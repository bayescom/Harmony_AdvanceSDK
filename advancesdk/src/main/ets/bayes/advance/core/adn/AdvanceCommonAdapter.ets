import { AdvanceADNUnitData } from './AdvanceADNUnitData';
import { NodeController, window } from '@kit.ArkUI';
import { AdvanceAdnStatusResult } from '../../model/AdvanceSendModel';

export abstract class AdvanceCommonAdapter {
  //渠道参数
  unitData: AdvanceADNUnitData

  constructor(supData: AdvanceADNUnitData) {
    this.unitData = supData
  }

  abstract adapter_loadAd(): Promise<AdvanceAdnStatusResult>

  // abstract adapter_showAd(advanceRenderOP: AdvanceRenderOption)

  adapter_showAd(windowStage: window.WindowStage) {} // 默认实现

  adapter_isAdValid(): boolean {
    return false
  }

  adapter_getAdComponent(): NodeController | undefined { // for banner & native express
    return undefined
  }

  adapter_render(context: UIContext) {} // for banner & native express

}
