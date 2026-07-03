
export class AdvanceSetting {
  public appId: string = ""
  public useHttps : boolean = false

  private static instance: AdvanceSetting;

  static get(): AdvanceSetting {
    if (AdvanceSetting.instance === undefined) {
      AdvanceSetting.instance = new AdvanceSetting();
    }
    return AdvanceSetting.instance;
  }
}