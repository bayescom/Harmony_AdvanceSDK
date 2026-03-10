import { BYConstant } from '../basic/BYConstant'
import { BYLifecycle } from '../basic/BYLifecycle'
import { BYLog } from '../basic/BYLog'
import { BYSingleton } from '../basic/BYSingleton'
import { AdvanceConstant } from './define/AdvanceConstant'
import { common, UIAbility } from '@kit.AbilityKit'
import { AdvanceSetting } from './config/AdvanceSetting'

export class AdvanceSDK {
  //初始化SDK
  static initSDK(context: Context, appId: string) {
    AdvanceSetting.get().appId = appId
    BYConstant.context = context as common.UIAbilityContext
    BYLifecycle.registerLife(context)
    BYLog.debug(`AdvanceSDK initSDK  context = ${context}`)
  }

  //调试模式
  static debug() {
    BYSingleton.get().debug = true
  }

  // //隐私控制开关
  // static setPrivacyController(advPri: AdvancePrivacyController) {
  //   //聚合统一隐私设置
  //   AdvanceSingleton.get().advancePrivacy = advPri
  //   //BY基础库隐私设置
  //   BYConstant.privacyController = advPri
  // }

  //当前版本号
  getSDKVersion(): string {
    return AdvanceConstant.ADV_SDK_VERSION_NAME
  }
}