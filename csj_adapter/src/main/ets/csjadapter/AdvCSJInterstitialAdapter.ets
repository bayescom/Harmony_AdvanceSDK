import { window } from '@kit.ArkUI';
import {
  BYLog,
  AdvanceError,
  AdvanceCommonInterstitialAdapter, AdvBidWinLossResult,
  AdvBidWinLossResultType,
} from 'advancesdk';
import {
  AdSlotBuilder, CSJAdCreator, CSJAdSdk, CSJFullAd, FullAdInteractionListener,
} from '@csj/openadsdk';

const TAG = `[AdvCSJInterstitialAdapter]`

export class AdvCSJInterstitialAdapter extends AdvanceCommonInterstitialAdapter {
  protected csj_ad?: CSJFullAd

  adapter_isAdValid(): boolean {
    return true
  }

  adapter_loadAd() {
    //执行广告加载流程
    let spotId = this.unitData.placementId
    let mAdCreator: CSJAdCreator = CSJAdSdk.getAdCreator()
    let adSlot = new AdSlotBuilder()
      .setCodeId(spotId)
      .build()
    mAdCreator.loadFullAd(adSlot, {
      onAdLoaded: (fullAd: CSJFullAd) => {
        BYLog.debug(TAG + "插屏回调 - onAdLoaded")
        this.csj_ad = fullAd
        // 穿山甲变现SDK不提供ecpm获取
        this.bridge?.interstitial_didAdLoaded(this, 0)
      },
      onError: (code: number, message: string) => {
        BYLog.debug(TAG + `插屏回调 - onAdLoadFailed code: ${code} message: ${message}`)
        this.bridge?.interstitial_didAdLoadFailed(this, new AdvanceError(code, message))
      },
      onAdCached: (fullAd: CSJFullAd) => {
      }
    })
  }

  adapter_showAd(windowStage: window.WindowStage) {
    this.csj_ad?.setInteractionListener(this.interactionListener)
    this.csj_ad?.showFullAd(windowStage)
  }

  adapter_sendNotification(result: AdvBidWinLossResult): void {
    if (result.bidResultType === AdvBidWinLossResultType.win) {
      this.csj_ad?.win(result.secondPrice)
    } else {
      this.csj_ad?.loss(result.winPrice)
    }
  }

  protected interactionListener: FullAdInteractionListener = {
    onShow: () => {
      BYLog.debug(TAG + "插屏回调 - onAdExposure")
      this.bridge?.interstitial_didAdShow(this)
    },
    onClose: () => {
      BYLog.debug(TAG + `插屏回调 - onAdClose`)
      this.bridge?.interstitial_didAdClose(this)
    },
    onClick: () => {
      BYLog.debug(TAG + "插屏回调 - onAdClick")
      this.bridge?.interstitial_didAdClick(this)
    },
    onSkip: () => {
      BYLog.debug(TAG + "插屏回调 - onAdSkip")
    },
    onComplete: () => {
      BYLog.debug(TAG + "插屏回调 - onAdPlayEnd")
    },
  }

}