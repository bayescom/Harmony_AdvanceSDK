import { systemDateTime } from "@kit.BasicServicesKit"
import { AdvanceCommonAdapter } from "../core/adn/AdvanceCommonAdapter"

export class AdvanceAdCacheModel {
  // 广告对象
  adObject?: AdvanceCommonAdapter
  // 广告价格
  price: number = 0
  // 广告缓存时间戳（ms）
  cachedTimestamp: number = 0
  // 广告缓存过期时间（秒）
  expireTime: number = 0
  // 缓存广告的源reqid
  sourceReqId: string = ''
  // 当前缓存是否有效（未过期）
  get isCacheValid(): boolean {
    const currentTimeStamp = systemDateTime.getTime()
    return this.adObject !== undefined &&
      this.cachedTimestamp + this.expireTime * 1000 > currentTimeStamp
  }
}


export class AdvanceAdCacheManager {
  private static cache: Map<string, AdvanceAdCacheModel> = new Map()

  // Adapter 在 UI 线程使用，检查与写入同步完成，不覆盖已有的有效缓存。
  static cacheAdIfAbsent(adapter: AdvanceCommonAdapter, price: number, expireTime: number,
    sourceReqId: string, key: string) {
    let cacheModel = AdvanceAdCacheManager.cache.get(key)
    if (cacheModel && !cacheModel.isCacheValid) {
      AdvanceAdCacheManager.cache.delete(key)
      cacheModel = undefined
    }
    if (cacheModel) {
      return
    }
    // 创建广告缓存对象
    cacheModel = new AdvanceAdCacheModel()
    cacheModel.adObject = adapter
    cacheModel.price = price
    cacheModel.cachedTimestamp = systemDateTime.getTime()
    cacheModel.expireTime = expireTime
    cacheModel.sourceReqId = sourceReqId
    AdvanceAdCacheManager.cache.set(key, cacheModel)
  }

  // 获取缓存对象
  static getAdCacheModelFromCachedKey(key: string): AdvanceAdCacheModel | undefined {
    const cacheModel = AdvanceAdCacheManager.cache.get(key)
    if (cacheModel && !cacheModel.isCacheValid) { // 缓存过期则移除
      AdvanceAdCacheManager.cache.delete(key)
      return undefined
    }
    return cacheModel
  }

  // 只删除同一个 Adapter，避免前一次请求的回调误删后续请求填充的缓存。
  static removeAdCacheModelFromCachedKey(key: string, matchingAdapter: AdvanceCommonAdapter) {
    const cacheModel = AdvanceAdCacheManager.cache.get(key)
    if (!cacheModel || cacheModel.adObject !== matchingAdapter) {
      return
    }
    return AdvanceAdCacheManager.cache.delete(key)
  }
}
