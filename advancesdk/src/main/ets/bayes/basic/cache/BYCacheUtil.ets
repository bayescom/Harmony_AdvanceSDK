
/**
 * 缓存工具类
 */
export class BYCacheUtil {
  private static cache: Record<string, Object> = {}; //私有缓存对象


  /**
   * 获取缓存中的数据
   * @param key 存入的key
   * @returns
   */
  static get<T>(key: string): T {
    return BYCacheUtil.cache[key] as T;
  }


  /**
   * 将数据存入缓存中
   * @param key 存入key
   * @param value 存入数据
   */
  static put<T>(key: string, value: T): void {
    BYCacheUtil.cache[key] = value as Object;
  }


  /**
   * 删除对应的缓存
   */
  static remove(key: string) {
    let newObj: Record<string, Object> = {};
    Object.keys(BYCacheUtil.cache).forEach(cacheKey => {
      if (cacheKey !== key) {
        newObj[cacheKey] = BYCacheUtil.cache[cacheKey];
      }
    });
    BYCacheUtil.cache = newObj
  }


  /**
   * 缓存中的数据是否存在
   * @param key 存入的key
   * @returns
   */
  static has(key: string): boolean {
    let keys = Object.keys(BYCacheUtil.cache);
    return keys.indexOf(key) >= 0
  }

  /**
   * 判断缓存是否为空
   * @returns
   */
  static isEmpty(): boolean {
    let keys = Object.keys(BYCacheUtil.cache);
    return keys.length <= 0;
  }

  /**
   * 清除缓存数据
   */
  static clear(): void {
    BYCacheUtil.cache = {};
  }


}
