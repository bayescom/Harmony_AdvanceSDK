import { AdvanceADNUnitData } from '../model/AdvanceADNUnitData';
import { NodeController } from '@kit.ArkUI';
import { BYLog } from '../../basic/BYLog';
import { AdvanceAdnResult } from '../model/AdvanceSendModel';

export abstract class AdvanceADNCommonAdapter {
  //渠道参数
  unitData: AdvanceADNUnitData

  constructor(supData: AdvanceADNUnitData) {
    this.unitData = supData
    BYLog.debug('AdvanceADNCommonAdapter init')
  }

  abstract loadAd(): Promise<AdvanceAdnResult>

  abstract getAdComponent(): NodeController | undefined
}