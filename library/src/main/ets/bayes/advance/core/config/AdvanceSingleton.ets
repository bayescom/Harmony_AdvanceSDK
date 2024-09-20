import { AdvancePrivacyController } from '../../config/AdvancePrivacyController';
"use shared"

@Sendable
export class AdvanceSingleton {
  public appId: string = ""
  public advancePrivacy?: AdvancePrivacyController


  private static instance: AdvanceSingleton;

  private constructor() {
  }

  static get(): AdvanceSingleton {
    if (AdvanceSingleton.instance === undefined) {
      AdvanceSingleton.instance = new AdvanceSingleton();
    }
    return AdvanceSingleton.instance;
  }
}