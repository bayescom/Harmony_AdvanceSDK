import { AdvanceConstant } from '../../define/AdvanceConstant'
import { AdvanceCommonAdapter } from './AdvanceCommonAdapter'
import { AdvanceServerReward, AdvanceSupplierModel } from '../../model/AdvanceNetModel'
import { AdvanceAdType } from '../../define/AdvanceDefine'
import { AdvRewardVideoModel } from '../../model/AdvanceAdInfo'

// 传递给 adapter 的参数信息
export class AdvanceADNUnitData {
  // 渠道id
  adnId: string = ''
  // 广告位类型
  adType: AdvanceAdType = AdvanceAdType.unknown
  // 广告位id
  placementId: string = ''
  // 超时时间
  timeout: number = 0
  // 广告位宽度
  vpWidth?: number
  // 广告位高度
  vpHeight?: number
  // 激励视频奖励信息（外部传入）
  rewardVideoModel?: AdvRewardVideoModel
  // 激励视频服务端验证对象
  serverReward?: AdvanceServerReward
  // 扩展信息
  extra?: Record<string, string | number>
}

export class AdvanceAdnInitResult {
  success: boolean = false
  code: string | number = ''
  msg: string = ''
}

export class AdvanceADNManager {
  //生成对应adapter实现类
  static async generateAdnAdapter(adnData: AdvanceADNUnitData): Promise<AdvanceCommonAdapter | undefined> {
    return new Promise<AdvanceCommonAdapter | undefined>((resolve) => {
      let supplierId = adnData.adnId
      let harName = AdvanceADNManager.mappingModuleName(supplierId)
      let className = ''
      switch (adnData.adType) {
        case AdvanceAdType.splash:
          className = AdvanceADNManager.mappingSplashAdapterName(supplierId)
          break
        case AdvanceAdType.banner:
          className = AdvanceADNManager.mappingBannerAdapterName(supplierId)
          break
        case AdvanceAdType.interstitial:
          className = AdvanceADNManager.mappingInterstitialAdapterName(supplierId)
          break
        case AdvanceAdType.rewardVideo:
          className = AdvanceADNManager.mappingRewardVideoAdapterName(supplierId)
          break
        case AdvanceAdType.nativeExpress:
          className = AdvanceADNManager.mappingNativeExpressAdapterName(supplierId)
          break
        case AdvanceAdType.renderFeed:
          className = AdvanceADNManager.mappingRenderFeedAdapterName(supplierId)
          break
        default:
          break
      }
      import(harName).then((ns: ESObject) => {
        const AdapterClass: ESObject = ns[className];
        resolve(AdapterClass? new AdapterClass(adnData) : undefined)
      }).catch((error: Error) => {
        resolve(undefined)
      });
    })
  }

