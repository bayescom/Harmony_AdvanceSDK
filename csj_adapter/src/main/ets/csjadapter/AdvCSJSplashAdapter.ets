import { window } from '@kit.ArkUI';
import {
  BYLog, BYDisplay, AdvanceError, BYApp,
  AdvanceCommonSplashAdapter,
  AdvBidWinLossResult,
  AdvBidWinLossResultType,
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

export class AdvCSJSplashAdapter extends AdvanceCommonSplashAdapter {
  protected csj_ad?: CSJSplashAd

  adapter_isAdValid(): boolean {
    return true
  }

  adapter_loadAd() {
    //执行广告加载流程
    let spotId = this.unitData.placementId
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
        this.bridge?.splash_didAdLoaded(this, 0)
      },
      onError: (code: number, message: string) => {
        BYLog.debug(TAG + `开屏回调 - onAdLoadFailed code: ${code} message: ${message}`)
        this.bridge?.splash_didAdLoadFailed(this, new AdvanceError(code, message))
      },
      onRenderSuccess: () => {
        BYLog.debug(TAG + "开屏回调 - onRenderSuccess")
      },
      onRenderFail: (code: number, message: string) => {
        BYLog.debug(TAG + "开屏回调 - onRenderFail")
        this.bridge?.splash_didAdShowFailed(this, new AdvanceError(code, message))
      },

    }, BYApp.getUIContext(), this.unitData.timeout)

    mAdCreator.loadSplashAd(param)
  }

  adapter_showAd(windowStage: window.WindowStage) {
    this.csj_ad?.setInteractionListener(this.interactionListener)
    this.csj_ad?.showSplashAd(windowStage)
  }

  adapter_sendNotification(result: AdvBidWinLossResult): void {
    if (result.bidResultType === AdvBidWinLossResultType.win) {
      this.csj_ad?.win(result.secondPrice)
    } else {
      this.csj_ad?.loss(result.winPrice)
    }
  }

  protected interactionListener: CSJSplashAdInteractionListener = {
    onDidShow: () => {
      BYLog.debug(TAG + "开屏回调 - onAdExposure")
      this.bridge?.splash_didAdShow(this)
    },
    onDidClose: (closeType: CSJSplashAdCloseType) => {
      BYLog.debug(TAG + `开屏回调 - onAdClose`)
      this.bridge?.splash_didAdClose(this)
    },
    onDidClick: () => {
      BYLog.debug(TAG + "开屏回调 - onAdClick")
      this.bridge?.splash_didAdClick(this)
    },
    onVideoDidPlayFinish: () => {
      BYLog.debug(TAG + "开屏回调 - onVideoDidPlayFinish")
    },
    onVideoDidPlayFail: () => {
      BYLog.debug(TAG + "开屏回调 - onVideoDidPlayFail")
    }
  }
}