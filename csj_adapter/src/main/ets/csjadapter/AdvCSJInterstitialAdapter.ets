import { window } from '@kit.ArkUI';
import {
  BYLog,
  AdvanceError,
  AdvanceInterstitialCommonAdapter,
} from 'advancesdk';
import {
  AdSlotBuilder, CSJAdCreator, CSJAdSdk, CSJFullAd, FullAdInteractionListener,
} from '@csj/openadsdk';

const TAG = `[AdvCSJInterstitialAdapter]`

export class AdvCSJInterstitialAdapter extends AdvanceInterstitialCommonAdapter {
  protected csj_ad?: CSJFullAd

  adapter_isAdValid(): boolean {
    return true
  }

  adapter_loadAd() {
    //执行广告加载流程
    let spotId = this.unitData.supplier.adspotid
    let mAdCreator: CSJAdCreator = CSJAdSdk.getAdCreator()
    let adSlot = new AdSlotBuilder()
      .setCodeId(spotId)
      .build()
    mAdCreator.loadFullAd(adSlot, {
      onAdLoaded: (fullAd: CSJFullAd) => {
        BYLog.debug(TAG + "插屏回调 - onAdLoaded")
        this.csj_ad = fullAd
        // 穿山甲变现SDK不提供ecpm获取
        this.bridge?.bridge_didAdLoaded(this.unitData.supplier, 0)
      },
      onError: (code: number, message: string) => {
        BYLog.debug(TAG + `插屏回调 - onAdLoadFailed code: ${code} message: ${message}`)
        this.bridge?.bridge_didAdLoadFailed(this.unitData.supplier, new AdvanceError(code, message))
      },
      onAdCached: (fullAd: CSJFullAd) => {
      }
    })
  }

  adapter_showAd(windowStage: window.WindowStage) {
    this.csj_ad?.setInteractionListener(this.interactionListener)
    this.csj_ad?.showFullAd(windowStage)
  }

  protected interactionListener: FullAdInteractionListener = {
    onShow: () => {
      BYLog.debug(TAG + "插屏回调 - onAdExposure")
      this.bridge?.bridge_didAdShow(this.unitData.supplier)
    },
    onClose: () => {
      BYLog.debug(TAG + `插屏回调 - onAdClose`)
      this.bridge?.bridge_didAdClose()
    },
    onClick: () => {
      BYLog.debug(TAG + "插屏回调 - onAdClick")
      this.bridge?.bridge_didAdClick(this.unitData.supplier)
    },
    onSkip: () => {
      BYLog.debug(TAG + "插屏回调 - onAdSkip")
    },
    onComplete: () => {
      BYLog.debug(TAG + "插屏回调 - onAdPlayEnd")
    },
  }

}