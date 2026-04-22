import { AdvanceAdBase } from '../AdvanceAdBase';
import { AdvanceRewardVideoListener } from '../AdvanceAdOpenListener';
import { window } from '@kit.ArkUI';
import { BYApp } from '../../../basic/BYApp';
import { AdvanceAdType, AdvanceAdnLoadAdState, AdvanceAdnReportTKEventType } from '../../define/AdvanceDefine';
import { AdvanceAdLoadConfig } from '../../config/AdvanceAdConfig';
import { AdvanceAdInfo, AdvanceError, BYLog } from '../../../../../../../Index';
import { AdvanceRewardVideoCommonAdapter } from '../adn/AdvanceRewardVideoCommonAdapter';
import { AdvanceSupplierModel } from '../../model/AdvanceNetModel';
import { AdvanceRewardVideoAdapterBridge } from '../adn/AdvanceCommonAdapterBridge';

export class AdvanceRewardVideo extends AdvanceAdBase {
  constructor(option: AdvanceAdLoadConfig) {
    super(option)
    this.adSlotType = AdvanceAdType.rewardVideo
  }

  protected mListener?: AdvanceRewardVideoListener

  // 广告策略加载失败
  protected override loadStrategyFailed(err: AdvanceError): void {
    this.mListener?.onAdLoadFailed(err)
    this.destroyAdapters()
  }

  // 加载某一个渠道对象
  protected override loadAnyAdnAdapter(adapter: AdvanceRewardVideoCommonAdapter): void {
    adapter.setRewardVideoAdapterBridge(this.adapterBridge)
    adapter.adapter_loadAd()
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

  setAdListener(listener: AdvanceRewardVideoListener) {
    this.mListener = listener
  }

  isAdValid() : boolean {
    return this.winAdapter?.adapter_isAdValid() ?? false
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
    this.winAdapter?.adapter_showAd(windowStage)
  }

  protected adapterBridge: AdvanceRewardVideoAdapterBridge = {
    bridge_didAdLoaded: (supplier: AdvanceSupplierModel, price: number) => {
      this.setECPMIfNeeded(supplier, price)
      this.checkTarget(supplier, AdvanceAdnLoadAdState.success)
    },
    bridge_didAdLoadFailed: (supplier: AdvanceSupplierModel, error: AdvanceError) => {
      this.checkTarget(supplier, AdvanceAdnLoadAdState.failed, error)
    },
    bridge_didAdShow: (supplier: AdvanceSupplierModel) => {
      this.reportAdnTask(AdvanceAdnReportTKEventType.exposed, supplier)
      this.mListener?.onAdShow()
    },
    bridge_didAdShowFailed: (supplier: AdvanceSupplierModel, error: AdvanceError) => {
      this.reportAdnTask(AdvanceAdnReportTKEventType.failed, supplier, error)
      this.mListener?.onAdShowFailed(error)
      // 销毁各渠道Adapter对象
      this.destroyAdapters()
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
    bridge_didAdReward: () => {
      this.mListener?.onAdReward()
    },
    bridge_didAdVideoPlayEnd: () => {
      if (this.mListener?.onVideoPlayEnd) {
        this.mListener?.onVideoPlayEnd()
      }
    }
  }

}