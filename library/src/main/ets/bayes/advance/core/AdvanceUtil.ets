import { AdvancePrivacyController } from '../config/AdvancePrivacyController';
import { AdvanceSingleton } from './AdvanceSingleton';

export class AdvanceUtil{
  static getAdvancePrivacy():AdvancePrivacyController | undefined{
    return AdvanceSingleton.get().advancePrivacy
  }
}