import { AdvanceAdnInitState } from '../../../../../../Index';

export class AdvanceSetting {
  public appId: string = ""

  csj_initState: AdvanceAdnInitState = AdvanceAdnInitState.default
  gdt_initState: AdvanceAdnInitState = AdvanceAdnInitState.default
  ks_initState: AdvanceAdnInitState = AdvanceAdnInitState.default
  mercury_initState: AdvanceAdnInitState = AdvanceAdnInitState.default

  // 渠道SDK初始化与否的记录 key: channelid, value: 0 or 1
  //  public initializedMap: Record<string, number> = {}

  private static instance: AdvanceSetting;

  private constructor() {
  }

  static get(): AdvanceSetting {
    if (AdvanceSetting.instance === undefined) {
      AdvanceSetting.instance = new AdvanceSetting();
    }
    return AdvanceSetting.instance;
  }
}