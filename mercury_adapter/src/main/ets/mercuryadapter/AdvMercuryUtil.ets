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
} from 'advancesdk'
import { AdvanceSupplierModel } from 'advancesdk/src/main/ets/bayes/advance/model/AdvanceNetModel'
import { MercuryAD } from 'mercuryadhar'
import { AdvMercuryBannerAdapter } from './AdvMercuryBannerAdapter'
import { AdvMercuryInterstitialAdapter } from './AdvMercuryInterstitialAdapter'
import { AdvMercuryNativeExpressAdapter } from './AdvMercuryNativeExpressAdapter'
import { AdvMercuryRenderFeedAdapter } from './AdvMercuryRenderFeedAdapter/AdvMercuryRenderFeedAdapter'
import { AdvMercuryRewardVideoAdapter } from './AdvMercuryRewardVideoAdapter'
import { AdvMercurySplashAdapter } from './AdvMercurySplashAdapter'

const TAG = `[AdvMercuryUtil] `

export class AdvMercuryUtil {
  static getMercuryAdAdapter(data: AdvanceADNUnitData): AdvanceCommonAdapter | undefined {
    switch (data.adType) {
      case AdvanceAdType.splash:
        return new AdvMercurySplashAdapter(data)
      case AdvanceAdType.banner:
        return new AdvMercuryBannerAdapter(data)
      case AdvanceAdType.interstitial:
        return new AdvMercuryInterstitialAdapter(data)
      case AdvanceAdType.rewardVideo:
        return new AdvMercuryRewardVideoAdapter(data)
      case AdvanceAdType.nativeExpress:
        return new AdvMercuryNativeExpressAdapter(data)
      case AdvanceAdType.renderFeed:
        return new AdvMercuryRenderFeedAdapter(data)
      default:
        return undefined
    }
  }

  static getMercurySDKVersion(): string {
    let version = MercuryAD.getVersion()
    return version
  }

  static async loadMercurySDK(supplier: AdvanceSupplierModel): Promise<AdvanceAdnInitResult> {
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
        let appID = supplier.mediaid
        let appKey = supplier.mediakey
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
    });
  }
}