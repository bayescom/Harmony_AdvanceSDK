import { AdvanceADNUnitData } from './AdvanceADNUnitData';
import { NodeController, window } from '@kit.ArkUI';
import { AdvanceAdnStatusResult } from '../../model/AdvanceSendModel';

export abstract class AdvanceCommonAdapter {
  //渠道参数
  unitData: AdvanceADNUnitData

  constructor(supData: AdvanceADNUnitData) {
    this.unitData = supData
  }

  abstract adapter_isAdValid(): boolean

  abstract adapter_loadAd(): Promise<AdvanceAdnStatusResult>

  // abstract adapter_showAd(advanceRenderOP: AdvanceRenderOption)

  adapter_showAd(windowStage: window.WindowStage) {} // 默认实现

  adapter_getAdComponent(): NodeController | undefined { // for banner
    return undefined
  }

}
