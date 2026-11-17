// Run with: node --test tests/ad-cache.test.cjs
// Executes the production .ets classes; only platform APIs, networking and ADN loading are mocked.
const assert = require('node:assert/strict');
const { beforeEach, test } = require('node:test');
const { readFileSync } = require('node:fs');
const path = require('node:path');
const { compileFunction } = require('node:vm');

const ts = require(process.env.ADVANCE_TYPESCRIPT_PATH ||
  '/Applications/DevEco-Studio.app/Contents/tools/hvigor/hvigor/node_modules/typescript');
const sdk = path.resolve(__dirname, '../advancesdk');
const bayes = path.join(sdk, 'src/main/ets/bayes');
const at = (file) => path.join(bayes, file + '.ets');
const modules = new Map();
const stubs = new Map();
const publicApi = {};
let now = 1000000;
let sequence = 0;
const timers = new Map();
const logger = { debug() {}, error() {}, printE() {} };
const host = { getWindowStage: () => ({}), getUIContext: () => ({}) };
const adn = {};

stubs.set(path.join(sdk, 'Index.ets'), publicApi);
stubs.set(at('basic/BYLog'), { BYLog: logger });
stubs.set(at('basic/BYApp'), { BYApp: host });
stubs.set(at('basic/BYConstant'), { BYConstant: { context: {} } });
stubs.set(at('basic/BYUtil'), { BYUtil: { getReqID: () => `req-${++sequence}` } });
stubs.set(at('basic/util/BYStrUtil'), {
  BYStrUtil: { isNotEmpty: (value) => !!value, replaceAll: (s, a, b) => s.split(a).join(b) }
});
stubs.set(at('advance/core/adn/AdvanceADNManager'), { AdvanceADNManager: adn });
stubs.set(at('advance/net/AdvanceNetwork'), {
  default: { shared: () => ({ reportUrl: async () => true }) }
});
stubs.set(at('advance/net/AdvanceStrategyRequest'), { AdvanceStrategyRequest: {} });
stubs.set('@kit.BasicServicesKit', { systemDateTime: { getTime: () => now } });

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
    if (stubs.has(id)) return stubs.get(id);
    assert.ok(id.startsWith('.'), `Unexpected platform dependency: ${id}`);
    return load(path.resolve(path.dirname(file), id) + '.ets');
  };
  compileFunction(compiled.outputText, ['require', 'module', 'exports', 'setTimeout', 'clearTimeout'],
    { filename: file })(requireEts, module, module.exports,
    (callback) => { const id = ++sequence; timers.set(id, callback); return id; },
    (id) => timers.delete(id));
  return module.exports;
}

const errors = load(at('advance/define/AdvanceError'));
const common = load(at('advance/core/adn/AdvanceCommonAdapter'));
Object.assign(publicApi, errors, common, { BYApp: host, BYLog: logger });
const { AdvanceSupplierModel, AdvanceStrategyModel } = load(at('advance/model/AdvanceNetModel'));
const { AdvanceAdnLoadAdState } = load(at('advance/define/AdvanceDefine'));
const { AdvanceAdCacheManager: cache } = load(at('advance/cache/AdvanceAdCacheManager'));
const formats = [
  ['splash', 'splash/AdvanceSplash', 'AdvanceSplash', false],
  ['interstitial', 'interstitial/AdvanceInterstital', 'AdvanceInterstitial', false],
  ['rewardVideo', 'rewardVideo/AdvanceRewardVideo', 'AdvanceRewardVideo', false],
  ['banner', 'banner/AdvanceBanner', 'AdvanceBanner', true],
  ['nativeExpress', 'nativeExpress/AdvanceNativeExpress', 'AdvanceNativeExpress', true],
  ['renderFeed', 'renderFeed/AdvanceRenderFeed', 'AdvanceRenderFeed', true]
].map(([prefix, file, name, embedded]) => ({
  prefix, Ad: load(at('advance/core/' + file))[name], embedded
}));

class FakeAdapter extends common.AdvanceCommonAdapter {
  constructor() { super(new common.AdvanceADNUnitData()); this.valid = true; }
  adapter_loadAd() { throw new Error('Cached ads must not load again'); }
  adapter_isAdValid() { return this.valid; }
  adapter_showAd() { this.onShow?.(); }
  adapter_render() { this.onRender?.(); }
  adapter_setSplashBridge(bridge) { this.bridge = bridge; }
  adapter_setInterstitialBridge(bridge) { this.bridge = bridge; }
  adapter_setRewardVideoBridge(bridge) { this.bridge = bridge; }
}

