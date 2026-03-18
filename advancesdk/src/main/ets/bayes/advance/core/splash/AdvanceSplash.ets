import { AdvanceAdBase } from '../AdvanceAdBase';
import { AdvanceSplashListener } from '../AdvanceAdOpenListener';
import { window } from '@kit.ArkUI';
import { BYApp } from '../../../basic/BYApp';
import { AdvanceAdType } from '../../define/AdvanceDefine';
import { AdvanceAdLoadConfig } from '../../config/AdvanceAdConfig';
import { AdvanceSplashCommonAdapter } from '../adn/AdvanceSplashCommonAdapter';
import { AdvanceError } from '../../../../../../../Index';

export class AdvanceSplash extends AdvanceAdBase {
  constructor(config: AdvanceAdLoadConfig) {
    super(config)
    this.adSlotType = AdvanceAdType.splash
  }

  protected mListener?: AdvanceSplashListener

  protected override adnWin(): void {
    let adapter = this.getCurrentAdapter() as AdvanceSplashCommonAdapter
    adapter.setSplashAdapterBridge({
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

  setAdListener(listener: AdvanceSplashListener) {
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