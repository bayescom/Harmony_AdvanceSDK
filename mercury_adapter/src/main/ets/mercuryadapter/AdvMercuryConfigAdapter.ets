import { AdvanceCommonConfigAdapter, BYApp, BYConstant } from "advancesdk";
import { MercuryAD } from 'mercury_ad'
import { BusinessError } from "@kit.BasicServicesKit";

export class AdvMercuryConfigAdapter extends AdvanceCommonConfigAdapter {
  static initializeAdapter(appId: string, appKey: string, completion: (error: BusinessError<void> | undefined) => void): void {
    MercuryAD.initWindow(BYApp.getWindowStage())
    MercuryAD.init(BYConstant.context, appId, appKey)
    completion(undefined)
  }

  static getSDKVersion(): string {
    let version = MercuryAD.getVersion()
    return version
  }
}