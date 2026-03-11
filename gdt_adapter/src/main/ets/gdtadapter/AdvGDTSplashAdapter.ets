import { GDTAdLoadConfig, GDTAdSDK, GDTError, GDTInteractionListener, GDTSplashAd } from '@gdt/gdt-union-sdk';
import { NodeController, window } from '@kit.ArkUI';
import {
  BYLog,
  AdvanceAdnStatusResult,
  AdvanceError,
  ADV_ERR_DATA_NULL,
  AdvanceSplashCommonAdapter,
  ADV_ERR_AD_Invalid_Expired,
  AdvanceAdLoadState,
} from 'AdvanceSDK';
import { AdvGDTUtil } from './AdvGDTUtil';


const TAG = `[AdvGDTSplashAdapter]`

export class AdvGDTSplashAdapter extends AdvanceSplashCommonAdapter {
  protected gdt_ad?: GDTSplashAd

  adapter_isAdValid(): boolean {
    const isAdValid = this.gdt_ad?.isValid() ?? false
    if (!isAdValid) {
      this.bridge?.splashAdapter_didAdShowFailed(new AdvanceError(ADV_ERR_AD_Invalid_Expired, '广告展示前广告已失效过期'))
    }
    return isAdValid
  }

  adapter_loadAd(): Promise<AdvanceAdnStatusResult> {
    BYLog.devDebug(TAG + ` adapter_loadAd start`)
    return new Promise<AdvanceAdnStatusResult>(async (resolve) => {
      let result = new AdvanceAdnStatusResult()
      let initResult = await AdvGDTUtil.loadGDTSDK(this)
      BYLog.debug(TAG + `gdt初始化执行结果：${JSON.stringify(initResult)}`)

      if (initResult.success) { // 初始化成功
        //执行广告加载流程
        let sup = this.unitData.supplier
        if (sup) {
          const config: GDTAdLoadConfig = {
            posId: sup.adspotid,
            timeoutMillis: sup.timeout
          };
          GDTAdSDK.getAdLoader().loadSplashAd(config, {
            onAdLoad: (ad: GDTSplashAd): void => {
              BYLog.debug(TAG + "开屏回调 - onAdLoaded")
              this.gdt_ad = ad
              result.status = AdvanceAdLoadState.success
              resolve(result)
            },
            onError: (err: GDTError): void => {
              BYLog.debug(TAG + `开屏回调 - onAdLoadFailed code: ${err.code} message: ${err.message}`)
              result.status = AdvanceAdLoadState.failed
              result.errCode = err.code
              result.errMsg = err.message
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
    this.gdt_ad?.setInteractionListener(this.interactionListener)
    this.gdt_ad?.show(windowStage)
  }

  protected interactionListener: GDTInteractionListener = {
    onAdExposure: (): void => {
      BYLog.debug(TAG + "开屏回调 - onAdExposure")
      this.bridge?.splashAdapter_didAdShow()
    },
    onAdClick: (): void => {
      BYLog.debug(TAG + "开屏回调 - onAdClick")
      this.bridge?.splashAdapter_didAdClick()
    },
    onAdClose: (): void => {
      BYLog.debug(TAG + `开屏回调 - onAdClose`)
      this.bridge?.splashAdapter_didAdClose()
    },
    onError: (err: GDTError): void => {
      BYLog.debug(TAG + "开屏回调 - onShowError")
      this.bridge?.splashAdapter_didAdShowFailed(new AdvanceError(err.code, err.message))
    }
  }

}