function fixture(format) {
  const ad = new format.Ad({ placementId: 'aggregation-slot' });
  const adapter = new FakeAdapter();
  const supplier = new AdvanceSupplierModel();
  supplier.sdk_id = 'source';
  supplier.id = '3';
  supplier.enable_cache = 1;
  supplier.cache_timeout = 60;
  supplier.priority = 1;
  supplier.sdk_price = 50;
  ad.allSuppliers.push(supplier);
  ad.adapterMap.set(supplier.sdk_id, adapter);
  ad.winAdapter = adapter;
  ad.setAdListener({
    onAdLoaded() {}, onAdShow() {}, onAdShowFailed() {}, onAdClick() {}, onAdClose() {},
    onAdLoadFailed() {}, onRenderSuccess() {}, onRenderFail() {}
  });
  return { ad, adapter, supplier, key: supplier.sdk_id };
}

beforeEach(() => {
  now = 1000000;
  cache.cache.clear();
  timers.clear();
  adn.loadADN = async () => undefined;
  adn.generateAdnAdapter = async () => { throw new Error('Expected a cache hit'); };
});

test('writing another adapter preserves the first valid entry and its metadata', () => {
  const first = new FakeAdapter();
  cache.cacheAdIfAbsent(first, 50, 60, 'original', 'key');
  now += 10000;
  cache.cacheAdIfAbsent(new FakeAdapter(), 100, 120, 'replacement', 'key');
  const entry = cache.getAdCacheModelFromCachedKey('key');
  assert.equal(entry.adObject, first);
  assert.equal(entry.price, 50);
  assert.equal(entry.sourceReqId, 'original');
  assert.equal(entry.cachedTimestamp, 1000000);
  assert.equal(entry.expireTime, 60);
});

test('expires at the exact TTL boundary and allows a new entry', () => {
  cache.cacheAdIfAbsent(new FakeAdapter(), 50, 60, 'original', 'key');
  now += 59999;
  assert.ok(cache.getAdCacheModelFromCachedKey('key'));
  now += 1;
  assert.equal(cache.getAdCacheModelFromCachedKey('key'), undefined);
  const next = new FakeAdapter();
  cache.cacheAdIfAbsent(next, 70, 60, 'next', 'key');
  assert.equal(cache.getAdCacheModelFromCachedKey('key').adObject, next);
});

test('supplier TTL defaults to 30 minutes and explicit TTL is respected', () => {
  assert.equal(new AdvanceSupplierModel().cache_timeout, 1800);
  for (const duration of [undefined, null, 0]) {
    const supplier = AdvanceSupplierModel.fromJson({ enable_cache: 1, cache_timeout: duration });
    assert.equal(supplier.cache_timeout, 1800);
    const key = String(duration);
    cache.cacheAdIfAbsent(new FakeAdapter(), 50, supplier.cache_timeout, 'req', key);
    assert.equal(cache.getAdCacheModelFromCachedKey(key).expireTime, 1800);
  }
  assert.equal(AdvanceSupplierModel.fromJson({ cache_timeout: 60 }).cache_timeout, 60);
});

test('only the matching adapter can delete an entry', () => {
  const first = new FakeAdapter();
  const next = new FakeAdapter();
  cache.cacheAdIfAbsent(first, 50, 60, 'original', 'key');
  cache.removeAdCacheModelFromCachedKey('key', next);
  assert.equal(cache.getAdCacheModelFromCachedKey('key').adObject, first);
  cache.removeAdCacheModelFromCachedKey('key', first);
  assert.equal(cache.getAdCacheModelFromCachedKey('key'), undefined);
  cache.cacheAdIfAbsent(next, 70, 60, 'next', 'key');
  cache.removeAdCacheModelFromCachedKey('key', first);
  assert.equal(cache.getAdCacheModelFromCachedKey('key').adObject, next);
});

test('writing a new entry replaces an expired entry without a preceding cache read', () => {
  cache.cacheAdIfAbsent(new FakeAdapter(), 50, 60, 'original', 'key');
  now += 60000;
  const next = new FakeAdapter();
  cache.cacheAdIfAbsent(next, 70, 120, 'next', 'key');
  const entry = cache.getAdCacheModelFromCachedKey('key');
  assert.equal(entry.adObject, next);
  assert.equal(entry.price, 70);
  assert.equal(entry.sourceReqId, 'next');
  assert.equal(entry.expireTime, 120);
});

