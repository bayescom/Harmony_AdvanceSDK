import { AdvanceADNUnitData } from '../model/AdvanceADNUnitData';
import { NodeController } from '@kit.ArkUI';
import { BYLog } from '../../basic/BYLog';

export abstract class AdvanceADNCommonAdapter {
  //渠道参数
  unitData: AdvanceADNUnitData

  constructor(supData: AdvanceADNUnitData) {
    this.unitData = supData
    BYLog.debug('AdvanceADNCommonAdapter init')
  }

  testAA(){
    console.info('AdvanceADNCommonAdapter testAA')

  }

  abstract loadAd(): Promise<boolean>

  abstract getAdComponent(): NodeController | undefined
}