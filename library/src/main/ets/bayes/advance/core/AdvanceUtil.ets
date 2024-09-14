import { BYStrUtil } from '../../basic/util/BYStrUtil';
import { AdvancePrivacyController } from '../config/AdvancePrivacyController';
import { AdvanceSingleton } from './AdvanceSingleton';
import { systemDateTime } from '@kit.BasicServicesKit';

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
}