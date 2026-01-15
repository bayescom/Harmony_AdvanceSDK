import util from '@ohos.util';
import fs from '@ohos.file.fs';
import { BYFileUtil } from '../util/BYFileUtil';
import { BYLog } from '../BYLog';

const INT_MAX = 2147483647
const TAG = "[BYDiskLruCache] "

/**
 * 二级文件缓存
 * 主线程通过lruCache管理缓存大小
 * 子线程直接读写文件
 */
export class BYDiskLruCache {
  static CACHE_FOLDER: string = 'BYDiskLruCache' // context cacheDir 的缓存文件目录
  maxMemory: number = 0
  currentMemory: number = 0
  maxSize: number = 0
  path: string = ''
  private lruCache: util.LRUCache<string, number>
  private isInited: boolean = false
  private context?: Context
  readonly defaultMaxMemorySize: number = 10 * 1024 * 1024 * 1024;
  readonly defaultMemorySize: number = 1024 * 1024 * 1024;

  constructor(context: Context, size: number = 0, memory: number = 0) {
    if (size <= 0 || size > INT_MAX) {
      size = INT_MAX;
    }
    if (memory <= 0 || memory > this.defaultMaxMemorySize) {
      memory = this.defaultMemorySize;
    }
    this.lruCache = new util.LRUCache(size);
    this.maxMemory = memory;
    this.currentMemory = 0;
    this.maxSize = size;
    this.context = context;
  }

  /**
   * 遍历缓存文件目录，初始化缓存
   */
  public initFileCache(path: string = BYDiskLruCache.CACHE_FOLDER) {
    if (this.isInited) {
      BYLog.debug(`already initFileCache `)
      return
    }
    BYLog.debug(`initFileCache Start`)

    let startTime = Date.now()
    if (this.context && path.startsWith(this.context.cacheDir) === true) {
      this.path = path
    } else {
      BYDiskLruCache.CACHE_FOLDER = path
      this.path = this.context?.cacheDir + BYFileUtil.SEPARATOR + BYDiskLruCache.CACHE_FOLDER + BYFileUtil.SEPARATOR
    }
    BYFileUtil.getInstance().createFolder(this.path)

    BYLog.debug(`initFileCache path：${this.path}`)
    // 遍历缓存目录下的文件，按照时间顺序加入缓存
    let filenames: string[] = BYFileUtil.getInstance().ListFileSync(this.path)

    interface CacheFileInfo {
      file: string;
      ctime: number;
      size: number;
    }

    // 按照上次访问该文件的时间排序
    let cachefiles: CacheFileInfo[] = []
    for (let i = 0; i < filenames.length; i++) {
      let stat: fs.Stat | undefined = BYFileUtil.getInstance().StatSync(this.path + filenames[i])
      cachefiles.push({
        file: filenames[i],
        ctime: stat === undefined ? 0 : stat.ctime,
        size: stat?.size ?? 0
      })
    }
    let sortedCachefiles: CacheFileInfo[] = cachefiles.sort((a, b) => a.ctime - b.ctime)

    for (let i = 0; i < sortedCachefiles.length; i++) {
      const fileSize: number = sortedCachefiles[i].size;
      // 处理数量超过size的场景，移除即将排除的文件
      if (this.lruCache.length == this.maxSize && !this.lruCache.contains(sortedCachefiles[i].file)) {
        let remove: number | undefined = this.lruCache.remove(this.lruCache.keys()[0])
        if (remove !== undefined) {
          BYFileUtil.getInstance().deleteFile(this.path + this.lruCache.keys()[0])
          this.removeMemorySize(fileSize)
        }
      }

      this.lruCache.put(sortedCachefiles[i].file, fileSize)
      this.addMemorySize(fileSize)
    }

    this.trimToSize();
    BYLog.info(' initFileCache cost:' + (Date.now() - startTime) + 'ms ,num:' + filenames.length + ',nums:' +
    this.lruCache.length + ',size:' + this.currentMemory)
    this.isInited = true
  }

  public isFileCacheInit(): boolean {
    return this.isInited
  }

  public getCacheFolder(): string {
    return BYDiskLruCache.CACHE_FOLDER
  }

  // 添加缓存键值对,同时写文件
  put(key: string, value: ArrayBuffer): void {
    if (key == null || value == null) {
      BYLog.error('key or value is invalid ');
    }
    if (!this.isInited) {
      BYLog.debug(`尚未初始化，无法执行存储操作`)
      return
    }

    // 如果size满了的话，需要按照LRU的方式删除第一个
    if (this.lruCache.length == this.maxSize && !this.lruCache.contains(key)) {
      this.remove(this.lruCache.keys()[0])
    } else if (this.lruCache.contains(key)) {
      this.remove(key)
    }

    let pre = this.lruCache.put(key, value.byteLength)
    BYFileUtil.getInstance().writeDataSync(this.path + key, value)
    if (pre !== undefined) {
      this.addMemorySize(value)
    }
    this.trimToSize()
  }

