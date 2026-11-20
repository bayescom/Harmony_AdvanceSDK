// Executes the production repository and manager with fake ADN modules.
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
  const namespaces = new Map([['csj_adapter', namespace], ['test_adapter', namespace]]);
  const importedModules = [];
  const stubs = new Map([
    [path.resolve(advance, '../basic/BYLog.ets'), { BYLog: {} }],
    [path.resolve(advance, '../basic/BYUtil.ets'), { BYUtil: {} }],
    [path.join(advance, 'core/AdvanceDeviceManager.ets'), { AdvanceDeviceManager: {} }],
    [path.join(advance, 'net/AdvanceNetwork.ets'), { default: {} }]
  ]);
  const customList = [{
    id: 100, custom_adn_module: 'test_adapter', custom_config_adapter: 'TestConfigAdapter'
  }];
  function load(file) {
    if (stubs.has(file)) return stubs.get(file);
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
      if (id === '@kit.BasicServicesKit' || id === '@ohos.bundle.bundleManager') return {};
      if (!id.startsWith('.')) {
        importedModules.push(id);
        if (namespaces.has(id)) return namespaces.get(id);
        throw new Error(`ADN module not installed: ${id}`);
      }
      return load(path.resolve(path.dirname(file), id) + '.ets');
    };
    compileFunction(compiled.outputText, ['require', 'module', 'exports'], { filename: file })(
      requireEts, module, module.exports);
    return module.exports;
  }
  const { AdvanceAdapterRepository: repository } = load(path.join(advance, 'core/adn/AdvanceAdapterRepository.ets'));
  repository.syncCustomAdaptersWithAdnList(customList);
  const { AdvanceADNManager: manager } = load(path.join(advance, 'core/adn/AdvanceADNManager.ets'));
  const { AdvanceAdnInitState: states } = load(path.join(advance, 'define/AdvanceDefine.ets'));
  const errors = load(path.join(advance, 'define/AdvanceError.ets'));
  const supplier = {
    id: custom ? '100' : '3', name: 'test ADN', mediaid: 'app-id', mediakey: '',
    is_custom_adn: custom ? 1 : 0
  };
  const { AdvanceAdType: adTypes } = load(path.join(advance, 'model/AdvanceAdInfo.ets'));
  return { manager, states, errors, supplier, namespace, repository, namespaces, importedModules, adTypes, load };
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

test('built-in descriptors match actual module exports without importing or initializing any ADN', () => {
  const { repository, importedModules, adTypes } = fixture();
  repository.loadBuiltInAdapterDescriptors();
  assert.equal(repository.allDescriptors().length, 5);
  const root = path.resolve(__dirname, '..');
  for (const descriptor of repository.allDescriptors()) {
    const index = readFileSync(path.join(root, descriptor.moduleName, 'Index.ets'), 'utf8');
    for (const name of [descriptor.configAdapterName, ...descriptor.adapters.values()]) {
      assert.match(index, new RegExp(`export\\s*\\{\\s*${name}\\s*\\}`));
    }
  }
  assert.equal(repository.descriptorForSupplierId('5').adapters.has(adTypes.banner), false);
  assert.equal(repository.descriptorForSupplierId('12').adapters.has(adTypes.banner), false);
  assert.equal(repository.descriptorForSupplierId('12').adapters.has(adTypes.renderFeed), false);
  assert.equal(repository.descriptorForSupplierId('unknown'), undefined);
  assert.deepEqual(importedModules, []);
});

test('custom descriptors declare only configured ad types and keep built-ins authoritative', () => {
  const { repository, adTypes } = fixture();
  repository.syncCustomAdaptersWithAdnList([
    { id: 3, custom_adn_module: 'override' },
    { id: 100, custom_adn_module: 'first', custom_config_adapter: 'Config',
      custom_splash_adapter: 'Splash', custom_banner_adapter: '', custom_renderfeed_adapter: 'Feed' },
    { id: 100, custom_adn_module: 'duplicate' },
    { id: null }, { id: undefined }
  ]);
  assert.equal(repository.descriptorForSupplierId('3').moduleName, 'csj_adapter');
  const descriptor = repository.descriptorForSupplierId('100');
  assert.equal(descriptor.moduleName, 'first');
  assert.equal(descriptor.configAdapterName, 'Config');
  assert.equal(descriptor.versionParameterKey, 'custom_100_v');
  assert.deepEqual([...descriptor.adapters], [[adTypes.splash, 'Splash'], [adTypes.renderFeed, 'Feed']]);
  assert.equal(repository.allDescriptors().length, 6);
});

