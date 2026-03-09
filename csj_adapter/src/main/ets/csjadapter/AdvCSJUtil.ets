import { CSJAdSdk, SDKConfig, SDKConfigBuilder, StartResult } from '@csj/openadsdk'
import {
  BYSingleton,
  ADV_ERR_ADN_INIT_FAILED,
  BYLog,
  AdvanceCommonAdapter,
  AdvanceConstant,
  AdvanceSetting,
  AdvanceAdnInitResult,
  AdvanceADNUnitData,
  AdvanceAdType,
  BYConstant
} from 'AdvanceSDK'
import { AdvCsjNativeExpressAdapter } from './AdvCsjNativeExpressAdapter'
import { AdvCsjRenderFeedAdapter } from './AdvCsjRenderFeedAdapter'
import { AdvCsjPrivacy } from './AdvCsjPrivacy'
import { AdvCSJSplashAdapter } from './AdvCSJSplashAdapter'

const TAG = `[AdvCSJUtil] `

export class AdvCSJUtil {
  static getCSJAdAdapter(adType: AdvanceAdType, supData: AdvanceADNUnitData): AdvanceCommonAdapter | undefined {
    switch (adType) {
      case AdvanceAdType.splash:
        return new AdvCSJSplashAdapter(supData)
      case AdvanceAdType.nativeExpress:
        return new AdvCsjNativeExpressAdapter(supData)
      case AdvanceAdType.selfRender:
        return new AdvCsjRenderFeedAdapter(supData)
      default:
        return undefined
    }
  }

  static getCSJSDKVersion(): string {
    let version = CSJAdSdk.getSDKVersion()
    return version
  }

  static async loadCSJSDK(adapter: AdvanceCommonAdapter): Promise<AdvanceAdnInitResult> {
    return new Promise<AdvanceAdnInitResult>((resolve) => {
      let result = new AdvanceAdnInitResult()
      let hasInit = AdvanceSetting.get().initializedMap[AdvanceConstant.ADV_SDK_ID_CSJ]
      if (hasInit) {
        result.success = true
        result.code = '0'
        result.msg = '已成功初始化过'
        resolve(result)
        return
      }
      BYLog.debug(TAG + '开始执行初始化')
      let adData = adapter.unitData
      if (adData && adData.supplier) {
        let adConfigBuilder = new SDKConfigBuilder()
        let appID = adData.supplier.mediaid
        BYLog.debug(TAG + `穿山甲 appID = ${appID} `)
        let config: SDKConfig = adConfigBuilder
          .appId(appID)
          .appName("appName")
          .allowShowNotify(true)
          .debug(BYSingleton.get().debug)
          .build()

        CSJAdSdk.init(BYConstant.context, config)
        let v = AdvCSJUtil.getCSJSDKVersion()
        BYLog.debug(TAG + `csj版本号：${v}`)
        CSJAdSdk.start().then((res) => {
          result.success = res.code == 0
          result.code = `${res.code}`
          result.msg = res.msg
          if (res.code == 0) { // 初始化成功
            AdvanceSetting.get().initializedMap[AdvanceConstant.ADV_SDK_ID_CSJ] = 1
            resolve(result)
          } else if (res.code == 4200) { // 重复初始化
            //sdk bug: 第一次初始化先回调了4200，再回调了0；后续不会进入初始化操作走 hasInit 逻辑了
          } else { // 初始化失败
            resolve(result)
          }
        })
      }
    });
  }

}

