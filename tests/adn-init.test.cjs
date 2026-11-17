// Executes the production manager with fake ADN modules and an in-memory custom ADN list.
const assert = require('node:assert/strict');
const { test } = require('node:test');
const { readFileSync } = require('node:fs');
const path = require('node:path');
const { compileFunction } = require('node:vm');
const ts = require(process.env.ADVANCE_TYPESCRIPT_PATH ||
  '/Applications/DevEco-Studio.app/Contents/tools/hvigor/hvigor/node_modules/typescript');
const advance = path.resolve(__dirname, '../advancesdk/src/main/ets/bayes/advance');

function fixture(custom = false) {
  const namespace = {};
  const modules = new Map();
  const customCache = path.join(advance, 'cache/AdvCustomAdnCacheManager.ets');
  const customList = { custom_adn_list: [{
    id: 100, custom_adn_module: 'test_adapter', custom_config_adapter: 'TestConfigAdapter'
  }] };
  function load(file) {
    if (file === customCache) {
      return { AdvCustomAdnCacheManager: { customAdnListInfo: () => customList } };
    }
    if (modules.has(file)) return modules.get(file).exports;
    const compiled = ts.transpileModule(readFileSync(file, 'utf8'), {
      fileName: file.replace(/\.ets$/, '.ts'),
      compilerOptions: { module: ts.ModuleKind.CommonJS, target: ts.ScriptTarget.ES2021 },
      reportDiagnostics: true
    });
    assert.deepEqual(compiled.diagnostics.filter((d) => d.category === ts.DiagnosticCategory.Error), []);
    const module = { exports: {} };
    modules.set(file, module);
    const requireEts = (id) => {
      if (id === 'csj_adapter' || id === 'test_adapter') return namespace;
      assert.ok(id.startsWith('.'), `Unexpected dependency: ${id}`);
      return load(path.resolve(path.dirname(file), id) + '.ets');
    };
    compileFunction(compiled.outputText, ['require', 'module', 'exports'], { filename: file })(
      requireEts, module, module.exports);
    return module.exports;
  }
  const { AdvanceADNManager: manager } = load(path.join(advance, 'core/adn/AdvanceADNManager.ets'));
  const { AdvanceAdnInitState: states } = load(path.join(advance, 'define/AdvanceDefine.ets'));
  const errors = load(path.join(advance, 'define/AdvanceError.ets'));
  const supplier = {
    id: custom ? '100' : '3', name: 'test ADN', mediaid: 'app-id', mediakey: '',
    is_custom_adn: custom ? 1 : 0
  };
  return { manager, states, errors, supplier, namespace };
}

for (const custom of [false, true]) {
  test(`${custom ? 'custom' : 'built-in'} ADN: missing config class finishes every concurrent request`,
    { timeout: 1000 }, async () => {
      const { manager, states, errors, supplier } = fixture(custom);
      const first = manager.loadADN(supplier);
      const second = manager.loadADN(supplier);
      const third = manager.loadADN(supplier);
      assert.equal(manager.initializeStatus.get(supplier.id), states.loading);
      assert.equal(manager.pendingCompletions.get(supplier.id).length, 2);

      const results = await Promise.all([first, second, third]);
      const code = custom ? errors.ADV_ERR_CUSTOM_ADN_LOAD_FAILED : errors.ADV_ERR_ADN_UNINSTALLED;
      for (const result of results) {
        assert.ok(result instanceof errors.AdvanceError);
        assert.equal(result.code, String(code));
        assert.equal(result.msg, results[0].msg);
      }
      assert.equal(manager.initializeStatus.get(supplier.id), states.failed);
      assert.equal(manager.pendingCompletions.get(supplier.id).length, 0);
    });
}

test('initialization can retry after a missing class without retaining previous waiters',
  { timeout: 1000 }, async () => {
    const { manager, states, supplier, namespace } = fixture();
    await Promise.all([manager.loadADN(supplier), manager.loadADN(supplier)]);
    let finish;
    let initCount = 0;
    namespace.AdvCSJConfigAdapter = {
      initializeAdapter(appId, appKey, completion) {
        initCount++;
        finish = completion;
      }
    };
    const first = manager.loadADN(supplier);
    const second = manager.loadADN(supplier);
    await new Promise(setImmediate);
    assert.equal(initCount, 1);
    assert.equal(manager.pendingCompletions.get(supplier.id).length, 2);
    finish(undefined);
    assert.deepEqual(await Promise.all([first, second]), [undefined, undefined]);
    assert.equal(manager.initializeStatus.get(supplier.id), states.success);
    assert.equal(manager.pendingCompletions.get(supplier.id).length, 0);
    assert.equal(await manager.loadADN(supplier), undefined);
    assert.equal(initCount, 1);
  });

test('SDK initialization errors still finish every waiter with the SDK init error code',
  { timeout: 1000 }, async () => {
    const { manager, states, errors, supplier, namespace } = fixture();
    namespace.AdvCSJConfigAdapter = {
      initializeAdapter(appId, appKey, completion) {
        completion({ name: 'TestSDK', code: 123, message: 'SDK initialization failed' });
      }
    };
    const results = await Promise.all([manager.loadADN(supplier), manager.loadADN(supplier)]);
    for (const result of results) {
      assert.equal(result.code, String(errors.ADV_ERR_ADN_INIT_FAILED));
      assert.match(result.msg, /123/);
      assert.match(result.msg, /SDK initialization failed/);
    }
    assert.equal(manager.initializeStatus.get(supplier.id), states.failed);
    assert.equal(manager.pendingCompletions.get(supplier.id).length, 0);
  });
