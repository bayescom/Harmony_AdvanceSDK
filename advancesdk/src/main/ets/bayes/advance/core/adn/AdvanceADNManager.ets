import { AdvanceConstant } from '../../define/AdvanceConstant'
import { AdvanceCommonAdapter } from './AdvanceCommonAdapter'
import { AdvanceSupplierModel } from '../../model/AdvanceNetModel'
import { AdvanceAdType } from '../../define/AdvanceDefine'

// 传递给adapter内的参数信息
export class AdvanceADNUnitData {
  // adn渠道对象
  supplier = new AdvanceSupplierModel()
  // 广告位类型
  adType: AdvanceAdType = AdvanceAdType.unknown
  // 广告位宽度
  vpWidth?: number
  // 广告位高度
  vpHeight?: number
}

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
      case AdvanceConstant.ADV_SDK_ID_HUAWEI:{ // 华为
        harName = 'huawei_adapter';
        const ns: ESObject = await import(harName);
        result = ns.AdvHuaweiUtil.getHuaweiAdAdapter(adnData)
        return result
      }
      default:
        return result
    }
  }

  //初始化ADN
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
      case AdvanceConstant.ADV_SDK_ID_HUAWEI:{ // 华为
        result.success = true
        result.code = 0
        result.msg = '无需初始化'
        return result
      }
      default:
        return result
    }
  }

  //获取ADN版本号
  static async getSDKVersion(supplierId: string): Promise<string> {
    let version = ''
    let harName = ''
    switch (supplierId) {
      case AdvanceConstant.ADV_SDK_ID_CSJ:{ // 穿山甲
        harName = 'csj_adapter';
        const ns: ESObject = await import(harName);
        version = ns.AdvCSJUtil.getCSJSDKVersion()
        return version
      }
      case AdvanceConstant.ADV_SDK_ID_GDT:{ // 广点通
        harName = 'gdt_adapter';
        const ns: ESObject = await import(harName);
        version = ns.AdvGDTUtil.getGDTSDKVersion()
        return version
      }
      case AdvanceConstant.ADV_SDK_ID_KS:{ // 快手
        harName = 'ks_adapter';
        const ns: ESObject = await import(harName);
        version = ns.AdvKSUtil.getKSSDKVersion()
        return version
      }
      case AdvanceConstant.ADV_SDK_ID_MERCURY:{ // 倍业
        harName = 'mercury_adapter';
        const ns: ESObject = await import(harName);
        version = ns.AdvMercuryUtil.getMercurySDKVersion()
        return version
      }
      default:
        return version
    }
  }
}