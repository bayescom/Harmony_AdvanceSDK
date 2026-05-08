import { systemDateTime } from "@kit.BasicServicesKit"
import { BYCacheUtil } from "../../basic/cache/BYCacheUtil"

export class AdvanceAdCacheModel {
  // 广告对象
  adObject: object | undefined = undefined
  // 广告价格
  price: number = 0
  // 广告缓存时间戳（ms）
  cachedTimestamp: number = 0
  // 广告缓存过期时间（秒）
  expireTime: number = 0
  // 缓存广告的源reqid
  sourceReqId: string = ''
  // 当前缓存是否有效（未过期）
  get isCacheValid() {
    const currentTimeStamp = systemDateTime.getTime()
    return this.cachedTimestamp + this.expireTime * 1000 > currentTimeStamp
  }
}


export class AdvanceAdCacheManager {
  // 缓存广告Adapter对象
  static cacheAd(adapter: object, price: number, expireTime: number, sourceReqId: string, key: string) {
    // 创建广告缓存对象
    let cacheModel = new AdvanceAdCacheModel()
    cacheModel.adObject = adapter
    cacheModel.price = price
    cacheModel.cachedTimestamp = systemDateTime.getTime()
    cacheModel.expireTime = expireTime
    cacheModel.sourceReqId = sourceReqId
    BYCacheUtil.put(key, cacheModel)
  }

  // 获取缓存对象
  static getAdCacheModelFromCachedKey(key: string): AdvanceAdCacheModel | undefined {
    let cacheModel = BYCacheUtil.get(key) as AdvanceAdCacheModel
    if (cacheModel && !cacheModel.isCacheValid) { // 缓存过期则移除
      AdvanceAdCacheManager.removeAdCacheModelFromCachedKey(key)
      return undefined
    }
    return cacheModel
  }

  // 移除缓存对象
  static removeAdCacheModelFromCachedKey(key: string) {
    BYCacheUtil.remove(key)
  }
}