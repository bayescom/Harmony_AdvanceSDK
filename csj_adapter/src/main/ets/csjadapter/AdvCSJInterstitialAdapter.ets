import { window } from '@kit.ArkUI';
import {
  BYLog,
  AdvanceAdnStatusResult,
  ADV_ERR_DATA_NULL,
  AdvanceAdLoadState,
  AdvanceInterstitialCommonAdapter,
} from 'advancesdk';
import {
  AdSlotBuilder, CSJAdCreator, CSJAdSdk, CSJFullAd, FullAdInteractionListener,
} from '@csj/openadsdk';
import { AdvCSJUtil } from './AdvCSJUtil';

const TAG = `[AdvCSJInterstitialAdapter]`

export class AdvCSJInterstitialAdapter extends AdvanceInterstitialCommonAdapter {
  protected csj_ad?: CSJFullAd

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
          mAdCreator.loadFullAd(adSlot, {
            onAdLoaded: (fullAd: CSJFullAd) => {
              BYLog.debug(TAG + "插屏回调 - onAdLoaded")
              this.csj_ad = fullAd
              result.status = AdvanceAdLoadState.success
              resolve(result)
            },
            onError: (code: number, message: string) => {
              BYLog.debug(TAG + `插屏回调 - onAdLoadFailed code: ${code} message: ${message}`)
              result.status = AdvanceAdLoadState.failed
              result.errCode = code
              result.errMsg = message
              resolve(result)
            },
            onAdCached: (fullAd: CSJFullAd) => {
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
    this.csj_ad?.showFullAd(windowStage)
  }

  protected interactionListener: FullAdInteractionListener = {
    onShow: () => {
      BYLog.debug(TAG + "插屏回调 - onDidShow")
      this.bridge?.bridge_didAdShow()
    },
    onClose: () => {
      BYLog.debug(TAG + `插屏回调 - onDidClose`)
      this.bridge?.bridge_didAdClose()
    },
    onClick: () => {
      BYLog.debug(TAG + "插屏回调 - onDidClick")
      this.bridge?.bridge_didAdClick()
    },
    onSkip: () => {
      BYLog.debug(TAG + "插屏回调 - onDidSkip")
    },
    onComplete: () => {
      BYLog.debug(TAG + "插屏回调 - onDidComplete")
    },
  }

}