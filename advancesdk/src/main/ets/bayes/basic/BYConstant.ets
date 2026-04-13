import { window } from '@kit.ArkUI'
import { BYPrivacyController } from './itf/BYPrivacyController'
import { common } from '@kit.AbilityKit'

export const BY_CACHE_KEY_UA = 'BY_CACHE_KEY_UA'

export const BY_CACHE_KEY_MAC = 'BY_CACHE_KEY_MAC'

export const BY_CACHE_KEY_OAID = 'BY_CACHE_KEY_OAID'

export const BY_CACHE_KEY_AAID = 'BY_CACHE_KEY_AAID'

export const BY_CACHE_KEY_ODID = 'BY_CACHE_KEY_ODID'

// export const BY_CACHE_KEY_ = 'BY_CACHE_KEY_'
// export const BY_CACHE_KEY_ = 'BY_CACHE_KEY_'
// export const BY_CACHE_KEY_ = 'BY_CACHE_KEY_'
export class BYConstant {
  static windowStage: window.WindowStage
  static context: common.UIAbilityContext
  static privacyController: BYPrivacyController | undefined = undefined
  //隐私设置
}