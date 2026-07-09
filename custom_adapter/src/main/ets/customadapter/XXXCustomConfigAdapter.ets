import { AdvanceCommonConfigAdapter, BYConstant, BYSetting } from "advancesdk";
import { CSJAdSdk, SDKConfig, SDKConfigBuilder } from '@csj/openadsdk'
import { BusinessError } from "@kit.BasicServicesKit";

export class XXXCustomConfigAdapter extends AdvanceCommonConfigAdapter {
  static initializeAdapter(appId: string, appKey: string, completion: (error: BusinessError<void> | undefined) => void): void {
    let adConfigBuilder = new SDKConfigBuilder()
    let config: SDKConfig = adConfigBuilder
      .appId(appId)
      .appName("appName")
      .allowShowNotify(true)
      .debug(BYSetting.get().isDev)
      .build()

    CSJAdSdk.init(BYConstant.context, config)
    CSJAdSdk.start().then((res) => {
      if (res.code == 0 || res.code == 4200) {
        completion(undefined)
      } else {
        const error: BusinessError = {name: 'CustomADN', code: res.code, message: res.msg}
        completion(error)
      }
    })
  }

  static getSDKVersion(): string {
    const version = CSJAdSdk.getSDKVersion()
    return version
  }
}