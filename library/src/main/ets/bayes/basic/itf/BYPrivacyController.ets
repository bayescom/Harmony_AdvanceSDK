import { BYLocation } from '../BYLocation'


@Sendable
export abstract class BYPrivacyController {
  /**
   * app在项目中配置权限。在适当时机申请权限，然后用户授权。
   * 1：如果isCanUseAppTrackingConsent()返回false，当sdk需要oaid时，则使用getDevOaid()返回的值。
   * 2：如果isCanUseAppTrackingConsent()返回true。当sdk需要oaid时，先去检查权限是否已经得到用户授权，如果用户已经授权则获取系统oaid。如果用户未授权，则使用getDevOaid()返回的值。
   * @returns 是否允许SDK获取系统oaid
   */
  isCanUseAppTrackingConsent(): boolean {
    return true
  }

  /**
   *
   * @returns 媒体传入的oaid
   */
  getCusOaid(): string | undefined {
    return undefined
  }


  /**
   * app在项目中配置权限。并在合适时机动态申请权限，用户授权。
   * 1：当isCanUseLocation()返回false。当sdk需要地理位置信息时，使用getTTLocation()返回的值。
   * 2：当isCanUseLocation()返回true。当sdk需要地理位置信息时，先去检查是否已经得到用户授权，如果是则获取系统地理位置信息，如果否则使用getTTLocation()返回的值。
   * @returns 是否允许SDK获取系统地理位置信息
   */
  isCanUseLocation(): boolean {
    return true
  }


  /**
   *
   * @returns 媒体传入的地理位置信息
   */
  getCusLocation(): BYLocation | undefined {
    return undefined
  }

  /**
   * 是否允许SDK使用ohos.permission.GET_WIFI_INFO权限对应的信息。
   * 返回true，如果应用申请了ohos.permission.GET_WIFI_INFO权限，sdk则可以使用
   * 返回false，sdk则不可以使用。
   * @returns
   */
  isCanUseWifiState() {
    return true
  }

  /**
   * 媒体isCanUseWifiState()返回false时，SDK使用getMacAddress()的返回值作为mac地址
   * @returns
   */
  getMacAddress(): string | undefined {
    return undefined
  }
}