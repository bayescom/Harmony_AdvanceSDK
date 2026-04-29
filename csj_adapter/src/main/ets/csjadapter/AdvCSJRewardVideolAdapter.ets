import { window } from '@kit.ArkUI';
import {
  BYLog,
  AdvanceError,
  AdvanceRewardVideoCommonAdapter,
} from 'advancesdk';
import {
  AdSlotBuilder, CSJAdCreator, CSJAdSdk,
  CSJRewardAd,
  RewardAdInteractionListener,
} from '@csj/openadsdk';

const TAG = `[AdvCSJRewardVideoAdapter]`

export class AdvCSJRewardVideoAdapter extends AdvanceRewardVideoCommonAdapter {
  protected csj_ad?: CSJRewardAd

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
    mAdCreator.loadRewardAd(adSlot, {
      onAdLoaded: (rewardAd: CSJRewardAd) => {
        BYLog.debug(TAG + "激励视频回调 - onAdLoaded")
        this.csj_ad = rewardAd
        // 穿山甲变现SDK不提供ecpm获取
        this.bridge?.bridge_didAdLoaded(this.unitData.supplier, 0)
      },
      onError: (code: number, message: string) => {
        BYLog.debug(TAG + `激励视频回调 - onAdLoadFailed code: ${code} message: ${message}`)
        this.bridge?.bridge_didAdLoadFailed(this.unitData.supplier, new AdvanceError(code, message))
      },
      onAdCached: () => {
      }
    })
  }

  adapter_showAd(windowStage: window.WindowStage) {
    this.csj_ad?.setInteractionListener(this.interactionListener)
    this.csj_ad?.showRewardAd(windowStage)
  }

  protected interactionListener: RewardAdInteractionListener = {
    onShow: () => {
      BYLog.debug(TAG + "激励视频回调 - onAdExposure")
      this.bridge?.bridge_didAdShow(this.unitData.supplier)
    },
    onClose: () => {
      BYLog.debug(TAG + `激励视频回调 - onAdClose`)
      this.bridge?.bridge_didAdClose()
    },
    onClick: () => {
      BYLog.debug(TAG + "激励视频回调 - onAdClick")
      this.bridge?.bridge_didAdClick(this.unitData.supplier)
    },
    onSkip: () => {
      BYLog.debug(TAG + "激励视频回调 - onAdSkip")
    },
    onRewardArrived: (isVerify, rewardType, extraInfo) => {
      BYLog.debug(TAG + "激励视频回调 - onAdReward")
      this.bridge?.bridge_didAdReward()
    },
    onComplete: () => {
      BYLog.debug(TAG + "激励视频回调 - onAdPlayEnd")
      this.bridge?.bridge_didAdVideoPlayEnd()
    }
  }

}