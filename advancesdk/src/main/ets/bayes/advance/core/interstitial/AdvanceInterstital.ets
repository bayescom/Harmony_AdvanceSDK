import { AdvanceAdBase } from '../AdvanceAdBase';
import { AdvanceInterstitialListener } from '../AdvanceAdOpenListener';
import { window } from '@kit.ArkUI';
import { BYApp } from '../../../basic/BYApp';
import { AdvanceAdType } from '../../define/AdvanceDefine';
import { AdvanceOption } from '../../config/AdvanceOption';
import { AdvanceInterstitialCommonAdapter } from '../adn/AdvanceInterstitialCommonAdapter';
import { AdvanceError } from '../../../../../../../Index';

export class AdvanceInterstitial extends AdvanceAdBase {
  constructor(option: AdvanceOption) {
    super(option)
    this.adSlotType = AdvanceAdType.interstitial
  }

  protected mListener?: AdvanceInterstitialListener

  protected override adnWin(): void {
    let adapter = this.getCurrentAdapter() as AdvanceInterstitialCommonAdapter
    adapter.setInterstitialAdapterBridge({
      interstitialAdapter_didAdShow: () => {
        this.reportBestAdnShowTask()
        this.mListener?.onAdShow()
      },
      interstitialAdapter_didAdShowFailed: (error: AdvanceError) => {
        this.reportBestAdnShowFailedTask(error)
        this.mListener?.onAdShowFailed(error)
        // 销毁各渠道Adapter对象
        this.destroyAdapters()
      },
      interstitialAdapter_didAdClick: () => {
        this.reportBestAdnClickTask()
        this.mListener?.onAdClick()
      },
      interstitialAdapter_didAdClose: () => {
        this.mListener?.onAdClose()
        // 销毁各渠道Adapter对象
        this.destroyAdapters()
      }
    })
  }

  setAdListener(listener: AdvanceInterstitialListener) {
    this.loadListener = listener
    this.mListener = listener
  }

  isAdValid() : boolean {
    let adapter = this.getCurrentAdapter()
    if (adapter) {
      return adapter.adapter_isAdValid()
    }
    return false
  }

  loadAd() {
    super.loadStrategy()
  }

  showAd(windowStage?: window.WindowStage) {
    if (!this.isAdValid()) {
      return;
    }
    if (!windowStage) {
      windowStage = BYApp.getWindowStage()
    }
    this.getCurrentAdapter()?.adapter_showAd(windowStage)
  }

}