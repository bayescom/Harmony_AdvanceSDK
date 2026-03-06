import { AdvanceADNUnitData } from './AdvanceADNUnitData'
import { AdvanceConstant } from '../../define/AdvanceConstant'
import { AdvanceCommonAdapter } from './AdvanceCommonAdapter'

export class AdvanceADNManger {
  //生成对应adapter实现类
  static async generateAdnAdapter(adnData: AdvanceADNUnitData, context: Context): Promise<AdvanceCommonAdapter | undefined> {
    let result: AdvanceCommonAdapter | undefined = undefined
    let sdkId = adnData.supplier?.id
    switch (sdkId) {
      case AdvanceConstant.ADV_SDK_ID_CSJ:{ // 穿山甲
        const harName = 'CSJAdapter';
        const ns: ESObject = await import(harName);
        result = ns.AdvCSJUtil.getCSJAdAdapter(adnData.adType, adnData)
        return result
      }
      default:
        return result
    }
  }
}