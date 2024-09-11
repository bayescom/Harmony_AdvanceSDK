import { window } from '@kit.ArkUI'
export const BY_CACHE_KEY_UA = 'BY_CACHE_KEY_UA'
export const BY_CACHE_KEY_MAC = 'BY_CACHE_KEY_MAC'
export const BY_CACHE_KEY_OAID = 'BY_CACHE_KEY_OAID'
export const BY_CACHE_KEY_AAID = 'BY_CACHE_KEY_AAID'
export const BY_CACHE_KEY_ODID = 'BY_CACHE_KEY_ODID'
// export const BY_CACHE_KEY_ = 'BY_CACHE_KEY_'
// export const BY_CACHE_KEY_ = 'BY_CACHE_KEY_'
// export const BY_CACHE_KEY_ = 'BY_CACHE_KEY_'
export default class BYConstant {
  public static readonly MERCURY_API_VERSION_NAME: string = '3.1.0'
  public static readonly MERCURY_SDK_VERSION_NAME: string = '1.0'

  static windowStage: window.WindowStage
}