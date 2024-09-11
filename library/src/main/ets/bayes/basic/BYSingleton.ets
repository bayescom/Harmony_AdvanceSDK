import { Context } from '@kit.AbilityKit';
import { BYPrivacyController } from './itf/BYPrivacyController';

/**
 * 可对外暴露得单例存储类
 */
export class BYSingleton {
  public context?: Context
  public debug : boolean = false
  public useHttps : boolean = false
  public privacyController : BYPrivacyController | undefined = undefined //隐私设置

  private static instance: BYSingleton;

  private constructor() {
  }

  static get(): BYSingleton {
    if (BYSingleton.instance === undefined) {
      BYSingleton.instance = new BYSingleton();
    }
    return BYSingleton.instance;
  }
}