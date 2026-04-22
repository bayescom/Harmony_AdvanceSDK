import { window } from '@kit.ArkUI';
import {
  BYLog, BYDisplay, AdvanceError, AdvanceSplashCommonAdapter, BYApp,
} from 'advancesdk';
import {
  AdSlotBuilder,
  CSJAdCreator,
  CSJAdSdk,
  CSJSplashAd,
  CSJSplashAdCloseType,
  CSJSplashAdInteractionListener,
  CSJSplashAdLoadParam
} from '@csj/openadsdk';

const TAG = `[AdvCSJSplashAdapter]`

export class AdvCSJSplashAdapter extends AdvanceSplashCommonAdapter {
  protected csj_ad?: CSJSplashAd

  adapter_isAdValid(): boolean {
    return true
  }

  adapter_loadAd() {
    //执行广告加载流程
    let spotId = this.unitData.supplier.adspotid
    let w = this.unitData.vpWidth ?? 0
    let h = this.unitData.vpHeight ?? 0

    //未配置的话取屏幕宽高
    if (w <= 0) {
      w = BYDisplay.px2VP(BYDisplay.getScreenWPX())
    }
    if (h <= 0) {
      h = BYDisplay.px2VP(BYDisplay.getScreenHPX())
    }
    let mAdCreator: CSJAdCreator = CSJAdSdk.getAdCreator()

    let adSlot = new AdSlotBuilder()
      .setCodeId(spotId)
      .setAcceptSize(w, h)
      .build()

    let param = new CSJSplashAdLoadParam(adSlot, {
      onAdLoaded: (splashAd: CSJSplashAd) => {
        BYLog.debug(TAG + "开屏回调 - onAdLoaded")
        this.csj_ad = splashAd
        // 穿山甲变现SDK不提供ecpm获取
        this.bridge?.bridge_didAdLoaded(this.unitData.supplier, 0)
      },
      onError: (code: number, message: string) => {
        BYLog.debug(TAG + `开屏回调 - onAdLoadFailed code: ${code} message: ${message}`)
        this.bridge?.bridge_didAdLoadFailed(this.unitData.supplier, new AdvanceError(code, message))
      },
      onRenderSuccess: () => {
        BYLog.debug(TAG + "开屏回调 - onRenderSuccess")
      },
      onRenderFail: (code: number, message: string) => {
        BYLog.debug(TAG + "开屏回调 - onRenderFail")
        this.bridge?.bridge_didAdShowFailed(this.unitData.supplier, new AdvanceError(code, message))
      },

    }, BYApp.getUIContext(), this.unitData.supplier.timeout)

    mAdCreator.loadSplashAd(param)
  }

  adapter_showAd(windowStage: window.WindowStage) {
    this.csj_ad?.setInteractionListener(this.interactionListener)
    this.csj_ad?.showSplashAd(windowStage)
  }

  protected interactionListener: CSJSplashAdInteractionListener = {
    onDidShow: () => {
      BYLog.debug(TAG + "开屏回调 - onDidShow")
      this.bridge?.bridge_didAdShow(this.unitData.supplier)
    },
    onDidClose: (closeType: CSJSplashAdCloseType) => {
      BYLog.debug(TAG + `开屏回调 - onDidClose`)
      this.bridge?.bridge_didAdClose()
    },
    onDidClick: () => {
      BYLog.debug(TAG + "开屏回调 - onDidClick")
      this.bridge?.bridge_didAdClick(this.unitData.supplier)
    },
    onVideoDidPlayFinish: () => {
      BYLog.debug(TAG + "开屏回调 - onVideoDidPlayFinish")
    },
    onVideoDidPlayFail: () => {
      BYLog.debug(TAG + "开屏回调 - onVideoDidPlayFail")
    }
  }
}