import { GDTAdSDK } from '@gdt/gdt-union-sdk'
import {
  BYLog,
  AdvanceCommonAdapter,
  AdvanceConstant,
  AdvanceSetting,
  AdvanceAdnInitResult,
  AdvanceADNUnitData,
  AdvanceAdType,
  BYConstant
} from 'AdvanceSDK'

import { AdvGDTSplashAdapter } from './AdvGDTSplashAdapter'
import { BusinessError } from '@kit.BasicServicesKit'

const TAG = `[AdvGDTUtil] `

export class AdvGDTUtil {
  static getGDTAdAdapter(supData: AdvanceADNUnitData): AdvanceCommonAdapter | undefined {
    switch (supData.adType) {
      case AdvanceAdType.splash:
        return new AdvGDTSplashAdapter(supData)
      // case AdvanceAdType.nativeExpress:
      //   return new AdvCsjNativeExpressAdapter(supData)
      // case AdvanceAdType.selfRender:
      //   return new AdvCsjRenderFeedAdapter(supData)
      default:
        return undefined
    }
  }

  static getGDTSDKVersion(): string {
    let version = GDTAdSDK.getSDKVersion()
    return version
  }

  static async loadGDTSDK(adapter: AdvanceCommonAdapter): Promise<AdvanceAdnInitResult> {
    return new Promise<AdvanceAdnInitResult>((resolve) => {
      let result = new AdvanceAdnInitResult()
      let hasInit = AdvanceSetting.get().initializedMap[AdvanceConstant.ADV_SDK_ID_GDT]
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
        let appID = adData.supplier.mediaid
        GDTAdSDK.init(BYConstant.context, {
          appId: appID
        })
        let v = AdvGDTUtil.getGDTSDKVersion()
        BYLog.debug(TAG + `gdt版本号：${v}`)
        GDTAdSDK.start().then((res) => {
          result.success = true
          result.code = `${res.code}`
          result.msg = res.msg
          AdvanceSetting.get().initializedMap[AdvanceConstant.ADV_SDK_ID_GDT] = 1
          resolve(result)
        }).catch((err: BusinessError) => {
          result.success = false
          result.code = `${err.code}`
          result.msg = err.message
          resolve(result)
        });
      }
    });
  }
}

