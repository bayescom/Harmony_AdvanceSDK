import AdvanceConstant from '../../model/AdvanceConstant';

export class AdvanceSetting {
  public csjInitStatus: number = AdvanceConstant.ADV_ADN_INIT_DEFAULT // -1 默认状态。-2 初始化失败 ;0 请求发起中  1.成功请求 ，  ；状态为0、1时不可重复发起，等待状态变更后再执行


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