import { AdvanceAdBase } from '../AdvanceAdBase';
import { AdvanceNativeExpressListener } from '../AdvanceAdOpenListener';
import { NodeController } from '@kit.ArkUI';
import { AdvanceCommonNativeExpressAdapter } from '../adn/AdvanceCommonAdapter';
import { AdvanceAdType, AdvanceAdnLoadAdState, AdvanceAdnReportTKEventType } from '../../define/AdvanceDefine';
import { AdvanceAdInfo, AdvanceError, AdvanceAdLoadConfig, BYApp, BYLog } from '../../../../../../../Index';
import { AdvanceCommonNativeExpressAdapterBridge } from '../adn/AdvanceCommonNativeExpressAdapterBridge';
import { AdvanceAdCacheManager } from '../../cache/AdvanceAdCacheManager';

export class AdvanceNativeExpress extends AdvanceAdBase {
  constructor(option: AdvanceAdLoadConfig) {
    super(option)
    this.adSlotType = AdvanceAdType.nativeExpress
  }

  private mListener?: AdvanceNativeExpressListener

  // 广告策略加载失败
  protected override loadStrategyFailed(err: AdvanceError): void {
    this.mListener?.onAdLoadFailed(err)
    this.destroyAdapters()
  }

  // 加载某一个渠道对象
  protected override loadAnyAdnAdapter(adapter: AdvanceCommonNativeExpressAdapter): void {
    adapter.adapter_setNativeExpressBridge(this.bridge)
    if (adapter.isFromCache) {
      this.bridge.nativeExpress_didAdLoaded(adapter, adapter.price)
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
    let adapter = this.winAdapter as AdvanceCommonNativeExpressAdapter
    adapter.adapter_render(BYApp.getUIContext())
  }

  setAdListener(listener: AdvanceNativeExpressListener) {
    this.mListener = listener
  }

  loadAd() {
    this.loadStrategy()
  }

  getAdComponent(): NodeController | undefined {
    let adapter = this.winAdapter as AdvanceCommonNativeExpressAdapter
    return adapter.adapter_getAdComponent()
  }

  protected bridge: AdvanceCommonNativeExpressAdapterBridge = {
    nativeExpress_didAdLoaded: (adapter: AdvanceCommonNativeExpressAdapter, price: number) => {
      let supplier = this.matchSupplier(adapter)
      if (supplier.enable_cache && !AdvanceAdCacheManager.getAdCacheModelFromCachedKey(supplier.sdk_id)) { // 缓存adapter
        AdvanceAdCacheManager.cacheAd(adapter, price, supplier.cache_timeout ?? 0, this.adConfig.reqId ?? "",
          supplier.sdk_id)
      }
      this.setECPMIfNeeded(supplier, price)
      this.checkTarget(supplier, AdvanceAdnLoadAdState.success)
    },
    nativeExpress_didAdLoadFailed: (adapter: AdvanceCommonNativeExpressAdapter, error: AdvanceError) => {
      let supplier = this.matchSupplier(adapter)
      this.checkTarget(supplier, AdvanceAdnLoadAdState.failed, error)
    },
    nativeExpress_didAdRenderSuccess: (adapter: AdvanceCommonNativeExpressAdapter) => {
      let supplier = this.matchSupplier(adapter)
      this.mListener?.onRenderSuccess()
      // 删除缓存Adapter
      if (AdvanceAdCacheManager.getAdCacheModelFromCachedKey(supplier.sdk_id)) {
        AdvanceAdCacheManager.removeAdCacheModelFromCachedKey(supplier.sdk_id)
      }
    },
    nativeExpress_didAdRenderFail: (adapter: AdvanceCommonNativeExpressAdapter, error: AdvanceError) => {
      let supplier = this.matchSupplier(adapter)
      this.reportAdnTask(AdvanceAdnReportTKEventType.failed, supplier, error)
      this.mListener?.onRenderFail(error)
      // 销毁各渠道Adapter对象
      this.destroyAdapters()
      // 删除缓存Adapter
      if (AdvanceAdCacheManager.getAdCacheModelFromCachedKey(supplier.sdk_id)) {
        AdvanceAdCacheManager.removeAdCacheModelFromCachedKey(supplier.sdk_id)
      }
    },
    nativeExpress_didAdShow: (adapter: AdvanceCommonNativeExpressAdapter) => {
      let supplier = this.matchSupplier(adapter)
      this.reportAdnTask(AdvanceAdnReportTKEventType.exposed, supplier)
      this.mListener?.onAdShow()
    },
    nativeExpress_didAdClick: (adapter: AdvanceCommonNativeExpressAdapter) => {
      let supplier = this.matchSupplier(adapter)
      this.reportAdnTask(AdvanceAdnReportTKEventType.clicked, supplier)
      this.mListener?.onAdClick()
    },
    nativeExpress_didAdClose: (adapter: AdvanceCommonNativeExpressAdapter) => {
      this.mListener?.onAdClose()
      // 销毁各渠道Adapter对象
      this.destroyAdapters()
    },
    nativeExpress_didAdVideoPlayStart: (adapter: AdvanceCommonNativeExpressAdapter) => {
      if (this.mListener?.onVideoPlayStart) {
        this.mListener?.onVideoPlayStart()
      }
    },
    nativeExpress_didAdVideoPlayEnd: (adapter: AdvanceCommonNativeExpressAdapter) => {
      if (this.mListener?.onVideoPlayEnd) {
        this.mListener?.onVideoPlayEnd()
      }
    },
    nativeExpress_didAdVideoPlayFailed: (adapter: AdvanceCommonNativeExpressAdapter, error: AdvanceError) => {
      if (this.mListener?.onVideoPlayFailed) {
        this.mListener?.onVideoPlayFailed(error)
      }
    }
  }
}