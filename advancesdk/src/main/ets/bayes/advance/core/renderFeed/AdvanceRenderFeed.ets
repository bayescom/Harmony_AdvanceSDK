import { AdvanceAdBase } from '../AdvanceAdBase';
import { AdvanceRenderFeedListener } from '../AdvanceAdOpenListener';
import { AdvanceCommonRenderFeedAdapter } from '../adn/AdvanceCommonAdapter';
import { AdvanceRenderFeedAdWrapper } from './AdvanceRenderFeedAdWrapper';
import { AdvanceAdnLoadAdState, AdvanceAdnReportTKEventType } from '../../define/AdvanceDefine';
import { AdvanceAdInfo, AdvanceError, AdvanceAdLoadConfig, BYApp, BYLog } from '../../../../../../../Index';
import { AdvanceCommonRenderFeedAdapterBridge } from '../adn/AdvanceCommonRenderFeedAdapterBridge';
import { AdvanceAdCacheManager } from '../../cache/AdvanceAdCacheManager';
import { AdvanceAdType } from '../../model/AdvanceAdInfo';

export class AdvanceRenderFeed extends AdvanceAdBase {
  constructor(option: AdvanceAdLoadConfig) {
    super(option)
    this.adSlotType = AdvanceAdType.renderFeed
  }

  private mListener?: AdvanceRenderFeedListener

  // 广告策略加载失败
  protected override loadStrategyFailed(err: AdvanceError): void {
    this.mListener?.onAdLoadFailed(err)
    this.destroyAdapters()
  }

  // 加载某一个渠道对象
  protected override loadAnyAdnAdapter(adapter: AdvanceCommonRenderFeedAdapter): void {
    adapter.adapter_setRenderFeedBridge(this.bridge)
    if (adapter.isFromCache) {
      this.bridge.renderFeed_didAdLoaded(adapter, adapter.price)
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
    let adapter = this.winAdapter as AdvanceCommonRenderFeedAdapter
    adapter.adapter_render(BYApp.getUIContext())
  }

  setAdListener(listener: AdvanceRenderFeedListener) {
    this.mListener = listener
  }

  loadAd() {
    this.loadStrategy()
  }

  protected bridge: AdvanceCommonRenderFeedAdapterBridge = {
    renderFeed_didAdLoaded: (adapter: AdvanceCommonRenderFeedAdapter, price: number) => {
      let supplier = this.matchSupplier(adapter)
      if (supplier.enable_cache && !AdvanceAdCacheManager.getAdCacheModelFromCachedKey(supplier.sdk_id)) { // 缓存adapter
        AdvanceAdCacheManager.cacheAd(adapter, price, supplier.cache_timeout ?? 0, this.adConfig.reqId ?? "",
          supplier.sdk_id)
      }
      this.setECPMIfNeeded(supplier, price)
      this.checkTarget(supplier, AdvanceAdnLoadAdState.success)
    },
    renderFeed_didAdLoadFailed: (adapter: AdvanceCommonRenderFeedAdapter, error: AdvanceError) => {
      let supplier = this.matchSupplier(adapter)
      this.checkTarget(supplier, AdvanceAdnLoadAdState.failed, error)
    },
    renderFeed_didAdRenderSuccess: (adapter: AdvanceCommonRenderFeedAdapter, wrapper: AdvanceRenderFeedAdWrapper) => {
      let supplier = this.matchSupplier(adapter)
      this.mListener?.onRenderSuccess(wrapper)
      // 删除缓存Adapter
      if (AdvanceAdCacheManager.getAdCacheModelFromCachedKey(supplier.sdk_id)) {
        AdvanceAdCacheManager.removeAdCacheModelFromCachedKey(supplier.sdk_id)
      }
    },
    renderFeed_didAdRenderFail: (adapter: AdvanceCommonRenderFeedAdapter, error: AdvanceError) => {
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
    renderFeed_didAdShow: (adapter: AdvanceCommonRenderFeedAdapter) => {
      let supplier = this.matchSupplier(adapter)
      this.reportAdnTask(AdvanceAdnReportTKEventType.exposed, supplier)
      this.mListener?.onAdShow()
    },
    renderFeed_didAdClick: (adapter: AdvanceCommonRenderFeedAdapter) => {
      let supplier = this.matchSupplier(adapter)
      this.reportAdnTask(AdvanceAdnReportTKEventType.clicked, supplier)
      this.mListener?.onAdClick()
    },
    renderFeed_didAdVideoPlayStart: (adapter: AdvanceCommonRenderFeedAdapter) => {
      if (this.mListener?.onVideoPlayStart) {
        this.mListener?.onVideoPlayStart()
      }
    },
    renderFeed_didAdVideoPlayEnd: (adapter: AdvanceCommonRenderFeedAdapter) => {
      if (this.mListener?.onVideoPlayEnd) {
        this.mListener?.onVideoPlayEnd()
      }
    },
    renderFeed_didAdVideoPlayFailed: (adapter: AdvanceCommonRenderFeedAdapter, error: AdvanceError) => {
      if (this.mListener?.onVideoPlayFailed) {
        this.mListener?.onVideoPlayFailed(error)
      }
    }
  }

}