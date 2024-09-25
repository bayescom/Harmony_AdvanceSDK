import { BYPrivacyController } from './itf/BYPrivacyController';

/**
 * 可对外暴露得单例存储类
 */
"use shared"

@Sendable
export class BYSingleton {
  public debug : boolean = false
  public useHttps : boolean = false

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