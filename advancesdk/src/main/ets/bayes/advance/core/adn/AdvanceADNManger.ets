import { AdvanceADNUnitData } from './AdvanceADNUnitData'
import { AdvanceConstant } from '../../model/AdvanceConstant'
import { AdvanceADNCommonAdapter } from './AdvanceADNCommonAdapter'

export class AdvanceADNManger {
  //生成对应adapter实现类
  static async generateAdnAdapter(adnData: AdvanceADNUnitData, context: Context): Promise<AdvanceADNCommonAdapter | undefined> {
    let result: AdvanceADNCommonAdapter | undefined = undefined
    let sdkId = adnData.supplier?.id
    switch (sdkId) {
      case AdvanceConstant.ADV_SDK_ID_CSJ:{ // 穿山甲
        const harName = 'CSJAdapter';
        const ns: ESObject = await import(harName);
        result = ns.AdvCsjUtil.getCsjAdAdapter(adnData.adType, adnData, context.getApplicationContext())
        return result
      }
      default:
        return result
    }
  }
}