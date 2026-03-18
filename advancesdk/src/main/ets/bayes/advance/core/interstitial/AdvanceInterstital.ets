import { AdvanceAdBase } from '../AdvanceAdBase';
import { AdvanceInterstitialListener } from '../AdvanceAdOpenListener';
import { window } from '@kit.ArkUI';
import { BYApp } from '../../../basic/BYApp';
import { AdvanceAdType } from '../../define/AdvanceDefine';
import { AdvanceAdLoadConfig } from '../../config/AdvanceAdConfig';
import { AdvanceInterstitialCommonAdapter } from '../adn/AdvanceInterstitialCommonAdapter';
import { AdvanceError } from '../../../../../../../Index';

export class AdvanceInterstitial extends AdvanceAdBase {
  constructor(option: AdvanceAdLoadConfig) {
    super(option)
    this.adSlotType = AdvanceAdType.interstitial
  }

  protected mListener?: AdvanceInterstitialListener

  protected override adnWin(): void {
    let adapter = this.getCurrentAdapter() as AdvanceInterstitialCommonAdapter
    adapter.setInterstitialAdapterBridge({
      bridge_didAdShow: () => {
        this.reportBestAdnShowTask()
        this.mListener?.onAdShow()
      },
      bridge_didAdShowFailed: (error: AdvanceError) => {
        this.reportBestAdnShowFailedTask(error)
        if (this.mListener?.onAdShowFailed) {
          this.mListener?.onAdShowFailed(error)
        }
        // 销毁各渠道Adapter对象
        this.destroyAdapters()
      },
      bridge_didAdClick: () => {
        this.reportBestAdnClickTask()
        this.mListener?.onAdClick()
      },
      bridge_didAdClose: () => {
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
    this.loadStrategy()
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