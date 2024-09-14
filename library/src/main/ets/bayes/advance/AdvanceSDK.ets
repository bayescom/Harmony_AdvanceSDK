import BYConstant from '../basic/BYConstant'
import { BYLifecycle } from '../basic/BYLifecycle'
import { BYSetting } from '../basic/BYSetting'
import { BYSingleton } from '../basic/BYSingleton'
import { AdvancePrivacyController } from './config/AdvancePrivacyController'
import { AdvanceSingleton } from './core/AdvanceSingleton'

export class AdvanceSDK {
  //初始化SDK
  static initSDK(context: Context, appId: string) {
    AdvanceSingleton.get().appId = appId
    BYConstant.context = context
    BYLifecycle.registerLife(context)
  }

  //调试模式
  static debug() {
    BYSingleton.get().debug = true

    // todo 移除
    BYSetting.get().isDev = true
  }

  //隐私控制开关
  static setPrivacyController(advPri: AdvancePrivacyController) {
    //聚合统一隐私设置
    AdvanceSingleton.get().advancePrivacy = advPri
    //BY基础库隐私设置
    BYSingleton.get().privacyController = advPri
  }
}