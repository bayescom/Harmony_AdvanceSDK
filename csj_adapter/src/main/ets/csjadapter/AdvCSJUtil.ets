import { CSJAdSdk, SDKConfig, SDKConfigBuilder } from '@csj/openadsdk'
import {
  BYLog,
  AdvanceCommonAdapter,
  AdvanceSetting,
  AdvanceAdnInitResult,
  AdvanceADNUnitData,
  AdvanceAdType,
  BYConstant,
  AdvanceAdnInitState,
  BYSetting
} from 'advancesdk'
import { AdvanceSupplierModel } from 'advancesdk/src/main/ets/bayes/advance/model/AdvanceNetModel'
import { AdvCSJBannerAdapter } from './AdvCSJBannerAdapter'
import { AdvCSJInterstitialAdapter } from './AdvCSJInterstitialAdapter'
import { AdvCSJNativeExpressAdapter } from './AdvCSJNativeExpressAdapter'
import { AdvCSJRenderFeedAdapter } from './AdvCSJRenderFeedAdapter/AdvCSJRenderFeedAdapter'
import { AdvCSJRewardVideoAdapter } from './AdvCSJRewardVideolAdapter'
import { AdvCSJSplashAdapter } from './AdvCSJSplashAdapter'

const TAG = `[AdvCSJUtil] `

export class AdvCSJUtil {
  static getCSJAdAdapter(data: AdvanceADNUnitData): AdvanceCommonAdapter | undefined {
    switch (data.adType) {
      case AdvanceAdType.splash:
        return new AdvCSJSplashAdapter(data)
      case AdvanceAdType.banner:
        return new AdvCSJBannerAdapter(data)
      case AdvanceAdType.interstitial:
        return new AdvCSJInterstitialAdapter(data)
      case AdvanceAdType.rewardVideo:
        return new AdvCSJRewardVideoAdapter(data)
      case AdvanceAdType.nativeExpress:
        return new AdvCSJNativeExpressAdapter(data)
      case AdvanceAdType.renderFeed:
        return new AdvCSJRenderFeedAdapter(data)
      default:
        return undefined
    }
  }

  static getCSJSDKVersion(): string {
    let version = CSJAdSdk.getSDKVersion()
    return version
  }

  static async loadCSJSDK(supplier: AdvanceSupplierModel): Promise<AdvanceAdnInitResult> {
    return new Promise<AdvanceAdnInitResult>((resolve) => {
      let result = new AdvanceAdnInitResult()
      let csjState = AdvanceSetting.get().csj_initState
      if (csjState == AdvanceAdnInitState.success) {
        result.success = true
        result.code = 0
        result.msg = '已成功初始化过'
        resolve(result)
      } else if (csjState == AdvanceAdnInitState.loading) { //适用于配置多个CSJ广告源场景时，第一个进行初始化，后面几个需要等待第一个初始化的结果
        let totalWaitMs = 1500
        let perMs = 30
        let intervalID = setInterval(() => {
          totalWaitMs -= perMs
          let csjSuccess = AdvanceSetting.get().csj_initState == AdvanceAdnInitState.success
          let isTimeout = totalWaitMs <= 0
          BYLog.debug(TAG + ` init interval check status, isCSJSuccess = ${csjSuccess} , isTimeout = ${isTimeout} `)
          if (isTimeout || csjSuccess) {
            let msg = ``
            if (csjSuccess) {
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
        let adConfigBuilder = new SDKConfigBuilder()
        let appID = supplier.mediaid
        BYLog.debug(TAG + `穿山甲 appID = ${appID} `)
        let config: SDKConfig = adConfigBuilder
          .appId(appID)
          .appName("appName")
          .allowShowNotify(true)
          .debug(BYSetting.get().isDev)
          .build()

        CSJAdSdk.init(BYConstant.context, config)
        let v = AdvCSJUtil.getCSJSDKVersion()
        BYLog.debug(TAG + `csj版本号：${v}`)
        CSJAdSdk.start().then((res) => {
          result.code = res.code
          result.msg = res.msg
          if (res.code == 0 || res.code == 4200) {
            result.success = true
            AdvanceSetting.get().csj_initState = AdvanceAdnInitState.success
          } else {
            result.success = false
            AdvanceSetting.get().csj_initState = AdvanceAdnInitState.failed
          }
          resolve(result)
        })
        // 初始化进行中
        AdvanceSetting.get().csj_initState = AdvanceAdnInitState.loading
      }
    });
  }

}

