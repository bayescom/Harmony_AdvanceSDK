import { AdvanceAdBase } from '../AdvanceAdBase';
import { AdvanceRenderFeedListener } from '../AdvanceAdOpenListener';
import { AdvanceRenderFeedCommonAdapter } from '../adn/AdvanceRenderFeedCommonAdapter';
import { AdvanceRenderFeedWrapper } from './AdvanceRenderFeedWrapper';
import { AdvanceAdType, AdvanceAdnLoadAdState, AdvanceAdnReportTKEventType } from '../../define/AdvanceDefine';
import { AdvanceAdInfo, AdvanceError, AdvanceAdLoadConfig, BYApp, BYLog } from '../../../../../../../Index';
import { AdvanceSupplierModel } from '../../model/AdvanceNetModel';
import { AdvanceRenderFeedAdapterBridge } from '../adn/AdvanceCommonAdapterBridge';

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
  protected override loadAnyAdnAdapter(adapter: AdvanceRenderFeedCommonAdapter): void {
    adapter.setRenderFeedAdapterBridge(this.adapterBridge)
    adapter.adapter_loadAd()
  }

  // Bidding失败（渠道广告全部加载失败）
  protected override allAdnBiddingFail(err: AdvanceError): void {
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

  setAdListener(listener: AdvanceRenderFeedListener) {
    this.mListener = listener
  }

  loadAd() {
    this.loadStrategy()
  }

  protected adapterBridge: AdvanceRenderFeedAdapterBridge = {
    bridge_didAdLoaded: (supplier: AdvanceSupplierModel, price: number) => {
      this.setECPMIfNeeded(supplier, price)
      this.checkTarget(supplier, AdvanceAdnLoadAdState.success)
    },
    bridge_didAdLoadFailed: (supplier: AdvanceSupplierModel, error: AdvanceError) => {
      this.checkTarget(supplier, AdvanceAdnLoadAdState.failed, error)
    },
    bridge_didAdRenderSuccess: (supplier: AdvanceSupplierModel, wrapper: AdvanceRenderFeedWrapper) => {
      this.mListener?.onRenderSuccess(wrapper)
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
    },
    bridge_didAdClick: (supplier: AdvanceSupplierModel) => {
      this.reportAdnTask(AdvanceAdnReportTKEventType.clicked, supplier)
      this.mListener?.onAdClick()
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