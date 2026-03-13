import {
  BYLog,
  AdvanceCommonAdapter,
  AdvanceSetting,
  AdvanceAdnInitResult,
  AdvanceADNUnitData,
  AdvanceAdType,
  AdvanceAdnInitState,
  BYApp,
} from 'AdvanceSDK'
import { KSAdSDK, KSAdSDKInitConfig } from 'ksadsdk'
import { AdvKSInterstitialAdapter } from './AdvKSInterstitialAdapter'
import { AdvKSSplashAdapter } from './AdvKSSplashAdapter'

const TAG = `[AdvKSUtil] `

export class AdvKSUtil {
  static getKSAdAdapter(supData: AdvanceADNUnitData): AdvanceCommonAdapter | undefined {
    switch (supData.adType) {
      case AdvanceAdType.splash:
        return new AdvKSSplashAdapter(supData)
      case AdvanceAdType.interstitial:
        return new AdvKSInterstitialAdapter(supData)
      // case AdvanceAdType.nativeExpress:
      //   return new AdvCsjNativeExpressAdapter(supData)
      // case AdvanceAdType.selfRender:
      //   return new AdvCsjRenderFeedAdapter(supData)
      default:
        return undefined
    }
  }

  static getKSSDKVersion(): string {
    let version = KSAdSDK.getSDKVersion()
    return version
  }

  static async loadKSSDK(adapter: AdvanceCommonAdapter): Promise<AdvanceAdnInitResult> {
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
        let adData = adapter.unitData
        if (adData && adData.supplier) {
          let appID = adData.supplier.mediaid
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
      }
    });
  }
}