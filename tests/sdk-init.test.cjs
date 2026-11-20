const assert = require('node:assert/strict');
const { test } = require('node:test');
const { readFileSync } = require('node:fs');
const path = require('node:path');
const { compileFunction } = require('node:vm');
const ts = require(process.env.ADVANCE_TYPESCRIPT_PATH ||
  '/Applications/DevEco-Studio.app/Contents/tools/hvigor/hvigor/node_modules/typescript');
const advance = path.resolve(__dirname, '../advancesdk/src/main/ets/bayes/advance');
const flush = () => new Promise(setImmediate);

function load(file, imports = {}, scheduleTimeout = setTimeout) {
  const module = { exports: {} };
  const compiled = ts.transpileModule(readFileSync(file, 'utf8'), {
    fileName: file.replace(/\.ets$/, '.ts'),
    compilerOptions: { module: ts.ModuleKind.CommonJS, target: ts.ScriptTarget.ES2021 }
  });
  compileFunction(compiled.outputText, ['require', 'module', 'exports', 'setTimeout'], { filename: file })(
    (name) => { assert.ok(name in imports, `Unexpected import: ${name}`); return imports[name]; },
    module, module.exports, scheduleTimeout);
  return module.exports;
}

const errors = load(path.join(advance, 'define/AdvanceError.ets'));
const info = { version: 'v1', custom_adn_list: [{ id: 100 }] };

function configCacheFor(setting) {
  const values = new Map();
  return load(path.join(advance, 'cache/AdvConfigCacheManager.ets'), {
    '../config/AdvanceSetting': { AdvanceSetting: { get: () => setting } },
    '../../basic/cache/BYPreferencesUtil': { BYPreferencesUtil: {
      putSync: (key, value) => values.set(key, value),
      getStringSync: (key) => values.get(key) ?? ''
    } }
  });
}

