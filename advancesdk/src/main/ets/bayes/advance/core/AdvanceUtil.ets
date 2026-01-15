import { BYStrUtil } from '../../basic/util/BYStrUtil';
import { AdvancePrivacyController } from '../config/AdvancePrivacyController';
import { AdvanceSingleton } from './config/AdvanceSingleton';
import { systemDateTime } from '@kit.BasicServicesKit';
import { AdvanceSupplierModel } from '../model/AdvanceNetModel';
import { AdvanceSupplier } from '../model/AdvanceSupplier';
import { AdvanceError } from '../define/AdvanceError';
import { window } from '@kit.ArkUI';
import { AdvanceRenderOption } from '../config/AdvanceOption';
import BYConstant from '../../basic/BYConstant';
import { BYLog } from '../../basic/BYLog';

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

  static getWindowStage(advanceRenderOP: AdvanceRenderOption): window.WindowStage |undefined{
    let result : window.WindowStage |undefined = undefined
    try {
      if (advanceRenderOP) {
        result = advanceRenderOP.windowStage
      }
      //尝试使用基础库中获取到的窗口实例
      if (!result) {
        result = BYConstant.windowStage
      }
    } catch (e) {
      BYLog.printE(e)
    }
    return result
  }
}