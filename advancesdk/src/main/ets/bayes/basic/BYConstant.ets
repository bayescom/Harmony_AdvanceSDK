import { window } from '@kit.ArkUI'
import { BYPrivacyController } from './itf/BYPrivacyController'
import { common } from '@kit.AbilityKit'

export class BYConstant {
  static windowStage: window.WindowStage
  static context: common.UIAbilityContext
  static privacyController: BYPrivacyController | undefined = undefined
  //隐私设置
}