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
import { AdvCSJUtil } from './AdvCSJUtil';

const TAG = `[AdvCSJRewardVideoAdapter]`

export class AdvCSJRewardVideoAdapter extends AdvanceRewardVideoCommonAdapter {
  protected csj_ad?: CSJRewardAd

  adapter_isAdValid(): boolean {
    return true
  }

  async adapter_loadAd() {
    let initResult = await AdvCSJUtil.loadCSJSDK(this)
    BYLog.debug(TAG + ` csj初始化执行结果：${JSON.stringify(initResult)}`)

    if (initResult.success) { // 初始化成功
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

    } else { // 初始化失败
      this.bridge?.bridge_didAdLoadFailed(this.unitData.supplier!, new AdvanceError(initResult.code, initResult.msg))
    }
  }

  adapter_showAd(windowStage: window.WindowStage) {
    this.csj_ad?.setInteractionListener(this.interactionListener)
    this.csj_ad?.showRewardAd(windowStage)
  }

  protected interactionListener: RewardAdInteractionListener = {
    onShow: () => {
      BYLog.debug(TAG + "激励视频回调 - onDidShow")
      this.bridge?.bridge_didAdShow(this.unitData.supplier)
    },
    onClose: () => {
      BYLog.debug(TAG + `激励视频回调 - onDidClose`)
      this.bridge?.bridge_didAdClose()
    },
    onClick: () => {
      BYLog.debug(TAG + "激励视频回调 - onDidClick")
      this.bridge?.bridge_didAdClick(this.unitData.supplier)
    },
    onSkip: () => {
      BYLog.debug(TAG + "激励视频回调 - onDidSkip")
    },
    onRewardArrived: (isVerify, rewardType, extraInfo) => {
      BYLog.debug(TAG + "激励视频回调 - onDidReward")
      this.bridge?.bridge_didAdReward()
    },
    onComplete: () => {
      BYLog.debug(TAG + "激励视频回调 - onDidComplete")
      this.bridge?.bridge_didAdVideoPlayEnd()
    }
  }

}