const assert = require('node:assert/strict');
const { test } = require('node:test');
const { readFileSync } = require('node:fs');
const path = require('node:path');
const { compileFunction } = require('node:vm');
const ts = require(process.env.ADVANCE_TYPESCRIPT_PATH ||
  '/Applications/DevEco-Studio.app/Contents/tools/hvigor/hvigor/node_modules/typescript');
const advance = path.resolve(__dirname, '../advancesdk/src/main/ets/bayes/advance');
const flush = () => new Promise(setImmediate);

function load(file, imports = {}) {
  const module = { exports: {} };
  const compiled = ts.transpileModule(readFileSync(file, 'utf8'), {
    fileName: file.replace(/\.ets$/, '.ts'),
    compilerOptions: { module: ts.ModuleKind.CommonJS, target: ts.ScriptTarget.ES2021 }
  });
  compileFunction(compiled.outputText, ['require', 'module', 'exports'], { filename: file })(
    (name) => { assert.ok(name in imports, `Unexpected import: ${name}`); return imports[name]; },
    module, module.exports);
  return module.exports;
}

const errors = load(path.join(advance, 'define/AdvanceError.ets'));
const info = { version: 'v1', custom_adn_list: [{ id: 100 }] };

function fixture(cached, cacheWriteError, cacheReadError) {
  const requests = [];
  const logged = [];
  const setting = { appId: '' };
  let descriptors = [];
  const network = { getCustomAdnListInfo: (version) => new Promise((resolve, reject) => {
    requests.push({ version, resolve, reject });
  }) };
  const { AdvanceSDK: sdk } = load(path.join(advance, 'AdvanceSDK.ets'), {
    '../basic/BYConstant': { BYConstant: {} },
    '../basic/BYLifecycle': { BYLifecycle: { registerLife() {} } },
    '../basic/BYLog': { BYLog: { printE: (error) => logged.push(error) } },
    '../basic/BYSetting': { BYSetting: {} },
    './define/AdvanceConstant': { AdvanceConstant: {} },
    './config/AdvanceSetting': { AdvanceSetting: { get: () => setting } },
    './cache/AdvCustomAdnCacheManager': { AdvCustomAdnCacheManager: {
      customAdnListInfo: () => {
        if (cacheReadError) throw cacheReadError;
        return cached;
      },
      cacheCustomAdnListInfo: (value) => {
        if (cacheWriteError) throw cacheWriteError;
        cached = value;
      }
    } },
    './net/AdvanceNetwork': { default: { shared: () => network } },
    './define/AdvanceError': errors,
    './core/adn/AdvanceAdapterRepository': { AdvanceAdapterRepository: {
      loadBuiltInAdapterDescriptors: () => { descriptors = []; },
      syncCustomAdaptersWithAdnList: (list) => { descriptors = list ?? []; }
    } }
  });
  return {
    sdk, requests, logged, setting, cached: () => cached,
    descriptors: () => descriptors,
    start: (appId = 'app') => sdk.start({}, appId)
  };
}

test('an empty AppId returns an initialization error without requesting configuration', async () => {
  const f = fixture();
  assert.equal((await f.start('')).code, String(errors.ADV_ERR_SDK_INIT_FAILED));
  assert.equal(f.requests.length, 0);
});

test('cold initialization saves configuration before completion, including an empty ADN list', async () => {
  for (const value of [info, { version: 'v1', custom_adn_list: [] }]) {
    const f = fixture();
    let completed = false;
    const result = f.start().then((error) => { completed = true; return error; });
    assert.equal(completed, false);
    assert.equal(f.setting.appId, 'app');
    assert.equal(f.requests[0].version, undefined);
    f.requests[0].resolve(value);
    assert.equal(await result, undefined);
    assert.equal(f.cached(), value);
    assert.equal(f.descriptors(), value.custom_adn_list);
  }
});

test('cached initialization resolves without waiting for the background refresh', async () => {
  for (const list of [[{ id: 200 }], []]) {
    const f = fixture(info);
    let completions = 0;
    await f.start().then((error) => {
      assert.equal(error, undefined);
      completions++;
    });
    assert.equal(completions, 1);
    assert.equal(f.descriptors(), info.custom_adn_list);
    assert.equal(f.requests[0].version, 'v1');
    const updated = { version: 'v2', custom_adn_list: list };
    f.requests[0].resolve(updated);
    await flush();
    assert.equal(f.cached(), list.length ? updated : info);
    assert.equal(f.descriptors(), list.length ? list : info.custom_adn_list);
    assert.equal(completions, 1);
  }
});

test('cold request failure is returned to the caller and a subsequent initialization can retry', async () => {
  const f = fixture();
  const result = f.start();
  const error = new errors.AdvanceError(1001, 'offline');
  f.requests[0].reject(error);
  assert.equal(await result, error);
  assert.equal(f.cached(), undefined);
  const retry = f.start();
  f.requests[1].resolve(info);
  assert.equal(await retry, undefined);
  assert.equal(f.cached(), info);
  assert.equal(f.descriptors(), info.custom_adn_list);
});

test('background update failure retains cache without changing initialization success', async () => {
  const f = fixture(info);
  let completions = 0;
  await f.start().then((error) => {
    assert.equal(error, undefined);
    completions++;
  });
  const error = new errors.AdvanceError(1001, 'offline');
  f.requests[0].reject(error);
  await flush();
  assert.equal(completions, 1);
  assert.equal(f.cached(), info);
  assert.equal(f.descriptors(), info.custom_adn_list);
  assert.deepEqual(f.logged, [error]);
});

test('a configuration error from the network layer is returned without publishing custom descriptors', async () => {
  const f = fixture();
  const result = f.start();
  const error = new errors.AdvanceError(errors.ADV_ERR_DATA_NULL, '自定义ADN配置为空');
  f.requests[0].reject(error);
  assert.equal(await result, error);
  assert.equal(f.cached(), undefined);
  assert.deepEqual(f.descriptors(), []);
});

test('cache write errors are returned before custom descriptors are published', { timeout: 1000 }, async () => {
  const error = new Error('cache write failed');
  const f = fixture(undefined, error);
  const result = f.start();
  f.requests[0].resolve(info);
  const resultError = await result;
  assert.equal(resultError, error);
  assert.deepEqual(f.descriptors(), []);
});

test('synchronous cache read errors reject the startup Promise without requesting configuration', async () => {
  const error = new Error('cache read failed');
  const f = fixture(undefined, undefined, error);
  await assert.rejects(f.start(), error);
  assert.equal(f.requests.length, 0);
  assert.deepEqual(f.descriptors(), []);
});
