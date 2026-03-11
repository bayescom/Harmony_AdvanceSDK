import { NodeController, window } from '@kit.ArkUI';
import {
  BYLog,
  AdvanceAdnStatusResult,
  AdvanceError,
  ADV_ERR_DATA_NULL,
  AdvanceSplashCommonAdapter,
  AdvanceAdLoadState,
} from 'AdvanceSDK';
import { KSAdScene, KSAdSDK, KSSplashAd, KSSplashAdInteractListener, KSAdInteractionType,
  KSAdBuildSplashView } from 'ksadsdk';
import { AdvKSUtil } from './AdvKSUtil';


const TAG = `[AdvKSSplashAdapter]`

export class AdvKSSplashAdapter extends AdvanceSplashCommonAdapter {
  protected ks_ad?: KSSplashAd

  adapter_isAdValid(): boolean {
    return true
  }

  adapter_loadAd(): Promise<AdvanceAdnStatusResult> {
    BYLog.devDebug(TAG + ` adapter_loadAd start`)
    return new Promise<AdvanceAdnStatusResult>(async (resolve) => {
      let result = new AdvanceAdnStatusResult()
      let initResult = await AdvKSUtil.loadKSSDK(this)
      BYLog.debug(TAG + `ks初始化执行结果：${JSON.stringify(initResult)}`)

      if (initResult.success) { // 初始化成功
        //执行广告加载流程
        let sup = this.unitData.supplier
        if (sup) {
          const scene: KSAdScene = new KSAdScene()
            .setPosId(sup.adspotid)
            .setAdNum(1);
          KSAdSDK.getLoadManager().loadSplashAd(scene, {
            onRequestSuccess(splashAd: KSSplashAd) {
              // 广告请求成功
            },
            onError(code: number, msg: string) {
              // 广告请求失败
              BYLog.debug(TAG + `开屏回调 - onAdLoadFailed code: ${code} message: ${msg}`)
              result.status = AdvanceAdLoadState.failed
              result.errCode = code
              result.errMsg = msg
              resolve(result)
            },
            onAdLoad(splashAd: KSSplashAd) {
              // 广告成功加载，可以展示
              BYLog.debug(TAG + "开屏回调 - onAdLoaded")
              this.ks_ad = splashAd
              result.status = AdvanceAdLoadState.success
              resolve(result)
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
    this.ks_ad?.setInteractListener(this.interactionListener)
    KSAdBuildSplashView(this.ks_ad)
  }

  protected interactionListener: KSSplashAdInteractListener = {
    onAdShowStart() {
      BYLog.debug(TAG + "开屏回调 - onAdExposure")
      this.bridge?.splashAdapter_didAdShow()
    },
    onAdShowEnd() {},
    onAdClick(interactionType?: KSAdInteractionType) {
      BYLog.debug(TAG + "开屏回调 - onAdClick")
      this.bridge?.splashAdapter_didAdClick()
    },
    onAdSkip() {
      BYLog.debug(TAG + `开屏回调 - onAdClose`)
      this.bridge?.splashAdapter_didAdClose()
    },
    onCloseLandingPage() {}
  }

}