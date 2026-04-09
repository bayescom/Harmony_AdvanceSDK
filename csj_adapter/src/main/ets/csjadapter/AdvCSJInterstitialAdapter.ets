import { window } from '@kit.ArkUI';
import {
  BYLog,
  AdvanceError,
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

    } else { // 初始化失败
      this.bridge?.bridge_didAdLoadFailed(this.unitData.supplier!, new AdvanceError(initResult.code, initResult.msg))
    }
  }

  adapter_showAd(windowStage: window.WindowStage) {
    this.csj_ad?.setInteractionListener(this.interactionListener)
    this.csj_ad?.showFullAd(windowStage)
  }

  protected interactionListener: FullAdInteractionListener = {
    onShow: () => {
      BYLog.debug(TAG + "插屏回调 - onDidShow")
      this.bridge?.bridge_didAdShow(this.unitData.supplier)
    },
    onClose: () => {
      BYLog.debug(TAG + `插屏回调 - onDidClose`)
      this.bridge?.bridge_didAdClose()
    },
    onClick: () => {
      BYLog.debug(TAG + "插屏回调 - onDidClick")
      this.bridge?.bridge_didAdClick(this.unitData.supplier)
    },
    onSkip: () => {
      BYLog.debug(TAG + "插屏回调 - onDidSkip")
    },
    onComplete: () => {
      BYLog.debug(TAG + "插屏回调 - onDidComplete")
    },
  }

}