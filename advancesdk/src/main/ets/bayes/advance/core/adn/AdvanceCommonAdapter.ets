import { AdvanceADNUnitData } from './AdvanceADNUnitData';
import { NodeController, window } from '@kit.ArkUI';

export abstract class AdvanceCommonAdapter {
  //渠道参数
  unitData: AdvanceADNUnitData

  constructor(unitData: AdvanceADNUnitData) {
    this.unitData = unitData
  }

  abstract adapter_loadAd()

  adapter_showAd(windowStage: window.WindowStage) {} // 默认实现

  adapter_isAdValid(): boolean {
    return true
  }

  adapter_getAdComponent(): NodeController | undefined { // for banner & native express
    return undefined
  }

  adapter_render(context: UIContext) {} // for banner & native express & render feed

}
