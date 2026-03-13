import {
  BYLog,
  AdvanceCommonAdapter,
  AdvanceSetting,
  AdvanceAdnInitResult,
  AdvanceADNUnitData,
  AdvanceAdType,
  AdvanceAdnInitState,
  BYConstant,
  BYApp,
} from 'AdvanceSDK'
import { MercuryAD } from 'mercuryadhar'
import { AdvMercuryInterstitialAdapter } from './AdvMercuryInterstitialAdapter'
import { AdvMercurySplashAdapter } from './AdvMercurySplashAdapter'

const TAG = `[AdvMercuryUtil] `

export class AdvMercuryUtil {
  static getMercuryAdAdapter(supData: AdvanceADNUnitData): AdvanceCommonAdapter | undefined {
    switch (supData.adType) {
      case AdvanceAdType.splash:
        return new AdvMercurySplashAdapter(supData)
      case AdvanceAdType.interstitial:
        return new AdvMercuryInterstitialAdapter(supData)
      // case AdvanceAdType.nativeExpress:
      //   return new AdvCsjNativeExpressAdapter(supData)
      // case AdvanceAdType.selfRender:
      //   return new AdvCsjRenderFeedAdapter(supData)
      default:
        return undefined
    }
  }

  static getMercurySDKVersion(): string {
    let version = MercuryAD.getVersion()
    return version
  }

  static async loadMercurySDK(adapter: AdvanceCommonAdapter): Promise<AdvanceAdnInitResult> {
    return new Promise<AdvanceAdnInitResult>((resolve) => {
      let result = new AdvanceAdnInitResult()
      let mercuryState = AdvanceSetting.get().mercury_initState
      if (mercuryState == AdvanceAdnInitState.success) {
        result.success = true
        result.code = 0
        result.msg = '已成功初始化过'
        resolve(result)
      } else {
        BYLog.debug(TAG + '开始执行初始化')
        let adData = adapter.unitData
        if (adData && adData.supplier) {
          let appID = adData.supplier.mediaid
          let appKey = adData.supplier.mediakey
          let v = AdvMercuryUtil.getMercurySDKVersion()
          BYLog.debug(TAG + `mercury版本号：${v}`)
          MercuryAD.initWindow(BYApp.getWindowStage())
          MercuryAD.init(BYConstant.context, appID, appKey)
          result.success = true
          result.code = 0
          result.msg = '初始化成功'
          AdvanceSetting.get().mercury_initState = AdvanceAdnInitState.success
          resolve(result)
        }
      }
    });
  }
}