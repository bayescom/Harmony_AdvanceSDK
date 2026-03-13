import { BYConstant } from '../basic/BYConstant'
import { BYLifecycle } from '../basic/BYLifecycle'
import { BYLog } from '../basic/BYLog'
import { AdvanceConstant } from './define/AdvanceConstant'
import { common, UIAbility } from '@kit.AbilityKit'
import { AdvanceSetting } from './config/AdvanceSetting'
import { BYSetting } from '../../../../../Index'

export class AdvanceSDK {
  //初始化SDK
  static initSDK(context: Context, appId: string) {
    AdvanceSetting.get().appId = appId
    BYConstant.context = context as common.UIAbilityContext
    BYLifecycle.registerLife(context)
  }

  //调试模式
  static debug() {
    BYSetting.get().isDev = true
    BYLog.setShowLog(true)
  }

  //使用https
  static useHttps() {
    AdvanceSetting.get().useHttps = true
  }

  //当前版本号
  static getSDKVersion(): string {
    return AdvanceConstant.ADV_SDK_VERSION_NAME
  }
}