import { AdvanceADNUnitData } from '../model/AdvanceADNUnitData';
import { NodeController } from '@kit.ArkUI';

export abstract class AdvanceADNCommonAdapter {
  //渠道参数
  unitData: AdvanceADNUnitData

  constructor(supData: AdvanceADNUnitData) {
    this.unitData = supData
  //   todo report loaded tk
  }


  abstract getAdComponent() : NodeController | undefined
}