import { NodeController } from '@kit.ArkUI';
import { BYLog } from '../../../basic/BYLog';
import {
  AdSlotBuilder,
  CSJAdCreator,
  CSJAdSdk,
  CSJSplashAd,
  CSJSplashAdCloseType,
  CSJSplashAdLoadParam
} from '@csj/openadsdk';
import { AdvanceAdnResult } from '../../model/AdvanceSendModel';
import { AdvCsjUtil } from './AdvCsjUtil';
import AdvanceConstant from '../../model/AdvanceConstant';
import { BYDisplay } from '../../../basic/BYDisplay';
import { AdvanceError, ADV_ERR_DATA_NULL, ADV_ERR_EXCEPTION_RENDER } from '../../model/AdvanceError';
import { AdvanceRenderOption } from '../../config/AdvanceOption';
import { AdvanceADNCommonSplashAdapter } from '../../core/adn/AdvanceADNCommonSplashAdapter';
import { AdvanceCloseType } from '../../model/AdvanceCloseType';

const TAG = `[AdvCSJSplashAdapter] `

export class AdvCSJSplashAdapter extends AdvanceADNCommonSplashAdapter {
  mSplashAd ?: CSJSplashAd

  showAd(advanceRenderOP: AdvanceRenderOption): void {
    try {
      if (this.mSplashAd) {
        BYLog.debug(TAG + `showAd ,windowStage = ${advanceRenderOP.windowStage}`)
        this.mSplashAd.showSplashAd(advanceRenderOP.windowStage, advanceRenderOP.customBottomBuilder,
          advanceRenderOP.customSkipBuilder)
      }
    } catch (e) {
      BYLog.printE(e)
      let err = e as Error
      this.callAdRenderFailed(new AdvanceError(ADV_ERR_EXCEPTION_RENDER, '展示调用异常, ' + err?.message))
    }
  }

  loadAd(): Promise<AdvanceAdnResult> {
    BYLog.devDebug(TAG + ` loadAd start`)
    return new Promise<AdvanceAdnResult>(async (resolve, reject) => {
      try {
        let result = new AdvanceAdnResult()
        let initResult = await AdvCsjUtil.canLoadAD(this)
        BYLog.debug(TAG + ` csj初始化执行结果：${JSON.stringify(initResult)}`)

        //
        if (initResult.initSucc == true) {
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
                this.mSplashAd = splashAd
                this.mSplashAd.setInteractionListener({
                  onRenderSuccess: () => {
                    BYLog.debug(TAG + "开屏回调 - onRenderSuccess")

                    this.callAdRenderSuccess()
                  },

                  onRenderFail: (code: number, message: string) => {
                    BYLog.debug(TAG + "开屏回调 - onRenderFail")

                    this.callAdRenderFailed(new AdvanceError(code, message))
                  },

                  onDidShow: () => {
                    BYLog.debug(TAG + "开屏回调 - onDidShow")

                    this.callAdShow()
                  },

                  onDidClose: (closeType: CSJSplashAdCloseType) => {
                    BYLog.debug(TAG + `开屏回调 - onDidClose 关闭原因：${closeType}`)
                    let advClose = AdvanceCloseType.UNKNOWN
                    switch (closeType) {
                      case CSJSplashAdCloseType.CLICK_SKIP:
                        advClose = AdvanceCloseType.SKIP_CLICK
                        break
                      case CSJSplashAdCloseType.COUNTDOWN_TO_ZERO:
                        advClose = AdvanceCloseType.COUNT_DOWN
                        break
                      case CSJSplashAdCloseType.CLICK_AD:
                        advClose = AdvanceCloseType.AD_CLICK
                        break
                    }
                    this.splashListener?.onClose(advClose)
                  },

                  onDidClick: () => {
                    BYLog.debug(TAG + "开屏回调 - onDidClick")

                    this.callAdClick()

                  },

                  onVideoDidPlayFinish: () => {
                    BYLog.debug(TAG + "开屏回调 - onVideoDidPlayFinish")
                  },

                  onVideoDidPlayFail: () => {
                    BYLog.debug(TAG + "开屏回调 - onVideoDidPlayFail")
                  }
                })
                result.resultStatus = AdvanceConstant.ADV_ADN_RESULT_SUCCESS
                resolve(result)
              },

              onError: (code: number, message: string) => {
                BYLog.debug(TAG + `开屏回调 - onError code: ${code} message: ${message}`)
                result.resultStatus = AdvanceConstant.ADV_ADN_RESULT_FAILED

                result.errCode = code + ''
                result.errMsg = message
                resolve(result)
              }
            }
              , sup.timeout)
            mAdCreator.loadSplashAd(param)
          } else {
            result.resultStatus = AdvanceConstant.ADV_ADN_RESULT_FAILED

            result.errCode = ADV_ERR_DATA_NULL
            result.errMsg = '未找到该adn策略信息'
            resolve(result)
          }

        } else {
          result.resultStatus = AdvanceConstant.ADV_ADN_RESULT_FAILED
          result.errCode = initResult.errCode
          result.errMsg = initResult.errMsg
          resolve(result)
        }
        // let start: number = new Date().getTime();
        // let random = Math.random()
        // let delayTime = random * 2000
        // randomResult = BYUtil.caseNumberInt(random)
        // // mock异步执行过程
        // while (new Date().getTime() - start < delayTime) {
        //   continue;
        // }
        // BYLog.devDebug(`AdvCSJSplashAdapter loadAd mock , random = ${random} ,randomResultStatus = ${randomResult} , delayTime = ` +
        //   delayTime)
      } catch (e) {
      }


    })
  }

  getAdComponent(): NodeController | undefined {
    return this.mSplashAd?.getAdComponent(false)
  }
}