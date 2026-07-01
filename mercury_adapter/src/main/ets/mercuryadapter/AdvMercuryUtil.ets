import {
  BYLog,
  AdvanceSetting,
  AdvanceAdnInitResult,
  AdvanceAdnInitState,
  BYConstant,
  BYApp,
} from 'advancesdk'
import { AdvanceSupplierModel } from 'advancesdk/src/main/ets/bayes/advance/model/AdvanceNetModel'
import { MercuryAD } from 'mercury_ad'

const TAG = `[AdvMercuryUtil] `

export class AdvMercuryUtil {

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
        // MercuryAD.debug()
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