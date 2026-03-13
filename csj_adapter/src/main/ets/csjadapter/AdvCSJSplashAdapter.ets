import { window } from '@kit.ArkUI';
import {
  BYLog,
  AdvanceAdnStatusResult,
  BYDisplay,
  AdvanceError,
  ADV_ERR_DATA_NULL,
  AdvanceSplashCommonAdapter,
  BYApp,
  AdvanceAdLoadState,
} from 'AdvanceSDK';
import {
  AdSlotBuilder,
  CSJAdCreator,
  CSJAdSdk,
  CSJSplashAd,
  CSJSplashAdCloseType,
  CSJSplashAdInteractionListener,
  CSJSplashAdLoadParam
} from '@csj/openadsdk';
import { AdvCSJUtil } from './AdvCSJUtil';

const TAG = `[AdvCSJSplashAdapter]`

export class AdvCSJSplashAdapter extends AdvanceSplashCommonAdapter {
  protected csj_ad?: CSJSplashAd

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

        let w = this.unitData.ext?.vpWidth ?? 0
        let h = this.unitData.ext?.vpHeight ?? 0

        //未配置的话取屏幕宽高
        if (w <= 0) {
          w = BYDisplay.px2VP(BYDisplay.getScreenWPX())
        }
        if (h <= 0) {
          h = BYDisplay.px2VP(BYDisplay.getScreenHPX())
        }
        let mAdCreator: CSJAdCreator = CSJAdSdk.getAdCreator()

        if (sup) {
          let adSlot = new AdSlotBuilder()
            .setCodeId(sup.adspotid)
            .setAcceptSize(w, h)
            .build()

          let param = new CSJSplashAdLoadParam(adSlot, {
            onAdLoaded: (splashAd: CSJSplashAd) => {
              BYLog.debug(TAG + "开屏回调 - onAdLoaded")
              this.csj_ad = splashAd
              result.status = AdvanceAdLoadState.success
              resolve(result)
            },
            onError: (code: number, message: string) => {
              BYLog.debug(TAG + `开屏回调 - onAdLoadFailed code: ${code} message: ${message}`)
              result.status = AdvanceAdLoadState.failed
              result.errCode = code
              result.errMsg = message
              resolve(result)
            },
            onRenderSuccess: () => {
              BYLog.debug(TAG + "开屏回调 - onRenderSuccess")
            },
            onRenderFail: (code: number, message: string) => {
              BYLog.debug(TAG + "开屏回调 - onRenderFail")
              this.bridge?.splashAdapter_didAdShowFailed(new AdvanceError(code, message))
            },

          }, BYApp.getUIContext(), sup.timeout)

          mAdCreator.loadSplashAd(param)

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
    this.csj_ad?.showSplashAd(windowStage)
  }

  protected interactionListener: CSJSplashAdInteractionListener = {
    onDidShow: () => {
      BYLog.debug(TAG + "开屏回调 - onDidShow")
      this.bridge?.splashAdapter_didAdShow()
    },
    onDidClose: (closeType: CSJSplashAdCloseType) => {
      BYLog.debug(TAG + `开屏回调 - onDidClose 关闭原因：${closeType}`)
      this.bridge?.splashAdapter_didAdClose()
    },
    onDidClick: () => {
      BYLog.debug(TAG + "开屏回调 - onDidClick")
      this.bridge?.splashAdapter_didAdClick()
    },
    onVideoDidPlayFinish: () => {
      BYLog.debug(TAG + "开屏回调 - onVideoDidPlayFinish")
    },
    onVideoDidPlayFail: () => {
      BYLog.debug(TAG + "开屏回调 - onVideoDidPlayFail")
    },
  }

}