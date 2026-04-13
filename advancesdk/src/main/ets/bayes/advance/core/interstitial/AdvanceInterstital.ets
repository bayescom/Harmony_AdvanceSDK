import { AdvanceAdBase } from '../AdvanceAdBase';
import { AdvanceInterstitialListener } from '../AdvanceAdOpenListener';
import { window } from '@kit.ArkUI';
import { BYApp } from '../../../basic/BYApp';
import { AdvanceAdType, AdvanceAdnLoadAdState, AdvanceAdnReportTKEventType } from '../../define/AdvanceDefine';
import { AdvanceAdLoadConfig } from '../../config/AdvanceAdConfig';
import { AdvanceInterstitialCommonAdapter } from '../adn/AdvanceInterstitialCommonAdapter';
import { AdvanceAdInfo, AdvanceError, BYLog } from '../../../../../../../Index';
import { AdvanceSupplierModel } from '../../model/AdvanceNetModel';
import { AdvanceInterstitialAdapterBridge } from '../adn/AdvanceCommonAdapterBridge';

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
  protected override loadAnyAdnAdapter(adapter: AdvanceInterstitialCommonAdapter): void {
    adapter.setInterstitialAdapterBridge(this.adapterBridge)
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
  }

  setAdListener(listener: AdvanceInterstitialListener) {
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

  protected adapterBridge: AdvanceInterstitialAdapterBridge = {
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
    bridge_didAdShowFailed: (supplier:AdvanceSupplierModel, error: AdvanceError) => {
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
    }
  }

}