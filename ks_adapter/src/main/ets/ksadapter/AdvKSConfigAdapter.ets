import { AdvanceCommonConfigAdapter, BYApp } from "advancesdk";
import { KSAdSDK, KSAdSDKInitConfig } from 'ksadsdk'
import { BusinessError } from "@kit.BasicServicesKit";

export class AdvKSConfigAdapter extends AdvanceCommonConfigAdapter {
  static initializeAdapter(appId: string, appKey: string, completion: (error: BusinessError<void> | undefined) => void): void {
    const initConfig: KSAdSDKInitConfig = {
      appId: appId,
    }
    KSAdSDK.init(
      initConfig,
      BYApp.getApplicationContext(),
      BYApp.getWindowStage()
    )
    KSAdSDK.start().then((success) => {
      completion(success? undefined : {name: 'KSSDK', code: -1, message: '初始化失败'})
    });
  }

  static getSDKVersion(): string {
    let version = KSAdSDK.getSDKVersion()
    return version
  }
}