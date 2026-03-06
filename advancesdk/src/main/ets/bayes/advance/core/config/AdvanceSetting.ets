import { AdvanceConstant } from '../../define/AdvanceConstant';

export class AdvanceSetting {
  public csjInitStatus: number = AdvanceConstant.ADV_ADN_INIT_DEFAULT

  // 渠道SDK初始化与否的记录 key: channelid, value: 0 or 1
  public initializedMap: Record<string, number> = {}

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