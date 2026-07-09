import { AdvanceSetting } from "../../../../../../Index"
import { BYPreferencesUtil } from "../../basic/cache/BYPreferencesUtil"

// 自定义Adn list信息
export interface AdvCustomAdnListInfo {
  custom_adn_list: AdvCustomAdnModel[]
  version: string // 当前adn_list的版本信息
}

// 自定义广告网络对象
export interface AdvCustomAdnModel {
  id: number // id
  name: string // 名称
  custom_adn_module: string // 模块名称
  custom_config_adapter: string // 初始化的配置类名
  custom_splash_adapter: string // 开屏广告的配置类名
  custom_banner_adapter: string // banner广告的配置类名
  custom_interstitial_adapter: string // 插屏广告的配置类名
  custom_rewardvideo_adapter: string // 激励视频广告的配置类名
  custom_nativeexpress_adapter: string // 模板渲染信息流广告的配置类名
  custom_renderfeed_adapter: string // 自渲染信息流广告的配置类名
}

const AdvanceAdnListInfoKey = 'AdvanceAdnListInfoKey'

export class AdvCustomAdnCacheManager {
  static cacheCustomAdnListInfo(info: AdvCustomAdnListInfo) {
    const key = `${AdvanceAdnListInfoKey}${AdvanceSetting.get().appId}`
    const jsonString = JSON.stringify(info)
    BYPreferencesUtil.putSync(key, jsonString)
  }

  static customAdnListInfo(): AdvCustomAdnListInfo | undefined {
    const key = `${AdvanceAdnListInfoKey}${AdvanceSetting.get().appId}`
    const jsonString = BYPreferencesUtil.getStringSync(key)
    if (jsonString) {
      const info = JSON.parse(jsonString) as AdvCustomAdnListInfo
      return info
    }
    return undefined
  }
}