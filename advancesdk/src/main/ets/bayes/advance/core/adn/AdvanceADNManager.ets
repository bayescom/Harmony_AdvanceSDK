import { AdvanceConstant } from '../../define/AdvanceConstant'
import { AdvanceCommonAdapter } from './AdvanceCommonAdapter'
import { AdvanceServerReward, AdvanceSupplierModel } from '../../model/AdvanceNetModel'
import { AdvanceAdType } from '../../define/AdvanceDefine'
import { AdvRewardVideoModel } from '../../model/AdvanceAdInfo'

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
  // 激励视频奖励信息（外部传入）
  rewardVideoModel?: AdvRewardVideoModel
  // 激励视频服务端验证对象
  serverReward?: AdvanceServerReward
}

export class AdvanceAdnInitResult{
  success: boolean = false
  code: string | number  = ''
  msg: string = ''
}

export class AdvanceADNManager {
  //生成对应adapter实现类
  static async generateAdnAdapter(adnData: AdvanceADNUnitData): Promise<AdvanceCommonAdapter | undefined> {
    return new Promise<AdvanceCommonAdapter | undefined>((resolve) => {
      let result: AdvanceCommonAdapter | undefined = undefined
      let sdkId = adnData.supplier?.id
      let harName = ''
      switch (sdkId) {
        case AdvanceConstant.ADV_SDK_ID_CSJ:{ // 穿山甲
          harName = 'csj_adapter';
          import(harName).then((ns:ESObject) => {
            result = ns.AdvCSJUtil.getCSJAdAdapter(adnData)
            resolve(result)
          }).catch((error: Error) => {
            resolve(result)
          });
          break
        }
        case AdvanceConstant.ADV_SDK_ID_GDT:{ // 广点通
          harName = 'gdt_adapter';
          import(harName).then((ns:ESObject) => {
            result = ns.AdvGDTUtil.getGDTAdAdapter(adnData)
            resolve(result)
          }).catch((error: Error) => {
            resolve(result)
          });
          break
        }
        case AdvanceConstant.ADV_SDK_ID_KS:{ // 快手
          harName = 'ks_adapter';
          import(harName).then((ns:ESObject) => {
            result = ns.AdvKSUtil.getKSAdAdapter(adnData)
            resolve(result)
          }).catch((error: Error) => {
            resolve(result)
          });
          break
        }
        case AdvanceConstant.ADV_SDK_ID_MERCURY:{ // 倍业
          harName = 'mercury_adapter';
          import(harName).then((ns:ESObject) => {
            result = ns.AdvMercuryUtil.getMercuryAdAdapter(adnData)
            resolve(result)
          }).catch((error: Error) => {
            resolve(result)
          });
          break
        }
        case AdvanceConstant.ADV_SDK_ID_HUAWEI:{ // 华为
          harName = 'huawei_adapter';
          import(harName).then((ns:ESObject) => {
            result = ns.AdvHuaweiUtil.getHuaweiAdAdapter(adnData)
            resolve(result)
          }).catch((error: Error) => {
            resolve(result)
          });
          break
        }
        default:
          resolve(result)
      }
    })
  }

  //初始化ADN
  static async loadADN(supplier: AdvanceSupplierModel): Promise<AdvanceAdnInitResult> {
    return new Promise<AdvanceAdnInitResult>((resolve) => {
      let result = new AdvanceAdnInitResult()
      let harName = ''
      switch (supplier.id) {
        case AdvanceConstant.ADV_SDK_ID_CSJ:{ // 穿山甲
          harName = 'csj_adapter';
          import(harName).then(async (ns:ESObject) => {
            result = await ns.AdvCSJUtil.loadCSJSDK(supplier)
            resolve(result)
          }).catch((error: Error) => {
            result.msg = error.message
            resolve(result)
          });
          break
        }
        case AdvanceConstant.ADV_SDK_ID_GDT:{ // 广点通
          harName = 'gdt_adapter';
          import(harName).then(async (ns:ESObject) => {
            result = await ns.AdvGDTUtil.loadGDTSDK(supplier)
            resolve(result)
          }).catch((error: Error) => {
            result.msg = error.message
            resolve(result)
          });
          break
        }
        case AdvanceConstant.ADV_SDK_ID_KS:{ // 快手
          harName = 'ks_adapter';
          import(harName).then(async (ns:ESObject) => {
            result = await ns.AdvKSUtil.loadKSSDK(supplier)
            resolve(result)
          }).catch((error: Error) => {
            result.msg = error.message
            resolve(result)
          });
          break
        }
        case AdvanceConstant.ADV_SDK_ID_MERCURY:{ // 倍业
          harName = 'mercury_adapter';
          import(harName).then(async (ns:ESObject) => {
            result = await ns.AdvMercuryUtil.loadMercurySDK(supplier)
            resolve(result)
          }).catch((error: Error) => {
            result.msg = error.message
            resolve(result)
          });
          break
        }
        case AdvanceConstant.ADV_SDK_ID_HUAWEI:{ // 华为
          harName = 'huawei_adapter';
          import(harName).then(async (ns:ESObject) => {
            result.success = true
            result.code = 0
            result.msg = '无需初始化'
            resolve(result)
          }).catch((error: Error) => {
            result.msg = error.message
            resolve(result)
          });
          break
        }
        default:
          resolve(result)
      }
    })
  }

  //获取ADN版本号
  static async getSDKVersion(supplierId: string): Promise<string> {
    return new Promise<string>((resolve) => {
      let version = ''
      let harName = ''
      switch (supplierId) {
        case AdvanceConstant.ADV_SDK_ID_CSJ:{ // 穿山甲
          harName = 'csj_adapter';
          import(harName).then((ns:ESObject) => {
            version = ns.AdvCSJUtil.getCSJSDKVersion()
            resolve(version)
          }).catch((error: Error) => {
            resolve(version)
          });
          break
        }
        case AdvanceConstant.ADV_SDK_ID_GDT:{ // 广点通
          harName = 'gdt_adapter';
          import(harName).then((ns:ESObject) => {
            version = ns.AdvGDTUtil.getGDTSDKVersion()
            resolve(version)
          }).catch((error: Error) => {
            resolve(version)
          });
          break
        }
        case AdvanceConstant.ADV_SDK_ID_KS:{ // 快手
          harName = 'ks_adapter';
          import(harName).then((ns:ESObject) => {
            version = ns.AdvKSUtil.getKSSDKVersion()
            resolve(version)
          }).catch((error: Error) => {
            resolve(version)
          });
          break
        }
        case AdvanceConstant.ADV_SDK_ID_MERCURY: { // 倍业
          harName = 'mercury_adapter';
          import(harName).then((ns: ESObject) => {
            version = ns.AdvMercuryUtil.getMercurySDKVersion()
            resolve(version)
          }).catch((error: Error) => {
            resolve(version)
          });
          break
        }
        default:
          resolve(version)
      }
    })
  }
}