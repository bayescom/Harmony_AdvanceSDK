import { AdvanceAdBase } from '../AdvanceAdBase';
import { AdvanceBannerListener } from '../AdvanceAdOpenListener';
import { NodeController } from '@kit.ArkUI';
import { AdvanceAdType, AdvanceAdnLoadAdState, AdvanceAdnReportTKEventType } from '../../define/AdvanceDefine';
import { AdvanceAdLoadConfig } from '../../config/AdvanceAdConfig';
import { AdvanceCommonBannerAdapter } from '../adn/AdvanceCommonAdapter';
import { AdvanceAdInfo, AdvanceError, BYApp, BYLog, ADV_ERR_AD_Invalid_Expired } from '../../../../../../../Index';
import { AdvanceCommonBannerAdapterBridge } from '../adn/AdvanceCommonBannerAdapterBridge';
import { AdvanceAdCacheManager } from '../../cache/AdvanceAdCacheManager';

export class AdvanceBanner extends AdvanceAdBase {
  constructor(option: AdvanceAdLoadConfig) {
    super(option)
    this.adSlotType = AdvanceAdType.banner
  }

  protected mListener?: AdvanceBannerListener

  // 广告策略加载失败
  protected override loadStrategyFailed(err: AdvanceError): void {
    this.mListener?.onAdLoadFailed(err)
    this.destroyAdapters()
  }

  // 加载某一个渠道对象
  protected override loadAnyAdnAdapter(adapter: AdvanceCommonBannerAdapter): void {
    adapter.adapter_setBannerBridge(this.bridge)
    if (adapter.isFromCache) {
      this.bridge.banner_didAdLoaded(adapter, adapter.price)
    } else {
      adapter.adapter_loadAd()
    }
  }

  // 所有Bidding渠道返回广告失败
  protected override allAdnLoadAdFailed(err: AdvanceError): void {
    BYLog.debug(`渠道广告全部加载失败: err = ${err.toString()}`)
    this.mListener?.onAdLoadFailed(err)
    this.destroyAdapters()
  }

  // Bidding成功
  protected override adnBidWin(adInfo: AdvanceAdInfo): void {
    this.mListener?.onAdLoaded(adInfo)
    // 竞胜的广告源渲染广告
    let adapter = this.winAdapter as AdvanceCommonBannerAdapter
    adapter.adapter_render(BYApp.getUIContext())
  }

  setAdListener(listener: AdvanceBannerListener) {
    this.mListener = listener
  }

  isAdValid(): boolean {
    const valid = this.winAdapter?.adapter_isAdValid() ?? false
    if (!valid) {
      this.bridge.banner_didAdShowFailed(this.winAdapter as AdvanceCommonBannerAdapter, new AdvanceError(ADV_ERR_AD_Invalid_Expired, '广告展示前广告已失效过期'))
    }
    return valid
  }

  loadAd() {
    this.loadStrategy()
  }

  getAdComponent(): NodeController | undefined {
    let adapter = this.winAdapter as AdvanceCommonBannerAdapter
    return adapter.adapter_getAdComponent()
  }

  getAcceptWidth(): number {
    return this.adConfig.adWidth ?? 0
  }

  getAcceptHeight(): number {
    return this.adConfig.adHeight ?? 0
  }

  protected bridge: AdvanceCommonBannerAdapterBridge = {
    banner_didAdLoaded: (adapter: AdvanceCommonBannerAdapter, price: number) => {
      let supplier = this.matchSupplier(adapter)
      if (supplier.enable_cache && !AdvanceAdCacheManager.getAdCacheModelFromCachedKey(supplier.sdk_id)) { // 缓存adapter
        AdvanceAdCacheManager.cacheAd(adapter, price, supplier.cache_timeout ?? 0, this.adConfig.reqId ?? "",
          supplier.sdk_id)
      }
      this.setECPMIfNeeded(supplier, price)
      this.checkTarget(supplier, AdvanceAdnLoadAdState.success)
    },
    banner_didAdLoadFailed: (adapter: AdvanceCommonBannerAdapter, error: AdvanceError) => {
      let supplier = this.matchSupplier(adapter)
      this.checkTarget(supplier, AdvanceAdnLoadAdState.failed, error)
    },
    banner_didAdShow: (adapter: AdvanceCommonBannerAdapter) => {
      let supplier = this.matchSupplier(adapter)
      this.reportAdnTask(AdvanceAdnReportTKEventType.exposed, supplier)
      this.mListener?.onAdShow()
      // 删除缓存Adapter
      if (AdvanceAdCacheManager.getAdCacheModelFromCachedKey(supplier.sdk_id)) {
        AdvanceAdCacheManager.removeAdCacheModelFromCachedKey(supplier.sdk_id)
      }
    },
    banner_didAdShowFailed: (adapter: AdvanceCommonBannerAdapter, error: AdvanceError) => {
      let supplier = this.matchSupplier(adapter)
      this.reportAdnTask(AdvanceAdnReportTKEventType.failed, supplier, error)
      this.mListener?.onAdShowFailed(error)
      // 销毁各渠道Adapter对象
      this.destroyAdapters()
      // 删除缓存Adapter
      if (AdvanceAdCacheManager.getAdCacheModelFromCachedKey(supplier.sdk_id)) {
        AdvanceAdCacheManager.removeAdCacheModelFromCachedKey(supplier.sdk_id)
      }
    },
    banner_didAdClick: (adapter: AdvanceCommonBannerAdapter) => {
      let supplier = this.matchSupplier(adapter)
      this.reportAdnTask(AdvanceAdnReportTKEventType.clicked, supplier)
      this.mListener?.onAdClick()
    },
    banner_didAdClose: () => {
      this.mListener?.onAdClose()
      // 销毁各渠道Adapter对象
      this.destroyAdapters()
    }
  }

}