function fixture(cached, cacheWriteError, cacheReadError) {
  const requests = [];
  const configRequests = [];
  const logged = [];
  const setting = { appId: '' };
  const configCache = configCacheFor(setting);
  let descriptors = [];
  const network = {
    getCustomAdnListInfo: (version) => new Promise((resolve, reject) => {
      requests.push({ version, resolve, reject });
    }),
    getSDKCommonConfig: (appId = setting.appId) => new Promise((resolve, reject) => {
      configRequests.push({ appId, resolve, reject });
    })
  };
  const { AdvanceSDK: sdk } = load(path.join(advance, 'AdvanceSDK.ets'), {
    '../basic/BYConstant': { BYConstant: {} },
    '../basic/BYLifecycle': { BYLifecycle: { registerLife() {} } },
    '../basic/BYLog': { BYLog: { printE: (error) => logged.push(error), warn: (message) => logged.push(message) } },
    '../basic/BYSetting': { BYSetting: {} },
    './define/AdvanceConstant': { AdvanceConstant: {} },
    './config/AdvanceSetting': { AdvanceSetting: { get: () => setting } },
    './cache/AdvConfigCacheManager': configCache,
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
    sdk, requests, configRequests, logged, setting, cached: () => cached,
    sdkConfig: () => configCache.AdvConfigCacheManager.sdkConfig(),
    descriptors: () => descriptors,
    start: (appId = 'app') => sdk.start({}, appId)
  };
}

test('an empty AppId returns an initialization error without requesting configuration', async () => {
  const f = fixture();
  assert.equal((await f.start('')).code, String(errors.ADV_ERR_SDK_INIT_FAILED));
  assert.equal(f.requests.length, 0);
  assert.equal(f.configRequests.length, 0);
});

test('cold initialization saves the ADN list before completion, including an empty list', async () => {
  for (const value of [info, { version: 'v1', custom_adn_list: [] }]) {
    const f = fixture();
    let completed = false;
    const result = f.start().then((error) => { completed = true; return error; });
    assert.equal(completed, false);
    assert.equal(f.setting.appId, 'app');
    assert.equal(f.requests[0].version, undefined);
    assert.equal(f.configRequests[0].appId, 'app');
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

test('synchronous cache read errors reject startup without requesting the ADN list', async () => {
  const error = new Error('cache read failed');
  const f = fixture(undefined, undefined, error);
  await assert.rejects(f.start(), error);
  assert.equal(f.requests.length, 0);
  assert.deepEqual(f.descriptors(), []);
});

test('SDK config refresh does not delay startup and saves results under the requesting AppId', async () => {
  const f = fixture(info);
  assert.equal(await f.start('first'), undefined);
  assert.equal(await f.start('second'), undefined);
  assert.equal(f.sdkConfig(), undefined);
  assert.deepEqual(f.configRequests.map(({ appId }) => appId), ['first', 'second']);

  f.configRequests[1].resolve({ adspot_configs: { slot: { req_limit: 20 } } });
  await flush();
  f.configRequests[0].resolve({ adspot_configs: { slot: { req_limit: 10 } } });
  await flush();
  assert.equal(f.sdkConfig().adspot_configs.slot.req_limit, 20);
  assert.equal(await f.start('first'), undefined);
  assert.equal(f.sdkConfig().adspot_configs.slot.req_limit, 10);
});

test('failed SDK config refresh leaves the previous configuration available', async () => {
  const f = fixture(info);
  await f.start();
  const config = { material_inspection_config: { enable: 1 } };
  f.configRequests[0].resolve(config);
  await flush();
  assert.deepEqual(f.sdkConfig(), config);

  assert.equal(await f.start(), undefined);
  f.configRequests[1].reject(new errors.AdvanceError(503, 'unavailable'));
  await flush();
  assert.deepEqual(f.sdkConfig(), config);
  assert.match(f.logged[0], /503/);
});

test('SDK config uses the iOS endpoint and returns the original fields without adding defaults', async () => {
  const setting = { appId: 'app', useHttps: true };
  const requests = [];
  const http = {
    RequestMethod: { POST: 'POST' },
    HttpDataType: { OBJECT: 1 },
    createHttp: () => ({
      request(url, options, callback) { requests.push({ url, options, callback }); },
      destroy() {}
    })
  };
  const { default: Network } = load(path.join(advance, 'net/AdvanceNetwork.ets'), {
    '@ohos.net.http': { default: http },
    '@ohos.bundle.bundleManager': { default: {
      BundleFlag: { GET_BUNDLE_INFO_WITH_APPLICATION: 1 },
      getBundleInfoForSelf: async () => ({ versionName: '1.2.3' })
    } },
    '../../basic/BYLog': { BYLog: { debug() {}, error() {} } },
    '../config/AdvanceSetting': { AdvanceSetting: { get: () => setting } },
    '../define/AdvanceConstant': { AdvanceConstant: { ADV_SDK_VERSION_NAME: 'sdk-version' } },
    '../define/AdvanceError': errors,
    '../model/AdvanceNetModel': {}
  }, (_callback, delay) => { assert.equal(delay, 5000); return 1; });

  const startRequest = Network.shared().getSDKCommonConfig();
  await flush();
  const { url, options, callback } = requests[0];
  assert.equal(url, 'https://cruiser.bayescom.cn/advance_sdk_config');
  assert.equal(options.method, http.RequestMethod.POST);
  assert.equal(options.expectDataType, http.HttpDataType.OBJECT);
  assert.deepEqual(options.extraData, { appid: 'app', appver: '1.2.3', sdkver: 'sdk-version' });
  const response = {
    adspot_configs: { '100': { adspot_id: '100', req_interval: 300, imp_limit: 12 } },
    material_inspection_config: { enable: 1, exposure_sample_rate: 0 }
  };
  callback(undefined, { responseCode: 200, resultType: http.HttpDataType.OBJECT, result: response });
  assert.equal(await startRequest, response);

  for (const [responseCode, result, code] of [[503, {}, 503], [200, null, errors.ADV_ERR_DATA_NULL]]) {
    const request = Network.shared().getSDKCommonConfig();
    await flush();
    requests.at(-1).callback(undefined, { responseCode, resultType: http.HttpDataType.OBJECT, result });
    await assert.rejects(request, (error) => error.code === String(code));
  }
});