  // 添加缓存键值对，但不写文件（用于子线程已经写文件的场景）
  putWithoutWriteFile(key: string, value: ArrayBuffer | number): void {
    try {
      if (key == null || value == null) {
        BYLog.error('key or value is invalid ');
      }
      if (!this.isInited) {
        BYLog.debug(`尚未初始化，无法执行存储操作`)
        return
      }

      // 如果size满了的话，需要按照LRU的方式删除第一个
      if (this.lruCache.length == this.maxSize && !this.lruCache.contains(key)) {
        this.remove(this.lruCache.keys()[0])
      } else if (this.lruCache.contains(key)) {
        this.lruCache.remove(key)
        this.lruCache.put(key, typeof value == 'number' ? value : value.byteLength)
        return
      }

      this.lruCache.put(key, typeof value == 'number' ? value : value.byteLength)
      this.addMemorySize(value)
      this.trimToSize()
    } catch (e) {
      BYLog.printE(e)
    }
  }

  hasCached(key: string): boolean {
    let result = false

    try {
      let cacheInf = this.lruCache.get(key)
      BYLog.devDebug(TAG + `hasCached ,cacheInf :${cacheInf} `)
      if (cacheInf) {
        result = true
      }
    } catch (e) {
    }
    return result;
  }

  get(key: string): ArrayBuffer | undefined {
    if (!this.isInited) {
      BYLog.devDebug(TAG + `还未初始化`)
      return
    }

    if (this.lruCache.get(key) !== undefined) {
      // TODO 如何才能修改文件访问时间呢
      return BYFileUtil.getInstance().readFileSync(this.path + key)
    } else {
      BYLog.devDebug(TAG + `未找到缓存信息`)
    }
    return undefined
  }

  // 移除键为key的缓存
  remove(key: string): void {
    if (key == null) {
      BYLog.error('key is null,checking the parameter');
    }
    if (!this.isInited) {
      return
    }

    let remove: number | undefined = this.lruCache.remove(key)
    if (remove !== undefined) {
      BYFileUtil.getInstance().deleteFile(this.path + key)
      this.removeMemorySize(remove)
    }
  }

  async removeAll(): Promise<void> {
    if (!this.isInited) {
      return
    }
    this.lruCache.clear()
    this.currentMemory = 0;

    let filenames: string[] = await BYFileUtil.getInstance().ListFile(this.path)
    for (let i = 0; i < filenames.length; i++) {
      await BYFileUtil.getInstance().deleteFile(this.path + filenames[i])
    }
  }

  size(): number {
    return this.lruCache.length
  }

  // 移除较少使用的缓存数据
  private trimToSize(): void {
    while (true) {
      if (this.currentMemory <= this.maxMemory || this.lruCache.isEmpty()) {
        break
      }
      let delkey = this.lruCache.keys()[0]
      let remove: number | undefined = this.lruCache.remove(delkey)
      if (remove !== undefined) {
        BYFileUtil.getInstance().deleteFile(this.path + delkey)
        this.removeMemorySize(remove)
      }
      this.lruCache.remove(delkey)
    }
  }

  private removeMemorySize(value: ArrayBuffer | number): void {
    if (typeof value == 'number') {
      this.currentMemory -= value
    } else if (value != undefined) {
      this.currentMemory -= value.byteLength
      BYLog.debug('FileCache removeMemorySize: ' + value.byteLength + ' currentMemory：' + this.currentMemory)
    }
  }

  private addMemorySize(value: ArrayBuffer | number): void {
    if (typeof value == 'number') {
      this.currentMemory += value
      BYLog.debug('FileCache addMemorySize: ' + value + ' currentMemory：' + this.currentMemory)
    } else if (value != undefined) {
      this.currentMemory += value.byteLength
      BYLog.debug('FileCache addMemorySize: ' + value.byteLength + ' currentMemory：' + this.currentMemory)
    }
  }

  /**
   * 子线程里只写入缓存文件
   * @param context
   * @param key
   * @param value
   */
  static saveFileCacheOnlyFile(context: Context, key: string, value: ArrayBuffer,
    folder: string = BYDiskLruCache.CACHE_FOLDER): boolean {
    // 写文件
    BYFileUtil.getInstance()
      .writeFileSync(context.cacheDir + BYFileUtil.SEPARATOR + folder + BYFileUtil.SEPARATOR + key, value)
    return true
  }

  /**
   * 子线程中，通过文件名，直接查找是否有文件缓存
   * @param context
   * @param key
   * @returns
   */
  static getFileCacheByFile(context: Context, key: string,
    folder: string = BYDiskLruCache.CACHE_FOLDER): ArrayBuffer | undefined {
    // 从文件获取查看是否有缓存
    return BYFileUtil.getInstance()
      .readFileSync(context.cacheDir + BYFileUtil.SEPARATOR + folder + BYFileUtil.SEPARATOR + key)
  }

  /**
   * 获取key缓存数据绝对路径
   *
   * @params key 数值
   */
  getFileToPath(key: string): string {
    if (!!!key) {
      BYLog.error('key is null,checking the parameter')
      return ''
    }
    let path = this.path + key
    if (BYFileUtil.getInstance().exist(path)) {
      return path
    } else {
      return ''
    }
  }
}