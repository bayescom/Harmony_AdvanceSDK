import { AdvanceAdBase } from '../AdvanceAdBase';
import { AdvanceNativeExpressListener } from '../AdvanceAdOpenListener';
import { NodeController } from '@kit.ArkUI';
import { AdvanceNativeExpressCommonAdapter } from '../adn/AdvanceNativeExpressCommonAdapter';
import { AdvanceAdType, AdvanceAdnLoadAdState, AdvanceAdnReportTKEventType } from '../../define/AdvanceDefine';
import { AdvanceAdInfo, AdvanceError, AdvanceAdLoadConfig, BYApp, BYLog } from '../../../../../../../Index';
import { AdvanceSupplierModel } from '../../model/AdvanceNetModel';
import { AdvanceNativeExpressAdapterBridge } from '../adn/AdvanceCommonAdapterBridge';
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
  protected override loadAnyAdnAdapter(adapter: AdvanceNativeExpressCommonAdapter): void {
    adapter.setNativeExpressAdapterBridge(this.adapterBridge)
    if (adapter.isFromCache) {
      this.adapterBridge.bridge_didAdLoaded(adapter.unitData.supplier, adapter.price)
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
    this.winAdapter?.adapter_render(BYApp.getUIContext())
  }

  setAdListener(listener: AdvanceNativeExpressListener) {
    this.mListener = listener
  }

  loadAd() {
    this.loadStrategy()
  }

  getAdComponent(): NodeController | undefined {
    return this.winAdapter?.adapter_getAdComponent()
  }

  protected adapterBridge: AdvanceNativeExpressAdapterBridge = {
    bridge_cacheAdapterIfNeeded: (adapter: object, supplier: AdvanceSupplierModel, price: number) => {
      if (supplier.enable_cache) { // 缓存adapter
        AdvanceAdCacheManager.cacheAd(adapter, price, supplier.cache_timeout ?? 0, this.adConfig.reqId ?? "", supplier.sdk_id)
      }
    },
    bridge_didAdLoaded: (supplier: AdvanceSupplierModel, price: number) => {
      this.setECPMIfNeeded(supplier, price)
      this.checkTarget(supplier, AdvanceAdnLoadAdState.success)
    },
    bridge_didAdLoadFailed: (supplier: AdvanceSupplierModel, error: AdvanceError) => {
      this.checkTarget(supplier, AdvanceAdnLoadAdState.failed, error)
    },
    bridge_didAdRenderSuccess: (supplier: AdvanceSupplierModel) => {
      this.mListener?.onRenderSuccess()
    },
    bridge_didAdRenderFail: (supplier: AdvanceSupplierModel, error: AdvanceError) => {
      this.reportAdnTask(AdvanceAdnReportTKEventType.failed, supplier, error)
      this.mListener?.onRenderFail(error)
      // 销毁各渠道Adapter对象
      this.destroyAdapters()
    },
    bridge_didAdShow: (supplier: AdvanceSupplierModel) => {
      this.reportAdnTask(AdvanceAdnReportTKEventType.exposed, supplier)
      this.mListener?.onAdShow()
      // 删除缓存Adapter
      if (AdvanceAdCacheManager.getAdCacheModelFromCachedKey(supplier.sdk_id)) {
        AdvanceAdCacheManager.removeAdCacheModelFromCachedKey(supplier.sdk_id)
      }
    },
    bridge_didAdClick: (supplier: AdvanceSupplierModel) => {
      this.reportAdnTask(AdvanceAdnReportTKEventType.clicked, supplier)
      this.mListener?.onAdClick()
    },
    bridge_didAdClose: () => {
      this.mListener?.onAdClose()
      // 销毁各渠道Adapter对象
      this.destroyAdapters()
    },
    bridge_didAdVideoPlayStart: () => {
      if (this.mListener?.onVideoPlayStart) {
        this.mListener?.onVideoPlayStart()
      }
    },
    bridge_didAdVideoPlayEnd: () => {
      if (this.mListener?.onVideoPlayEnd) {
        this.mListener?.onVideoPlayEnd()
      }
    },
    bridge_didAdVideoPlayFailed: (error: AdvanceError) => {
      if (this.mListener?.onVideoPlayFailed) {
        this.mListener?.onVideoPlayFailed(error)
      }
    }
  }
}