test('a full custom-list refresh removes deleted channels and an empty list restores built-ins', () => {
  const { repository } = fixture();
  const old = repository.descriptorForSupplierId('100');
  repository.syncCustomAdaptersWithAdnList([{ id: 200, custom_adn_module: 'new' }]);
  assert.equal(repository.descriptorForSupplierId('100'), undefined);
  assert.equal(repository.descriptorForSupplierId('200').moduleName, 'new');
  assert.equal(old.moduleName, 'test_adapter');
  repository.syncCustomAdaptersWithAdnList([]);
  assert.equal(repository.descriptorForSupplierId('200'), undefined);
  assert.equal(repository.allDescriptors().length, 5);
  repository.syncCustomAdaptersWithAdnList([{ id: 200 }]);
  repository.loadBuiltInAdapterDescriptors();
  assert.equal(repository.descriptorForSupplierId('200'), undefined);
});

test('every declared built-in ad type creates the configured adapter lazily', async () => {
  const { repository, manager, namespaces, importedModules } = fixture();
  repository.loadBuiltInAdapterDescriptors();
  let created = 0;
  for (const descriptor of repository.allDescriptors()) {
    const exports = {};
    descriptor.adapters.forEach((name) => {
      exports[name] = class {
        constructor(data) { this.unitData = data; this.name = name; created++; }
      };
    });
    namespaces.set(descriptor.moduleName, exports);
  }
  assert.equal(created, 0);
  for (const descriptor of repository.allDescriptors()) {
    for (const [adType, name] of descriptor.adapters) {
      const data = { adnId: descriptor.supplierId, adType, placementId: 'slot' };
      const adapter = await manager.generateAdnAdapter(data);
      assert.equal(adapter.name, name);
      assert.equal(adapter.unitData, data);
    }
  }
  assert.equal(created, 27);
  assert.equal(importedModules.length, created);
  assert.equal(manager.initializeStatus.size, 0);
});

test('unknown channels and unsupported ad types do not import ADN modules', async () => {
  const { manager, adTypes, importedModules } = fixture();
  for (const data of [
    { adnId: '12', adType: adTypes.banner }, { adnId: '12', adType: adTypes.renderFeed },
    { adnId: '5', adType: adTypes.banner }, { adnId: '3', adType: adTypes.unknown },
    { adnId: '100', adType: adTypes.splash }, { adnId: 'unknown', adType: adTypes.splash }
  ]) assert.equal(await manager.generateAdnAdapter(data), undefined);
  assert.deepEqual(importedModules, []);
});

test('uninstalled modules and missing ad exports return an unavailable adapter', async () => {
  const { manager, namespaces, adTypes } = fixture();
  assert.equal(await manager.generateAdnAdapter({ adnId: '3', adType: adTypes.splash }), undefined);
  namespaces.delete('csj_adapter');
  assert.equal(await manager.generateAdnAdapter({ adnId: '3', adType: adTypes.splash }), undefined);
  assert.equal(await manager.getSDKVersion('3'), undefined);
});

test('custom adapter creation keeps one descriptor snapshot during a refresh', async () => {
  const { manager, repository, namespace, namespaces, adTypes } = fixture();
  repository.syncCustomAdaptersWithAdnList([{
    id: 100, custom_adn_module: 'test_adapter', custom_splash_adapter: 'OldSplash'
  }]);
  namespace.OldSplash = class { constructor() { this.name = 'old'; } };
  namespaces.set('next_adapter', { NextSplash: class { constructor() { this.name = 'next'; } } });
  const first = manager.generateAdnAdapter({ adnId: '100', adType: adTypes.splash });
  repository.syncCustomAdaptersWithAdnList([{
    id: 100, custom_adn_module: 'next_adapter', custom_splash_adapter: 'NextSplash'
  }]);
  assert.equal((await first).name, 'old');
  assert.equal((await manager.generateAdnAdapter({ adnId: '100', adType: adTypes.splash })).name, 'next');
});

test('version reporting uses repository keys and skips unavailable or empty versions without SDK initialization', async () => {
  const { repository, namespaces, manager, load } = fixture();
  for (const descriptor of repository.allDescriptors()) {
    if (!descriptor.versionParameterKey) continue;
    namespaces.set(descriptor.moduleName, {
      [descriptor.configAdapterName]: {
        getSDKVersion: () => descriptor.supplierId === '5' ? '' : `version-${descriptor.supplierId}`,
        initializeAdapter: () => assert.fail('Version reporting must not initialize an ADN')
      }
    });
  }
  namespaces.delete('gdt_adapter');
  const { AdvanceStrategyRequest } = load(path.join(advance, 'net/AdvanceStrategyRequest.ets'));
  assert.deepEqual(await AdvanceStrategyRequest.addSDKVersion(), {
    mry_v: 'version-1', csj_v: 'version-3', custom_100_v: 'version-100'
  });
  assert.equal(manager.initializeStatus.size, 0);
});
