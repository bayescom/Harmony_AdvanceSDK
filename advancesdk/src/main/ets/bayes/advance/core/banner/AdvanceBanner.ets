import { AdvanceAdBase } from '../AdvanceAdBase';
import { AdvanceBannerListener } from '../AdvanceAdOpenListener';
import { NodeController } from '@kit.ArkUI';
import { AdvanceAdType, AdvanceAdnLoadAdState, AdvanceAdnReportTKEventType } from '../../define/AdvanceDefine';
import { AdvanceAdLoadConfig } from '../../config/AdvanceAdConfig';
import { AdvanceBannerCommonAdapter } from '../adn/AdvanceBannerCommonAdapter';
import { AdvanceAdInfo, AdvanceError, BYApp, BYLog } from '../../../../../../../Index';
import { AdvanceSupplierModel } from '../../model/AdvanceNetModel';
import { AdvanceBannerAdapterBridge } from '../adn/AdvanceCommonAdapterBridge';

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
  protected override loadAnyAdnAdapter(adapter: AdvanceBannerCommonAdapter): void {
    adapter.setBannerAdapterBridge(this.adapterBridge)
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
    // 竞胜的广告源渲染广告
    this.winAdapter?.adapter_render(BYApp.getUIContext())
  }

  setAdListener(listener: AdvanceBannerListener) {
    this.mListener = listener
  }

  isAdValid() : boolean {
    return this.winAdapter?.adapter_isAdValid() ?? false
  }

  loadAd() {
    this.loadStrategy()
  }

  getAdComponent(): NodeController | undefined {
    return this.winAdapter?.adapter_getAdComponent()
  }

  getAcceptWidth(): number {
    return this.adConfig.adWidth ?? 0
  }

  getAcceptHeight(): number {
    return this.adConfig.adHeight ?? 0
  }

  protected adapterBridge: AdvanceBannerAdapterBridge = {
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