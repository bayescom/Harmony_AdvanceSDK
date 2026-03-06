import { AdvanceAdBase } from '../AdvanceAdBase';
import { AdvanceSplashListener } from '../AdvanceAdOpenListener';
import { NodeController, window } from '@kit.ArkUI';
import { BYApp } from '../../../basic/BYApp';
import { AdvanceAdType } from '../../define/AdvanceDefine';
import { AdvanceOption, AdvanceRenderOption } from '../../config/AdvanceOption';
import { AdvanceSplashCommonAdapter } from '../adn/AdvanceSplashCommonAdapter';
import { AdvanceError } from '../../../../../../../Index';

export class AdvanceSplash extends AdvanceAdBase {
  constructor(option: AdvanceOption) {
    super(option)
    this.adSlotType = AdvanceAdType.splash
  }

  protected mListener?: AdvanceSplashListener

  protected override adnWin(): void {
    let adapter = this.getCurrentAdapter() as AdvanceSplashCommonAdapter
    adapter.setSplashAdapterBridge({
      splashAdapter_didAdShow: () => {
        this.reportBestAdnShowTask()
        this.mListener?.onAdShow()
      },
      splashAdapter_didAdShowFailed: (error: AdvanceError) => {
        this.reportBestAdnShowFailedTask(error)
        this.mListener?.onAdShowFailed(error)
      },
      splashAdapter_didAdClick: () => {
        this.reportBestAdnClickTask()
        this.mListener?.onAdClick()
      },
      splashAdapter_didAdClose: () => {
        this.mListener?.onAdClose()
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
    super.loadStrategy()
  }

  // showAd(renderOP: AdvanceRenderOption) {
  //   super.showAd(renderOP)
  // }

  showAd(windowStage?: window.WindowStage) {
    if (!this.isAdValid()) {
      return;
    }
    if (!windowStage) {
      windowStage = BYApp.getWindowStage()
    }
    this.getCurrentAdapter()?.adapter_showAd(windowStage)
  }

  // getAdComponent(): NodeController | undefined {
  //   try {
  //     let adapter = this.getCurrentAdapter()
  //     return adapter?.adapter_getAdComponent()
  //   } catch (e) {
  //     BYLog.printE(e)
  //   }
  //   return
  // }
}