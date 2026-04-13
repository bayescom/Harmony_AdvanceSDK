import { GDTAdSDK } from '@gdt/gdt-union-sdk'
import {
  BYLog,
  AdvanceCommonAdapter,
  AdvanceSetting,
  AdvanceAdnInitResult,
  AdvanceADNUnitData,
  AdvanceAdType,
  BYConstant,
  AdvanceAdnInitState
} from 'advancesdk'

import { BusinessError } from '@kit.BasicServicesKit'
import { AdvGDTSplashAdapter } from './AdvGDTSplashAdapter'
import { AdvGDTInterstitialAdapter } from './AdvGDTInterstitialAdapter'
import { AdvGDTRewardVideoAdapter } from './AdvGDTRewardVideoAdapter'
import { AdvGDTBannerAdapter } from './AdvGDTBannerAdapter'
import { AdvGDTNativeExpressAdapter } from './AdvGDTNativeExpressAdapter'
import { AdvGDTRenderFeedAdapter } from './AdvGDTRenderFeedAdapter/AdvGDTRenderFeedAdapter'
import { AdvanceSupplierModel } from 'advancesdk/src/main/ets/bayes/advance/model/AdvanceNetModel'

const TAG = `[AdvGDTUtil] `

export class AdvGDTUtil {
  static getGDTAdAdapter(data: AdvanceADNUnitData): AdvanceCommonAdapter | undefined {
    switch (data.adType) {
      case AdvanceAdType.splash:
        return new AdvGDTSplashAdapter(data)
      case AdvanceAdType.banner:
        return new AdvGDTBannerAdapter(data)
      case AdvanceAdType.interstitial:
        return new AdvGDTInterstitialAdapter(data)
      case AdvanceAdType.rewardVideo:
        return new AdvGDTRewardVideoAdapter(data)
      case AdvanceAdType.nativeExpress:
        return new AdvGDTNativeExpressAdapter(data)
      case AdvanceAdType.renderFeed:
        return new AdvGDTRenderFeedAdapter(data)
      default:
        return undefined
    }
  }

  static getGDTSDKVersion(): string {
    let version = GDTAdSDK.getSDKVersion()
    return version
  }

  static async loadGDTSDK(supplier: AdvanceSupplierModel): Promise<AdvanceAdnInitResult> {
    return new Promise<AdvanceAdnInitResult>((resolve) => {
      let result = new AdvanceAdnInitResult()
      let gdtState = AdvanceSetting.get().gdt_initState
      if (gdtState == AdvanceAdnInitState.success) {
        result.success = true
        result.code = 0
        result.msg = '已成功初始化过'
        resolve(result)
      } else if (gdtState == AdvanceAdnInitState.loading) { //适用于配置多个GDT广告源场景时，第一个进行初始化，后面几个需要等待第一个初始化的结果
        let totalWaitMs = 1500
        let perMs = 30
        let intervalID = setInterval(() => {
          totalWaitMs -= perMs
          let gdtSuccess = AdvanceSetting.get().gdt_initState == AdvanceAdnInitState.success
          let isTimeout = totalWaitMs <= 0
          BYLog.debug(TAG + ` init interval check status, isGDTSuccess = ${gdtSuccess} , isTimeout = ${isTimeout} `)
          if (isTimeout || gdtSuccess) {
            let msg = ``
            if (gdtSuccess) {
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
        GDTAdSDK.init(BYConstant.context, {
          appId: appID
        })
        let v = AdvGDTUtil.getGDTSDKVersion()
        BYLog.debug(TAG + `gdt版本号：${v}`)
        GDTAdSDK.start().then((res) => {
          result.success = true
          result.code = res.code
          result.msg = res.msg
          AdvanceSetting.get().gdt_initState = AdvanceAdnInitState.success
          resolve(result)
        }).catch((err: BusinessError) => {
          result.success = false
          result.code = err.code
          result.msg = err.message
          AdvanceSetting.get().gdt_initState = AdvanceAdnInitState.failed
          resolve(result)
        });
        // 初始化进行中
        AdvanceSetting.get().gdt_initState = AdvanceAdnInitState.loading
      }
    });
  }
}

