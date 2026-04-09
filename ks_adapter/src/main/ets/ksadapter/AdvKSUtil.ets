import {
  BYLog,
  AdvanceCommonAdapter,
  AdvanceSetting,
  AdvanceAdnInitResult,
  AdvanceADNUnitData,
  AdvanceAdType,
  AdvanceAdnInitState,
  BYApp,
} from 'advancesdk'
import { AdvanceSupplierModel } from 'advancesdk/src/main/ets/bayes/advance/model/AdvanceNetModel'
import { KSAdSDK, KSAdSDKInitConfig } from 'ksadsdk'
import { AdvKSRenderFeedAdapter } from './AdvGDTRenderFeedAdapter/AdvKSRenderFeedAdapter'
import { AdvKSInterstitialAdapter } from './AdvKSInterstitialAdapter'
import { AdvKSNativeExpressAdapter } from './AdvKSNativeExpressAdapter'
import { AdvKSRewardVideoAdapter } from './AdvKSRewardVideoAdapter'
import { AdvKSSplashAdapter } from './AdvKSSplashAdapter'

const TAG = `[AdvKSUtil] `

export class AdvKSUtil {
  static getKSAdAdapter(data: AdvanceADNUnitData): AdvanceCommonAdapter | undefined {
    switch (data.adType) {
      case AdvanceAdType.splash:
        return new AdvKSSplashAdapter(data)
      case AdvanceAdType.interstitial:
        return new AdvKSInterstitialAdapter(data)
      case AdvanceAdType.rewardVideo:
        return new AdvKSRewardVideoAdapter(data)
      case AdvanceAdType.nativeExpress:
        return new AdvKSNativeExpressAdapter(data)
      case AdvanceAdType.renderFeed:
        return new AdvKSRenderFeedAdapter(data)
      default:
        return undefined
    }
  }

  static getKSSDKVersion(): string {
    let version = KSAdSDK.getSDKVersion()
    return version
  }

  static async loadKSSDK(supplier: AdvanceSupplierModel): Promise<AdvanceAdnInitResult> {
    return new Promise<AdvanceAdnInitResult>((resolve) => {
      let result = new AdvanceAdnInitResult()
      let ksState = AdvanceSetting.get().ks_initState
      if (ksState == AdvanceAdnInitState.success) {
        result.success = true
        result.code = 0
        result.msg = '已成功初始化过'
        resolve(result)
      } else if (ksState == AdvanceAdnInitState.loading) { //适用于配置多个KS广告源场景时，第一个进行初始化，后面几个需要等待第一个初始化的结果
        let totalWaitMs = 1500
        let perMs = 30
        let intervalID = setInterval(() => {
          totalWaitMs -= perMs
          let ksSuccess = AdvanceSetting.get().ks_initState == AdvanceAdnInitState.success
          let isTimeout = totalWaitMs <= 0
          BYLog.debug(TAG + ` init interval check status, isKSSuccess = ${ksSuccess} , isTimeout = ${isTimeout} `)
          if (isTimeout || ksSuccess) {
            let msg = ``
            if (ksSuccess) {
              msg = '已成功初始化过;'
            }
            if (isTimeout) {
              msg = '已等待超时;'
            }
            // 超时或成功 都进入SDK加载逻辑
            result.success = true
            result.code = 0
            result.msg = msg
            clearInterval(intervalID)
            resolve(result)
          }
        }, perMs);
      } else {
        BYLog.debug(TAG + '开始执行初始化')
        let appID = supplier.mediaid
        const initConfig: KSAdSDKInitConfig = {
          appId: appID,
        }
        KSAdSDK.init(
          initConfig,
          BYApp.getApplicationContext(),
          BYApp.getWindowStage()
        )
        let v = AdvKSUtil.getKSSDKVersion()
        BYLog.debug(TAG + `ks版本号：${v}`)
        KSAdSDK.start().then((success) => {
          result.success = success
          result.code = success ? 0 : -1
          result.msg = '初始化' + success ? "成功" : "失败"
          AdvanceSetting.get().ks_initState = success ? AdvanceAdnInitState.success : AdvanceAdnInitState.failed
          resolve(result)
        });
        // 初始化进行中
        AdvanceSetting.get().ks_initState = AdvanceAdnInitState.loading
      }
    });
  }
}