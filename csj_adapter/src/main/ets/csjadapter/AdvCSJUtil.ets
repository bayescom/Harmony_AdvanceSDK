import { CSJAdSdk, SDKConfig, SDKConfigBuilder, StartResult } from '@csj/openadsdk'
import {
  AdvanceUtil,
  BYSingleton,
  ADV_ERR_ADN_INIT_FAILED,
  BYLog,
  BYApp,
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
  static getCSJAdAdapter(adType: AdvanceAdType, supData: AdvanceADNUnitData) {
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

  static loadCSJSDK(adapter: AdvanceCommonAdapter): Promise<AdvanceAdnInitResult> {
    return new Promise<AdvanceAdnInitResult>(async (resolve) => {
      let csjInitResult = await AdvCSJUtil.init(adapter)
      let result = new AdvanceAdnInitResult()
      // 0 成功。4200 重复初始化
      if (csjInitResult.code == 0 || csjInitResult.code == 4200) {
        result.initSuccess = true
        AdvanceSetting.get().csjInitStatus = AdvanceConstant.ADV_ADN_INIT_SUCCESS
      } else {
        AdvanceSetting.get().csjInitStatus = AdvanceConstant.ADV_ADN_INIT_FAILED
      }
      result.code = csjInitResult.code + ''
      result.msg = csjInitResult.msg
      resolve(result)
    });

  }

  static init(adapter: AdvanceCommonAdapter): Promise<StartResult> {
    return new Promise<StartResult>((resolve) => {
      let defaultErr = '未知错误'

      try {
        let csjStatus = AdvanceSetting.get().csjInitStatus
        //请求中需等待，防止多次调用执行异常
        if (csjStatus == AdvanceConstant.ADV_ADN_INIT_LOADING) {
          try { //间隔 Nms 执行一次检查SDK回调状态
            let totalWaitMs = 1500
            let perMs = 30
            let intervalID = setInterval(() => {
              totalWaitMs -= perMs

              let isCsjSucc = AdvanceSetting.get().csjInitStatus == AdvanceConstant.ADV_ADN_INIT_SUCCESS
              let isTimeout = totalWaitMs <= 0
              BYLog.debug(TAG + ` init interval check status, isCsjSucc = ${isCsjSucc} , isTimeout = ${isTimeout} `)
              if (isTimeout || isCsjSucc) {
                let msg = ``
                if (isCsjSucc) {
                  msg += '已成功初始化过;'
                }

                if (isTimeout) {
                  msg += '已等待超时;'
                }

                // 超时或成功 都进入SDK加载逻辑
                let result = new StartResult(0, msg)
                clearInterval(intervalID)
                resolve(result)

              }
            }, perMs);
          } catch (e) {
          }

          return
        } else if (csjStatus == AdvanceConstant.ADV_ADN_INIT_SUCCESS) {
          let result = new StartResult(0, '已成功初始化过')
          resolve(result)
          return
        } else {
          BYLog.debug(TAG + `开始执行初始化 ， csjStatus = ${csjStatus}`)
        }
        let adData = adapter.unitData
        if (adData && adData.supplier) {
          let adConfigBuilder = new SDKConfigBuilder()
          let appID = adData.supplier.mediaid
          BYLog.debug(TAG + `穿山甲 appID = ${appID} `)
          let configBuilder: SDKConfigBuilder = adConfigBuilder
            .appId(appID)
            .appName("appName")
            .allowShowNotify(true)
            .debug(BYSingleton.get().debug)

          let advPrivacy = AdvanceUtil.getAdvancePrivacy()
          if (advPrivacy) {
            let csjPrivacy = new AdvCsjPrivacy(advPrivacy)
            configBuilder.customController(csjPrivacy)
          }

          let config: SDKConfig = configBuilder.build()
          CSJAdSdk.init(BYConstant.context, config)

          let csjResult = CSJAdSdk.start()
          //代表请求中
          AdvanceSetting.get().csjInitStatus = AdvanceConstant.ADV_ADN_INIT_LOADING
          resolve(csjResult)
          return
        }
      } catch (e) {
        BYLog.printE(e)
        defaultErr = `初始化执行异常`
      }

      let result = new StartResult(Number(ADV_ERR_ADN_INIT_FAILED), defaultErr)
      resolve(result)
    })
  }


  // static setAcceptWH(builder: AdSlotBuilder, adapter: AdvanceADNCommonAdapter) {
  //   if (adapter) {
  //     let w = adapter.unitData.ext?.vpWidth ?? 0
  //     let h = adapter.unitData.ext?.vpHeight ?? 0
  //
  //     //默认取屏幕宽高
  //     if (w <= 0) {
  //       w = BYDisplay.px2VP(BYDisplay.getScreenWPX())
  //     }
  //     if (h <= 0) {
  //       h = BYDisplay.px2VP(BYDisplay.getScreenHPX())
  //     }
  //     builder.setAcceptSize(w, h)
  //   }
  // }
}

