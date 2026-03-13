import { window } from '@kit.ArkUI';
import {
  BYLog,
  AdvanceAdnStatusResult,
  AdvanceError,
  ADV_ERR_DATA_NULL,
  AdvanceAdLoadState,
  BYApp,
  AdvanceInterstitialCommonAdapter,
} from 'AdvanceSDK';
import { MercuryCloseType, MercuryEntry, MercuryErr,
  MercuryInterstitial,
  MercuryRenderOption } from 'mercuryadhar';
import { AdvMercuryUtil } from './AdvMercuryUtil';


const TAG = `[AdvMercuryInterstitialAdapter]`

export class AdvMercuryInterstitialAdapter extends AdvanceInterstitialCommonAdapter {
  protected mercury_ad?: MercuryInterstitial

  adapter_isAdValid(): boolean {
    return true
  }

  adapter_loadAd(): Promise<AdvanceAdnStatusResult> {
    BYLog.debug(TAG + ` adapter_loadAd start`)
    return new Promise<AdvanceAdnStatusResult>(async (resolve) => {
      let result = new AdvanceAdnStatusResult()
      let initResult = await AdvMercuryUtil.loadMercurySDK(this)
      BYLog.debug(TAG + `mercury初始化执行结果：${JSON.stringify(initResult)}`)

      if (initResult.success) { // 初始化成功
        //执行广告加载流程
        let sup = this.unitData.supplier
        if (sup) {
          let opt = new MercuryEntry().setCodeId(sup.adspotid)
          this.mercury_ad = new MercuryInterstitial(opt)
          this.mercury_ad.loadAd({
            onAdLoaded: () => {
              BYLog.debug(TAG + "插屏回调 - onAdLoaded")
              result.status = AdvanceAdLoadState.success
              resolve(result)
            },
            onAdError: (err: MercuryErr): void => {
              BYLog.debug(TAG + `插屏回调 - onAdLoadFailed code: ${err.code} message: ${err.msg}`)
              result.status = AdvanceAdLoadState.failed
              result.errCode = err.code
              result.errMsg = err.msg
              resolve(result)
            },
            onMaterialCached: (isFromCache: boolean) => {},
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
    this.mercury_ad?.setRenderListener({
      onShow: (): void => {
        BYLog.debug(TAG + "插屏回调 - onAdExposure")
        this.bridge?.interstitialAdapter_didAdShow()
      },
      onClick: (): void => {
        BYLog.debug(TAG + "插屏回调 - onAdClick")
        this.bridge?.interstitialAdapter_didAdClick()
      },
      onRenderErr: (err: MercuryErr): void => {
        BYLog.debug(TAG + "插屏回调 - onShowError")
        this.bridge?.interstitialAdapter_didAdShowFailed(new AdvanceError(err.code, err.msg))
      },
      onClose: (type: MercuryCloseType): void => {
        BYLog.debug(TAG + `插屏回调 - onAdClose`)
        this.bridge?.interstitialAdapter_didAdClose()
      }
    })
    let renOp = new MercuryRenderOption()
    renOp.windowStage = BYApp.getWindowStage()
    renOp.layoutFullScreen = false
    this.mercury_ad?.showAd(renOp)
  }

}