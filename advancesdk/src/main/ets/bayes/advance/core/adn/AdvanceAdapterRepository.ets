import { AdvCustomAdnModel } from '../../cache/AdvCustomAdnCacheManager'
import { AdvanceConstant } from '../../define/AdvanceConstant'
import { AdvanceAdType } from '../../model/AdvanceAdInfo'

// 仅描述渠道的模块、导出类和支持的广告类型，不提前加载或初始化渠道 SDK。
export interface AdvanceAdapterDescriptor {
  readonly supplierId: string
  readonly moduleName: string
  readonly configAdapterName: string
  readonly versionParameterKey: string
  // 未支持的广告类型不加入映射。
  readonly adapters: Map<AdvanceAdType, string>
}

// SDK 内部渠道表，由启动流程维护，不需要媒体注册。
export class AdvanceAdapterRepository {
  private static descriptorsById: Map<string, AdvanceAdapterDescriptor> =
    AdvanceAdapterRepository.builtInDescriptors()

  static loadBuiltInAdapterDescriptors(): void {
    AdvanceAdapterRepository.descriptorsById = AdvanceAdapterRepository.builtInDescriptors()
  }

  static syncCustomAdaptersWithAdnList(adnList?: AdvCustomAdnModel[]): void {
    // 以完整内置表为基础整表替换，移除已删除的自定义渠道，保护内置渠道映射。
    const table = AdvanceAdapterRepository.builtInDescriptors()
    for (const adn of adnList ?? []) {
      const supplierId = adn.id?.toString()
      if (!supplierId || table.has(supplierId)) {
        continue
      }
      const adapters = new Map<AdvanceAdType, string>([
        [AdvanceAdType.splash, adn.custom_splash_adapter],
        [AdvanceAdType.banner, adn.custom_banner_adapter],
        [AdvanceAdType.interstitial, adn.custom_interstitial_adapter],
        [AdvanceAdType.rewardVideo, adn.custom_rewardvideo_adapter],
        [AdvanceAdType.nativeExpress, adn.custom_nativeexpress_adapter],
        [AdvanceAdType.renderFeed, adn.custom_renderfeed_adapter]
      ])
      adapters.forEach((className: string, adType: AdvanceAdType) => {
        if (!className) {
          adapters.delete(adType)
        }
      })
      const descriptor: AdvanceAdapterDescriptor = {
        supplierId: supplierId,
        moduleName: adn.custom_adn_module ?? '',
        configAdapterName: adn.custom_config_adapter ?? '',
        versionParameterKey: `custom_${supplierId}_v`,
        adapters: adapters
      }
      table.set(supplierId, descriptor)
    }
    AdvanceAdapterRepository.descriptorsById = table
  }

  static descriptorForSupplierId(supplierId: string): AdvanceAdapterDescriptor | undefined {
    return AdvanceAdapterRepository.descriptorsById.get(supplierId)
  }

  static allDescriptors(): AdvanceAdapterDescriptor[] {
    return Array.from(AdvanceAdapterRepository.descriptorsById.values())
  }

  private static builtInDescriptors(): Map<string, AdvanceAdapterDescriptor> {
    // 新增内置渠道只需在此添加一条完整描述。
    const descriptors: AdvanceAdapterDescriptor[] = [
      {
        supplierId: AdvanceConstant.ADV_SDK_ID_MERCURY,
        moduleName: 'mercury_adapter',
        configAdapterName: 'AdvMercuryConfigAdapter',
        versionParameterKey: 'mry_v',
        adapters: new Map<AdvanceAdType, string>([
          [AdvanceAdType.splash, 'AdvMercurySplashAdapter'],
          [AdvanceAdType.banner, 'AdvMercuryBannerAdapter'],
          [AdvanceAdType.interstitial, 'AdvMercuryInterstitialAdapter'],
          [AdvanceAdType.rewardVideo, 'AdvMercuryRewardVideoAdapter'],
          [AdvanceAdType.nativeExpress, 'AdvMercuryNativeExpressAdapter'],
          [AdvanceAdType.renderFeed, 'AdvMercuryRenderFeedAdapter']
        ])
      },
      {
        supplierId: AdvanceConstant.ADV_SDK_ID_GDT,
        moduleName: 'gdt_adapter',
        configAdapterName: 'AdvGDTConfigAdapter',
        versionParameterKey: 'gdt_v',
        adapters: new Map<AdvanceAdType, string>([
          [AdvanceAdType.splash, 'AdvGDTSplashAdapter'],
          [AdvanceAdType.banner, 'AdvGDTBannerAdapter'],
          [AdvanceAdType.interstitial, 'AdvGDTInterstitialAdapter'],
          [AdvanceAdType.rewardVideo, 'AdvGDTRewardVideoAdapter'],
          [AdvanceAdType.nativeExpress, 'AdvGDTNativeExpressAdapter'],
          [AdvanceAdType.renderFeed, 'AdvGDTRenderFeedAdapter']
        ])
      },
      {
        supplierId: AdvanceConstant.ADV_SDK_ID_CSJ,
        moduleName: 'csj_adapter',
        configAdapterName: 'AdvCSJConfigAdapter',
        versionParameterKey: 'csj_v',
        adapters: new Map<AdvanceAdType, string>([
          [AdvanceAdType.splash, 'AdvCSJSplashAdapter'],
          [AdvanceAdType.banner, 'AdvCSJBannerAdapter'],
          [AdvanceAdType.interstitial, 'AdvCSJInterstitialAdapter'],
          [AdvanceAdType.rewardVideo, 'AdvCSJRewardVideoAdapter'],
          [AdvanceAdType.nativeExpress, 'AdvCSJNativeExpressAdapter'],
          [AdvanceAdType.renderFeed, 'AdvCSJRenderFeedAdapter']
        ])
      },
      {
        supplierId: AdvanceConstant.ADV_SDK_ID_KS,
        moduleName: 'ks_adapter',
        configAdapterName: 'AdvKSConfigAdapter',
        versionParameterKey: 'ks_v',
        adapters: new Map<AdvanceAdType, string>([
          [AdvanceAdType.splash, 'AdvKSSplashAdapter'],
          [AdvanceAdType.interstitial, 'AdvKSInterstitialAdapter'],
          [AdvanceAdType.rewardVideo, 'AdvKSRewardVideoAdapter'],
          [AdvanceAdType.nativeExpress, 'AdvKSNativeExpressAdapter'],
          [AdvanceAdType.renderFeed, 'AdvKSRenderFeedAdapter']
        ])
      },
      {
        supplierId: AdvanceConstant.ADV_SDK_ID_HUAWEI,
        moduleName: 'huawei_adapter',
        configAdapterName: 'AdvHuaweiConfigAdapter',
        // 当前华为配置类未提供版本号，不参与渠道版本上报。
        versionParameterKey: '',
        adapters: new Map<AdvanceAdType, string>([
          [AdvanceAdType.splash, 'AdvHuaweiSplashAdapter'],
          [AdvanceAdType.interstitial, 'AdvHuaweiInterstitialAdapter'],
          [AdvanceAdType.rewardVideo, 'AdvHuaweiRewardVideoAdapter'],
          [AdvanceAdType.nativeExpress, 'AdvHuaweiNativeExpressAdapter']
        ])
      }
    ]
    const table = new Map<string, AdvanceAdapterDescriptor>()
    descriptors.forEach((descriptor: AdvanceAdapterDescriptor) => {
      table.set(descriptor.supplierId, descriptor)
    })
    return table
  }
}
