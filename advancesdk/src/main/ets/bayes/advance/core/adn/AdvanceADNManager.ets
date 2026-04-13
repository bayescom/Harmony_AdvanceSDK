import { AdvanceADNUnitData } from './AdvanceADNUnitData'
import { AdvanceConstant } from '../../define/AdvanceConstant'
import { AdvanceCommonAdapter } from './AdvanceCommonAdapter'
import { AdvanceSupplierModel } from '../../model/AdvanceNetModel'

export class AdvanceAdnInitResult{
  success: boolean = false
  code: string | number  = ''
  msg: string = ''
}

export class AdvanceADNManager {
  //生成对应adapter实现类
  static async generateAdnAdapter(adnData: AdvanceADNUnitData): Promise<AdvanceCommonAdapter | undefined> {
    let result: AdvanceCommonAdapter | undefined = undefined
    let sdkId = adnData.supplier?.id
    let harName = ''
    switch (sdkId) {
      case AdvanceConstant.ADV_SDK_ID_CSJ:{ // 穿山甲
        harName = 'csj_adapter';
        const ns: ESObject = await import(harName);
        result = ns.AdvCSJUtil.getCSJAdAdapter(adnData)
        return result
      }
      case AdvanceConstant.ADV_SDK_ID_GDT:{ // 广点通
        harName = 'gdt_adapter';
        const ns: ESObject = await import(harName);
        result = ns.AdvGDTUtil.getGDTAdAdapter(adnData)
        return result
      }
      case AdvanceConstant.ADV_SDK_ID_KS:{ // 快手
        harName = 'ks_adapter';
        const ns: ESObject = await import(harName);
        result = ns.AdvKSUtil.getKSAdAdapter(adnData)
        return result
      }
      case AdvanceConstant.ADV_SDK_ID_MERCURY:{ // 倍业
        harName = 'mercury_adapter';
        const ns: ESObject = await import(harName);
        result = ns.AdvMercuryUtil.getMercuryAdAdapter(adnData)
        return result
      }
      default:
        return result
    }
  }

  static async loadADN(supplier: AdvanceSupplierModel): Promise<AdvanceAdnInitResult> {
    let result = new AdvanceAdnInitResult()
    let harName = ''
    switch (supplier.id) {
      case AdvanceConstant.ADV_SDK_ID_CSJ:{ // 穿山甲
        harName = 'csj_adapter';
        const ns: ESObject = await import(harName);
        result = await ns.AdvCSJUtil.loadCSJSDK(supplier)
        return result
      }
      case AdvanceConstant.ADV_SDK_ID_GDT:{ // 广点通
        harName = 'gdt_adapter';
        const ns: ESObject = await import(harName);
        result = await ns.AdvGDTUtil.loadGDTSDK(supplier)
        return result
      }
      case AdvanceConstant.ADV_SDK_ID_KS:{ // 快手
        harName = 'ks_adapter';
        const ns: ESObject = await import(harName);
        result = await ns.AdvKSUtil.loadKSSDK(supplier)
        return result
      }
      case AdvanceConstant.ADV_SDK_ID_MERCURY:{ // 倍业
        harName = 'mercury_adapter';
        const ns: ESObject = await import(harName);
        result = await ns.AdvMercuryUtil.loadMercurySDK(supplier)
        return result
      }
      default:
        return result
    }
  }
}