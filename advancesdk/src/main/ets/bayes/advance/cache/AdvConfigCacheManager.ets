import { AdvanceSetting } from '../config/AdvanceSetting'
import { BYPreferencesUtil } from '../../basic/cache/BYPreferencesUtil'

export interface AdvanceSDKConfig {
  // 按广告位 ID 索引的频控配置。
  adspot_configs?: Record<string, AdvanceAdspotConfig>
  // 素材巡检配置；服务端未下发时保持关闭。
  material_inspection_config?: AdvMaterialInspectionConfig
}

// 频控值为 0 或未下发时表示不限制。
export interface AdvanceAdspotConfig {
  adspot_id?: string
  req_interval?: number // 两次真实广告请求之间的最小间隔（ms）
  req_limit?: number // 日请求次数上限
  imp_limit?: number // 日有效曝光次数上限
  click_limit?: number // 日点击次数上限
}

export interface AdvMaterialInspectionConfig {
  enable?: number // 是否启用，缺省值为 0
  exposure_sample_rate?: number // 曝光采样比例，缺省值为 0.01
  capture_delay_ms?: number // 曝光后首次采样延迟（ms），缺省值为 1000
  image_max_size?: number // 单张上传图片大小上限（KB），缺省值为 500
}

const AdvanceSDKConfigKey = 'AdvanceSDKConfigKey'

export class AdvConfigCacheManager {
  static cacheSDKConfig(config: AdvanceSDKConfig, appId: string = AdvanceSetting.get().appId): void {
    const key = `${AdvanceSDKConfigKey}${appId}`
    const jsonString = JSON.stringify(config)
    BYPreferencesUtil.putSync(key, jsonString)
  }

  static sdkConfig(): AdvanceSDKConfig | undefined {
    const key = `${AdvanceSDKConfigKey}${AdvanceSetting.get().appId}`
    const jsonString = BYPreferencesUtil.getStringSync(key)
    if (jsonString) {
      return JSON.parse(jsonString) as AdvanceSDKConfig
    }
    return undefined
  }
}
