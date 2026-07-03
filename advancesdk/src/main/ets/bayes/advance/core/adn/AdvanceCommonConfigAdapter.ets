import { BusinessError } from "@kit.BasicServicesKit";

export abstract class AdvanceCommonConfigAdapter {
  // adn初始化方法
  static initializeAdapter(appId: string, appKey: string, completion: (error: BusinessError | undefined) => void) {
    // 如果子类未覆写，则由基类回调错误信息
    // 一般只有自定义ADN才会进入基类实现
    const error: BusinessError = {name: 'CustomADN', code: -100, message: '自定义ADN未遵循初始化协议'}
    completion(error)
  }

  // adn的版本号
  static getSDKVersion(): string {
    return ''
  }

}