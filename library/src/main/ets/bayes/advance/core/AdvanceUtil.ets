import { BYStrUtil } from '../../basic/util/BYStrUtil';
import { AdvancePrivacyController } from '../config/AdvancePrivacyController';
import { AdvanceSingleton } from './AdvanceSingleton';
import { systemDateTime } from '@kit.BasicServicesKit';
import { AdvanceSupplierModel } from '../model/AdvanceNetModel';
import { AdvanceSupplier } from '../model/AdvanceSupplier';
import { AdvanceError } from '../model/AdvanceError';

export class AdvanceUtil {
  static getAdvancePrivacy(): AdvancePrivacyController | undefined {
    return AdvanceSingleton.get().advancePrivacy
  }

  static getTimeReplacedTk(ori: string): string {
    try {
      let current: number = systemDateTime.getTime()
      return BYStrUtil.replaceAll(ori, "__TIME__", `${current}`)
    } catch (e) {
      return ori
    }
  }

  static caseSupplier(inSup: AdvanceSupplierModel): AdvanceSupplier {
    let result = new AdvanceSupplier()
    if (inSup) {
      result.adnID = inSup.id
      result.adnName = inSup.name
      result.appID = inSup.mediaid
      result.adSlotID = inSup.adspotid
      result.price = inSup.sdk_price
    }
    return result

  }

  static appendFailedReason(ori: string, err: AdvanceError): string {
    try {
      let extErr = `&t_msg=err_${err?.code}`
      return ori + extErr
    } catch (e) {
      return ori
    }
  }
}