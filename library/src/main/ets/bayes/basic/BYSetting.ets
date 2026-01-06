/**
 * 单例存储类--仅内部逻辑流转使用  ,"use shared" 和 Sendable 保证多线程可用
 */

"use shared"

@Sendable
export class BYSetting {
  public savedUA: string = '' //ua复用
  public savedOAID: string = '' //oaid复用
  public savedAAID: string = '' //id复用
  public savedODID: string = '' //id复用
  public savedMac: string = '' //id复用

  public isDev: boolean = false //开发者模式
  public canMock: boolean = false //mock模式
  public savedDeviceEncrypt: string = '' //单例记录加密后得设备信息，用于请求时复用
  public statusBarHeightVP: number = 0
  public navigationBarHeightVP: number = 0

  public isAppForeground :boolean = true

  private static instance: BYSetting;

  private constructor() {
  }

  static get(): BYSetting {
    if (BYSetting.instance === undefined) {
      BYSetting.instance = new BYSetting();
    }
    return BYSetting.instance;
  }
}