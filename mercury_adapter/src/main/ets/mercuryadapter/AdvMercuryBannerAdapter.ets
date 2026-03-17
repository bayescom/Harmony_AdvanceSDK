import { NodeController } from '@kit.ArkUI';
import {
  BYLog,
  AdvanceAdnStatusResult,
  AdvanceError,
  ADV_ERR_DATA_NULL,
  AdvanceAdLoadState,
  AdvanceBannerCommonAdapter,
} from 'AdvanceSDK';
import { MercuryCloseType, MercuryEntry, MercuryErr,
  MercuryBanner } from 'mercuryadhar';
import { AdvMercuryUtil } from './AdvMercuryUtil';


const TAG = `[AdvMercuryBannerAdapter]`

export class AdvMercuryBannerAdapter extends AdvanceBannerCommonAdapter {
  protected mercury_ad?: MercuryBanner

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
        let width = this.unitData.ext?.vpWidth ?? 0
        let height = this.unitData.ext?.vpHeight ?? 0
        if (sup) {
          let opt = new MercuryEntry()
            .setCodeId(sup.adspotid)
            .setAdSize(width, height)
          this.mercury_ad = new MercuryBanner(opt)
          this.mercury_ad.loadAd({
            onAdLoaded: () => {
              BYLog.debug(TAG + "横幅回调 - onAdLoaded")
              this.mercury_ad?.setRenderListener({
                onShow: (): void => {
                  BYLog.debug(TAG + "横幅回调 - onAdExposure")
                  this.bridge?.bridge_didAdShow()
                },
                onClick: (): void => {
                  BYLog.debug(TAG + "横幅回调 - onAdClick")
                  this.bridge?.bridge_didAdClick()
                },
                onRenderErr: (err: MercuryErr): void => {
                  BYLog.debug(TAG + "横幅回调 - onShowError")
                  this.bridge?.bridge_didAdShowFailed(new AdvanceError(err.code, err.msg))
                },
                onClose: (type: MercuryCloseType): void => {
                  BYLog.debug(TAG + `横幅回调 - onAdClose`)
                  this.bridge?.bridge_didAdClose()
                }
              })
              result.status = AdvanceAdLoadState.success
              resolve(result)
            },
            onAdError: (err: MercuryErr): void => {
              BYLog.debug(TAG + `横幅回调 - onAdLoadFailed code: ${err.code} message: ${err.msg}`)
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

  adapter_getAdComponent(): NodeController | undefined {
    return this.mercury_ad?.getAdComponent()
  }

}