import { AdvanceAdBase } from '../AdvanceAdBase';
import { AdvanceInterstitialListener } from '../AdvanceAdOpenListener';
import { window } from '@kit.ArkUI';
import { BYApp } from '../../../basic/BYApp';
import { AdvanceAdnLoadAdState, AdvanceAdnReportTKEventType } from '../../define/AdvanceDefine';
import { AdvanceAdLoadConfig } from '../../config/AdvanceAdConfig';
import { AdvanceCommonInterstitialAdapter } from '../adn/AdvanceCommonAdapter';
import { AdvanceAdInfo, AdvanceError, BYLog, ADV_ERR_AD_Invalid_Expired } from '../../../../../../../Index';
import { AdvanceCommonInterstitialAdapterBridge } from '../adn/AdvanceCommonInterstitialAdapterBridge';
import { AdvanceAdCacheManager } from '../../cache/AdvanceAdCacheManager';
import { AdvanceAdType } from '../../model/AdvanceAdInfo';

export class AdvanceInterstitial extends AdvanceAdBase {
  constructor(option: AdvanceAdLoadConfig) {
    super(option)
    this.adSlotType = AdvanceAdType.interstitial
  }

  protected mListener?: AdvanceInterstitialListener

  // 广告策略加载失败
  protected override loadStrategyFailed(err: AdvanceError): void {
    this.mListener?.onAdLoadFailed(err)
    this.destroyAdapters()
  }

  // 加载某一个渠道对象
  protected override loadAnyAdnAdapter(adapter: AdvanceCommonInterstitialAdapter): void {
    adapter.adapter_setInterstitialBridge(this.bridge)
    if (adapter.isFromCache) {
      this.bridge.interstitial_didAdLoaded(adapter, adapter.price)
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
  }

  setAdListener(listener: AdvanceInterstitialListener) {
    this.mListener = listener
  }

  isAdValid(): boolean {
    const valid = this.winAdapter?.adapter_isAdValid() ?? false
    if (!valid) {
      this.bridge.interstitial_didAdShowFailed(this.winAdapter as AdvanceCommonInterstitialAdapter, new AdvanceError(ADV_ERR_AD_Invalid_Expired, '广告展示前广告已失效过期'))
    }
    return valid
  }

  loadAd() {
    this.loadStrategy()
  }

  showAd(windowStage?: window.WindowStage) {
    if (!this.isAdValid()) {
      return;
    }
    if (!windowStage) {
      windowStage = BYApp.getWindowStage()
    }
    let adapter = this.winAdapter as AdvanceCommonInterstitialAdapter
    adapter.adapter_showAd(windowStage)
  }

  protected bridge: AdvanceCommonInterstitialAdapterBridge = {
    interstitial_didAdLoaded: (adapter: AdvanceCommonInterstitialAdapter, price: number) => {
      let supplier = this.matchSupplier(adapter)
      if (supplier.enable_cache && !AdvanceAdCacheManager.getAdCacheModelFromCachedKey(supplier.sdk_id)) { // 缓存adapter
        AdvanceAdCacheManager.cacheAd(adapter, price, supplier.cache_timeout ?? 0, this.adConfig.reqId ?? "",
          supplier.sdk_id)
      }
      this.setECPMIfNeeded(supplier, price)
      this.checkTarget(supplier, AdvanceAdnLoadAdState.success)
    },
    interstitial_didAdLoadFailed: (adapter: AdvanceCommonInterstitialAdapter, error: AdvanceError) => {
      let supplier = this.matchSupplier(adapter)
      this.checkTarget(supplier, AdvanceAdnLoadAdState.failed, error)
    },
    interstitial_didAdShow: (adapter: AdvanceCommonInterstitialAdapter) => {
      let supplier = this.matchSupplier(adapter)
      this.reportAdnTask(AdvanceAdnReportTKEventType.exposed, supplier)
      this.mListener?.onAdShow()
      // 删除缓存Adapter
      if (AdvanceAdCacheManager.getAdCacheModelFromCachedKey(supplier.sdk_id)) {
        AdvanceAdCacheManager.removeAdCacheModelFromCachedKey(supplier.sdk_id)
      }
    },
    interstitial_didAdShowFailed: (adapter: AdvanceCommonInterstitialAdapter, error: AdvanceError) => {
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
    interstitial_didAdClick: (adapter: AdvanceCommonInterstitialAdapter) => {
      let supplier = this.matchSupplier(adapter)
      this.reportAdnTask(AdvanceAdnReportTKEventType.clicked, supplier)
      this.mListener?.onAdClick()
    },
    interstitial_didAdClose: (adapter: AdvanceCommonInterstitialAdapter) => {
      this.mListener?.onAdClose()
      // 销毁各渠道Adapter对象
      this.destroyAdapters()
    }
  }

}