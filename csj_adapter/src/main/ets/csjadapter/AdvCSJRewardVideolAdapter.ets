import { window } from '@kit.ArkUI';
import {
  BYLog,
  AdvanceAdnStatusResult,
  ADV_ERR_DATA_NULL,
  AdvanceAdLoadState,
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

  adapter_loadAd(): Promise<AdvanceAdnStatusResult> {
    BYLog.debug(TAG + ` adapter_loadAd start`)
    return new Promise<AdvanceAdnStatusResult>(async (resolve) => {
      let result = new AdvanceAdnStatusResult()
      let initResult = await AdvCSJUtil.loadCSJSDK(this)
      BYLog.debug(TAG + ` csj初始化执行结果：${JSON.stringify(initResult)}`)

      if (initResult.success) { // 初始化成功
        //执行广告加载流程
        let sup = this.unitData.supplier
        let mAdCreator: CSJAdCreator = CSJAdSdk.getAdCreator()

        if (sup) {
          let adSlot = new AdSlotBuilder()
            .setCodeId(sup.adspotid)
            .build()
          mAdCreator.loadRewardAd(adSlot, {
            onAdLoaded: (rewardAd: CSJRewardAd) => {
              BYLog.debug(TAG + "激励视频回调 - onAdLoaded")
              this.csj_ad = rewardAd
              result.status = AdvanceAdLoadState.success
              resolve(result)
            },
            onError: (code: number, message: string) => {
              BYLog.debug(TAG + `激励视频回调 - onAdLoadFailed code: ${code} message: ${message}`)
              result.status = AdvanceAdLoadState.failed
              result.errCode = code
              result.errMsg = message
              resolve(result)
            },
            onAdCached: () => {
            }
          })

        } else {
          result.status = AdvanceAdLoadState.failed
          result.errCode = ADV_ERR_DATA_NULL
          result.errMsg = '未找到该adn策略信息'
          resolve(result)
        }

      } else { // 初始化失败
        result.status = AdvanceAdLoadState.failed
        result.errCode = initResult.code
        result.errMsg = initResult.msg
        resolve(result)
      }
    })
  }

  adapter_showAd(windowStage: window.WindowStage) {
    this.csj_ad?.setInteractionListener(this.interactionListener)
    this.csj_ad?.showRewardAd(windowStage)
  }

  protected interactionListener: RewardAdInteractionListener = {
    onShow: () => {
      BYLog.debug(TAG + "激励视频回调 - onDidShow")
      this.bridge?.bridge_didAdShow()
    },
    onClose: () => {
      BYLog.debug(TAG + `激励视频回调 - onDidClose`)
      this.bridge?.bridge_didAdClose()
    },
    onClick: () => {
      BYLog.debug(TAG + "激励视频回调 - onDidClick")
      this.bridge?.bridge_didAdClick()
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
      this.bridge?.bridge_didAdPlayEnd()
    }
  }

}