import { AdvanceADNUnitData } from './AdvanceADNUnitData';
import { NodeController } from '@kit.ArkUI';
import { BYLog } from '../../../basic/BYLog';
import { AdvanceAdnResult } from '../../model/AdvanceSendModel';
import { AdvanceRenderOption } from '../../config/AdvanceOption';
import { AdvanceBaseListener } from '../AdvanceOpenListener';

export abstract class AdvanceADNCommonAdapter {
  //渠道参数
  unitData: AdvanceADNUnitData
  appContext: Context
  baseListener?:AdvanceBaseListener

  constructor(supData: AdvanceADNUnitData, context: Context) {
    this.unitData = supData
    this.appContext = context
    BYLog.debug('AdvanceADNCommonAdapter init')
  }


  abstract loadAd(): Promise<AdvanceAdnResult>

  abstract showAd(advanceRenderOP :AdvanceRenderOption)

  abstract getAdComponent(): NodeController | undefined
}