for (const format of formats) {
  test(`${format.prefix}: successful non-winning ads remain cached`, () => {
    const { ad, adapter, supplier, key } = fixture(format);
    const higher = new AdvanceSupplierModel();
    higher.sdk_price = 100;
    ad.parallelSuppliers = [higher, supplier];
    ad.bridge[`${format.prefix}_didAdLoaded`](adapter, 50);
    assert.equal(cache.getAdCacheModelFromCachedKey(key).adObject, adapter);
  });

  test(`${format.prefix}: cache deletion precedes channel and media callbacks; later callbacks preserve new cache`, () => {
    const { ad, adapter, key } = fixture(format);
    const next = new FakeAdapter();
    cache.cacheAdIfAbsent(adapter, 50, 60, 'original', key);
    const refill = () => {
      assert.equal(cache.getAdCacheModelFromCachedKey(key), undefined);
      cache.cacheAdIfAbsent(next, 70, 60, 'next', key);
    };
    if (format.embedded) {
      ad.mListener.onAdLoaded = refill;
      adapter.onRender = () => assert.equal(cache.getAdCacheModelFromCachedKey(key).adObject, next);
      ad.adnBidWin({});
    } else {
      adapter.onShow = refill;
      ad.showAd({});
    }
    const fail = format.embedded && format.prefix !== 'banner' ? 'didAdRenderFail' : 'didAdShowFailed';
    ad.bridge[`${format.prefix}_${fail}`](adapter, new errors.AdvanceError(1, 'show failed'));
    if (!format.embedded || format.prefix === 'banner') ad.bridge[`${format.prefix}_didAdShow`](adapter);
    if (format.embedded && format.prefix !== 'banner') {
      ad.bridge[`${format.prefix}_didAdRenderSuccess`](adapter, {});
    }
    assert.equal(cache.getAdCacheModelFromCachedKey(key).adObject, next);
  });

  test(`${format.prefix}: replaying a cache hit preserves metadata and cannot refresh an expired entry`, () => {
    const { ad, adapter, supplier, key } = fixture(format);
    const higher = new AdvanceSupplierModel();
    higher.sdk_price = 100;
    ad.parallelSuppliers = [higher, supplier];
    cache.cacheAdIfAbsent(adapter, 50, 60, 'original', key);
    now += 10000;
    adapter.isFromCache = true;
    ad.bridge[`${format.prefix}_didAdLoaded`](adapter, 100);
    assert.equal(cache.getAdCacheModelFromCachedKey(key).cachedTimestamp, 1000000);
    assert.equal(cache.getAdCacheModelFromCachedKey(key).price, 50);
    assert.equal(cache.getAdCacheModelFromCachedKey(key).sourceReqId, 'original');
    now += 50000;
    assert.equal(cache.getAdCacheModelFromCachedKey(key), undefined);
    ad.bridge[`${format.prefix}_didAdLoaded`](adapter, 100);
    assert.equal(cache.getAdCacheModelFromCachedKey(key), undefined);
  });
}

for (const format of formats.filter((f) => !f.embedded)) {
  test(`${format.prefix}: invalid ads are removed before reporting presentation failure`, () => {
    const { ad, adapter, key } = fixture(format);
    cache.cacheAdIfAbsent(adapter, 50, 60, 'original', key);
    adapter.valid = false;
    let failed = false;
    ad.mListener.onAdShowFailed = () => {
      failed = true;
      assert.equal(cache.cache.has(key), false);
      assert.equal(cache.getAdCacheModelFromCachedKey(key), undefined);
    };
    adapter.onShow = () => assert.fail('Invalid ad must not be presented');
    ad.showAd({});
    assert.equal(failed, true);
  });
}

function prepareCacheHit() {
  const format = formats[0];
  const { ad, adapter, supplier, key } = fixture(format);
  ad.allSuppliers = [];
  ad.adapterMap.clear();
  ad.winAdapter = undefined;
  const strategy = new AdvanceStrategyModel();
  strategy.suppliers = [supplier];
  strategy.setting.parallel_group = [[supplier.priority]];
  ad.strategyModel = strategy;
  cache.cacheAdIfAbsent(adapter, 50, 60, 'original', key);
  return { ad, adapter, supplier, key };
}

test('cache-hit loading preserves the original request, price and expiry without another ADN request', async () => {
  const { ad, adapter, supplier, key } = prepareCacheHit();
  now += 10000;
  ad.loadSuppliersConcurrently();
  await Promise.resolve();
  assert.equal(ad.winAdapter, adapter);
  assert.equal(adapter.isFromCache, true);
  assert.equal(adapter.price, 50);
  assert.equal(supplier.cachedReqId, 'original');
  assert.equal(cache.getAdCacheModelFromCachedKey(key).cachedTimestamp, 1000000);
  assert.equal(timers.size, 0);
});

test('initialization finishing after timeout cannot rebind a cached adapter', async () => {
  const { ad, adapter, key } = prepareCacheHit();
  let finishInit;
  adn.loadADN = () => new Promise((resolve) => { finishInit = resolve; });
  ad.loadSuppliersConcurrently();
  ad.observeLoadAdTimeout();
  finishInit();
  await Promise.resolve();
  assert.equal(adapter.isFromCache, false);
  assert.equal(adapter.bridge, undefined);
  assert.equal(cache.getAdCacheModelFromCachedKey(key).adObject, adapter);
  assert.equal(ad.allSuppliers[0].loadAdState, AdvanceAdnLoadAdState.timeout);
});
