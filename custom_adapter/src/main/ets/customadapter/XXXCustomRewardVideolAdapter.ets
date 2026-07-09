import { window } from '@kit.ArkUI';
import {
  BYLog,
  AdvanceError,
  AdvanceCommonRewardVideoAdapter, AdvBidWinLossResultType,
  AdvBidWinLossResult,
} from 'advancesdk';
import {
  AdSlotBuilder, CSJAdCreator, CSJAdSdk,
  CSJRewardAd,
  RewardAdInteractionListener,
} from '@csj/openadsdk';

const TAG = `[XXXCustomRewardVideoAdapter]`

export class XXXCustomRewardVideoAdapter extends AdvanceCommonRewardVideoAdapter {
  protected csj_ad?: CSJRewardAd

  adapter_isAdValid(): boolean {
    return true
  }

  adapter_loadAd() {
    //执行广告加载流程
    let spotId = this.unitData.placementId
    let mAdCreator: CSJAdCreator = CSJAdSdk.getAdCreator()
    let rewardName = this.unitData.rewardVideoModel?.rewardName ?? (this.unitData.serverRewardName ?? "")
    let rewardAmount = this.unitData.rewardVideoModel?.rewardAmount ?? (this.unitData.serverRewardCount ?? 0)
    let adSlot = new AdSlotBuilder()
      .setCodeId(spotId)
      .setUserData(this.unitData.rewardVideoModel?.userId ?? "")
      .setMediaExtra(this.unitData.rewardVideoModel?.extra ?? "")
      .setRewardName(rewardName)
      .setRewardAmount(rewardAmount)
      .build()
    mAdCreator.loadRewardAd(adSlot, {
      onAdLoaded: (rewardAd: CSJRewardAd) => {
        BYLog.debug(TAG + "激励视频回调 - onAdLoaded")
        this.csj_ad = rewardAd
        // 穿山甲变现SDK不提供ecpm获取
        this.bridge?.rewardVideo_didAdLoaded(this, 0)
      },
      onError: (code: number, message: string) => {
        BYLog.debug(TAG + `激励视频回调 - onAdLoadFailed code: ${code} message: ${message}`)
        this.bridge?.rewardVideo_didAdLoadFailed(this, new AdvanceError(code, message))
      },
      onAdCached: () => {
      }
    })
  }

  adapter_showAd(windowStage: window.WindowStage) {
    this.csj_ad?.setInteractionListener(this.interactionListener)
    this.csj_ad?.showRewardAd(windowStage)
  }

  adapter_sendNotification(result: AdvBidWinLossResult): void {
    if (result.bidResultType === AdvBidWinLossResultType.win) {
      this.csj_ad?.win(result.secondPrice)
    } else {
      this.csj_ad?.loss(result.winPrice)
    }
  }

  protected interactionListener: RewardAdInteractionListener = {
    onShow: () => {
      BYLog.debug(TAG + "激励视频回调 - onAdExposure")
      this.bridge?.rewardVideo_didAdShow(this)
    },
    onClose: () => {
      BYLog.debug(TAG + `激励视频回调 - onAdClose`)
      this.bridge?.rewardVideo_didAdClose(this)
    },
    onClick: () => {
      BYLog.debug(TAG + "激励视频回调 - onAdClick")
      this.bridge?.rewardVideo_didAdClick(this)
    },
    onSkip: () => {
      BYLog.debug(TAG + "激励视频回调 - onAdSkip")
    },
    onRewardArrived: (isVerify, rewardType, extraInfo) => {
      BYLog.debug(TAG + "激励视频回调 - onAdReward")
      this.bridge?.rewardVideo_didAdReward(this)
    },
    onComplete: () => {
      BYLog.debug(TAG + "激励视频回调 - onAdPlayEnd")
      this.bridge?.rewardVideo_didAdVideoPlayEnd(this)
    }
  }

}