  //初始化ADN
  static async loadADN(supplier: AdvanceSupplierModel): Promise<AdvanceAdnInitResult> {
    return new Promise<AdvanceAdnInitResult>((resolve) => {
      let result = new AdvanceAdnInitResult()
      let harName = ''
      switch (supplier.id) {
        case AdvanceConstant.ADV_SDK_ID_CSJ: { // 穿山甲
          harName = 'csj_adapter';
          import(harName).then(async (ns: ESObject) => {
            result = await ns.AdvCSJUtil.loadCSJSDK(supplier)
            resolve(result)
          }).catch((error: Error) => {
            result.msg = error.message
            resolve(result)
          });
          break
        }
        case AdvanceConstant.ADV_SDK_ID_GDT: { // 广点通
          harName = 'gdt_adapter';
          import(harName).then(async (ns: ESObject) => {
            result = await ns.AdvGDTUtil.loadGDTSDK(supplier)
            resolve(result)
          }).catch((error: Error) => {
            result.msg = error.message
            resolve(result)
          });
          break
        }
        case AdvanceConstant.ADV_SDK_ID_KS: { // 快手
          harName = 'ks_adapter';
          import(harName).then(async (ns: ESObject) => {
            result = await ns.AdvKSUtil.loadKSSDK(supplier)
            resolve(result)
          }).catch((error: Error) => {
            result.msg = error.message
            resolve(result)
          });
          break
        }
        case AdvanceConstant.ADV_SDK_ID_MERCURY: { // 倍业
          harName = 'mercury_adapter';
          import(harName).then(async (ns: ESObject) => {
            result = await ns.AdvMercuryUtil.loadMercurySDK(supplier)
            resolve(result)
          }).catch((error: Error) => {
            result.msg = error.message
            resolve(result)
          });
          break
        }
        case AdvanceConstant.ADV_SDK_ID_HUAWEI: { // 华为
          harName = 'huawei_adapter';
          import(harName).then(async (ns: ESObject) => {
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
        case AdvanceConstant.ADV_SDK_ID_CSJ: { // 穿山甲
          harName = 'csj_adapter';
          import(harName).then((ns: ESObject) => {
            version = ns.AdvCSJUtil.getCSJSDKVersion()
            resolve(version)
          }).catch((error: Error) => {
            resolve(version)
          });
          break
        }
        case AdvanceConstant.ADV_SDK_ID_GDT: { // 广点通
          harName = 'gdt_adapter';
          import(harName).then((ns: ESObject) => {
            version = ns.AdvGDTUtil.getGDTSDKVersion()
            resolve(version)
          }).catch((error: Error) => {
            resolve(version)
          });
          break
        }
        case AdvanceConstant.ADV_SDK_ID_KS: { // 快手
          harName = 'ks_adapter';
          import(harName).then((ns: ESObject) => {
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

  static mappingModuleName(supplierId: string) {
    switch (supplierId) {
      case AdvanceConstant.ADV_SDK_ID_CSJ: // 穿山甲
        return 'csj_adapter'
      case AdvanceConstant.ADV_SDK_ID_GDT: // 广点通
        return 'gdt_adapter'
      case AdvanceConstant.ADV_SDK_ID_KS: // 快手
        return 'ks_adapter'
      case AdvanceConstant.ADV_SDK_ID_MERCURY: // 倍业
        return 'mercury_adapter'
      case AdvanceConstant.ADV_SDK_ID_HUAWEI: // 华为
        return 'huawei_adapter'
      default: // 自定义ADN
        return ''
    }
  }

  static mappingSplashAdapterName(supplierId: string) {
    switch (supplierId) {
      case AdvanceConstant.ADV_SDK_ID_CSJ: // 穿山甲
        return 'AdvCSJSplashAdapter'
      case AdvanceConstant.ADV_SDK_ID_GDT: // 广点通
        return 'AdvGDTSplashAdapter'
      case AdvanceConstant.ADV_SDK_ID_KS: // 快手
        return 'AdvKSSplashAdapter'
      case AdvanceConstant.ADV_SDK_ID_MERCURY: // 倍业
        return 'AdvMercurySplashAdapter'
      case AdvanceConstant.ADV_SDK_ID_HUAWEI: // 华为
        return 'AdvHuaweiSplashAdapter'
      default: // 自定义ADN
        return ''
    }
  }

  static mappingBannerAdapterName(supplierId: string) {
    switch (supplierId) {
      case AdvanceConstant.ADV_SDK_ID_CSJ: // 穿山甲
        return 'AdvCSJBannerAdapter'
      case AdvanceConstant.ADV_SDK_ID_GDT: // 广点通
        return 'AdvGDTBannerAdapter'
      case AdvanceConstant.ADV_SDK_ID_MERCURY: // 倍业
        return 'AdvMercuryBannerAdapter'
      default: // 自定义ADN
        return ''
    }
  }

  static mappingInterstitialAdapterName(supplierId: string) {
    switch (supplierId) {
      case AdvanceConstant.ADV_SDK_ID_CSJ: // 穿山甲
        return 'AdvCSJInterstitialAdapter'
      case AdvanceConstant.ADV_SDK_ID_GDT: // 广点通
        return 'AdvGDTInterstitialAdapter'
      case AdvanceConstant.ADV_SDK_ID_KS: // 快手
        return 'AdvKSInterstitialAdapter'
      case AdvanceConstant.ADV_SDK_ID_MERCURY: // 倍业
        return 'AdvMercuryInterstitialAdapter'
      case AdvanceConstant.ADV_SDK_ID_HUAWEI: // 华为
        return 'AdvHuaweiInterstitialAdapter'
      default: // 自定义ADN
        return ''
    }
  }

  static mappingRewardVideoAdapterName(supplierId: string) {
    switch (supplierId) {
      case AdvanceConstant.ADV_SDK_ID_CSJ: // 穿山甲
        return 'AdvCSJRewardVideoAdapter'
      case AdvanceConstant.ADV_SDK_ID_GDT: // 广点通
        return 'AdvGDTRewardVideoAdapter'
      case AdvanceConstant.ADV_SDK_ID_KS: // 快手
        return 'AdvKSRewardVideoAdapter'
      case AdvanceConstant.ADV_SDK_ID_MERCURY: // 倍业
        return 'AdvMercuryRewardVideoAdapter'
      case AdvanceConstant.ADV_SDK_ID_HUAWEI: // 华为
        return 'AdvHuaweiRewardVideoAdapter'
      default: // 自定义ADN
        return ''
    }
  }

  static mappingNativeExpressAdapterName(supplierId: string) {
    switch (supplierId) {
      case AdvanceConstant.ADV_SDK_ID_CSJ: // 穿山甲
        return 'AdvCSJNativeExpressAdapter'
      case AdvanceConstant.ADV_SDK_ID_GDT: // 广点通
        return 'AdvGDTNativeExpressAdapter'
      case AdvanceConstant.ADV_SDK_ID_KS: // 快手
        return 'AdvKSNativeExpressAdapter'
      case AdvanceConstant.ADV_SDK_ID_MERCURY: // 倍业
        return 'AdvMercuryNativeExpressAdapter'
      case AdvanceConstant.ADV_SDK_ID_HUAWEI: // 华为
        return 'AdvHuaweiNativeExpressAdapter'
      default: // 自定义ADN
        return ''
    }
  }

  static mappingRenderFeedAdapterName(supplierId: string) {
    switch (supplierId) {
      case AdvanceConstant.ADV_SDK_ID_CSJ: // 穿山甲
        return 'AdvCSJRenderFeedAdapter'
      case AdvanceConstant.ADV_SDK_ID_GDT: // 广点通
        return 'AdvGDTRenderFeedAdapter'
      case AdvanceConstant.ADV_SDK_ID_KS: // 快手
        return 'AdvKSRenderFeedAdapter'
      case AdvanceConstant.ADV_SDK_ID_MERCURY: // 倍业
        return 'AdvMercuryRenderFeedAdapter'
      case AdvanceConstant.ADV_SDK_ID_HUAWEI: // 华为
        return 'AdvHuaweiRenderFeedAdapter'
      default: // 自定义ADN
        return ''
    }
  }
}