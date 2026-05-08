import { systemDateTime } from '@kit.BasicServicesKit';
import { BYLog } from '../BYLog';

export const CACHE_TIME_WEEK = 7*24*60*60
export const CACHE_TIME_MONTH = 30*24*60*60

export namespace BYCustomCacheUtil {

  /**
   * 私有缓存对象
   */
  const cache: Record<string, Object> = {};


  /**
   * 存值
   * @param key 存入key
   * @param value 存入数据
   */
  export function save<T>(key: string, value: T): void {
    try {
      const savedValue = new BYCacheEle<T>()
      savedValue.eleValue = value
      savedValue.cachedTime = systemDateTime.getTime()
      cache[key] = savedValue;
    } catch (e) {
      BYLog.printE(e)
    }
  }

  /**
   * 取值
   * @param key 存入的key
   * @returns
   */
  export function get<T>(key: string, expireTime: number = 0): BYCacheResult<T> {
    let result = new BYCacheResult<T>()
    try {
      let savedObj = cache[key] as BYCacheEle<T>
      if (savedObj) {
        const savedValue = savedObj.eleValue
        BYLog.debug(`已找到缓存 key:${key} , savedValue : ${savedValue}`)
        result.cacheValue = savedValue

        //如果配置了过期时间，检查是否需要更新源数据
        if (expireTime > 0) {
          let now = systemDateTime.getTime()
          let savedTime = savedObj.cachedTime
          if ((now - savedTime) > expireTime) {
            BYLog.debug(`当前缓存值已过期`)
            // 标识需要刷新 , 此时需要重新执行获取操作
            result.needRefresh = true
          }
        }
      }
    } catch (e) {
      BYLog.printE(e)
    }

    return result;
  }

}


export class BYCacheResult<T> {
  //是否需要进行刷新逻辑处理
  needRefresh: boolean = false
  //获取缓存的结果
  cacheValue ?: T = undefined

}

//缓存
export class BYCacheEle<T> {
  //缓存的数据信息
  eleValue ?: T = undefined
  //缓存时间，用来记录是否过期，过期将执行更新数据操作
  cachedTime: number = 0
}