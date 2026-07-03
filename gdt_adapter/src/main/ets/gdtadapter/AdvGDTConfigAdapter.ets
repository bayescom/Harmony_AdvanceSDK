import { AdvanceCommonConfigAdapter, BYConstant } from "advancesdk";
import { GDTAdSDK } from '@gdt/gdt-union-sdk'
import { BusinessError } from "@kit.BasicServicesKit";

export class AdvGDTConfigAdapter extends AdvanceCommonConfigAdapter {
  static initializeAdapter(appId: string, appKey: string, completion: (error: BusinessError<void> | undefined) => void): void {
    GDTAdSDK.init(BYConstant.context, {
      appId: appId
    })
    GDTAdSDK.start().then((res) => {
      completion(undefined)
    }).catch((err: BusinessError) => {
      completion(err)
    });
  }

  static getSDKVersion(): string {
    let version = GDTAdSDK.getSDKVersion()
    return version
  }
}