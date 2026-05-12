/**
 * 单例存储类--仅内部逻辑流转使用  ,"use shared" 和 Sendable 保证多线程可用
 */

"use shared"

@Sendable
export class BYSetting {
  public isDev: boolean = false //开发者模式
  public canMock: boolean = false //mock模式
  public statusBarHeightVP: number = 0
  public navigationBarHeightVP: number = 0
  public isAppForeground :boolean = true

  private static instance: BYSetting;

  static get(): BYSetting {
    if (BYSetting.instance === undefined) {
      BYSetting.instance = new BYSetting();
    }
    return BYSetting.instance;
  }
}