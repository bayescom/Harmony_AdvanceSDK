import fs from '@ohos.file.fs';
import { BusinessError } from '@ohos.base';
import { BYLog } from '../BYLog';


export class BYFileUtil {
  static readonly SEPARATOR: string = '/'
  private static sInstance: BYFileUtil

  private constructor() {
  }

  /**
   * 单例实现FileUtils类
   */
  public static getInstance(): BYFileUtil {
    if (!BYFileUtil.sInstance) {
      BYFileUtil.sInstance = new BYFileUtil();
    }
    return BYFileUtil.sInstance;
  }

  /**
   * 删除文件
   *
   * @param path 文件绝对路径及文件名
   */
  deleteFileSync(path: string): boolean {
    try {
      let fileExist = fs.accessSync(path);
      if (fileExist) {
        fs.unlinkSync(path);
      }
      return true
    } catch (err) {
      BYLog.error('FileUtils deleteFileSync failed: err msg=' + err.message + ' err code=' + err.code);
      return false
    }
  }

  /**
   * 异步删除文件
   * @param path
   * @returns
   */
  async deleteFile(path: string): Promise<void> {
    try {
      await fs.unlink(path)
    } catch (err) {
      BYLog.error('FileUtils deleteFile failed: err msg=' + err.message + ' err code=' + err.code);
    }
  }

  /**
   * 向path写入数据
   *
   * @param path 文件绝对路径
   * @param content 文件内容
   */
  writeDataSync(path: string, content: ArrayBuffer | string): boolean {
    try {
      let fd = fs.openSync(path, fs.OpenMode.READ_WRITE | fs.OpenMode.CREATE | fs.OpenMode.TRUNC).fd
      fs.writeSync(fd, content)
      fs.closeSync(fd)
      return true
    } catch (err) {
      BYLog.error('FileUtils writeDataSync failed: err msg=' + err.message + ' err code=' + err.code);
      return false
    }
  }

  /**
   * 异步向path写入数据
   *
   * @param path 文件绝对路径
   * @param content 文件内容
   */
  async writeData(path: string, content: ArrayBuffer | string): Promise<boolean> {
    try {
      let fd = (await fs.open(path, fs.OpenMode.READ_WRITE | fs.OpenMode.CREATE)).fd
      let stat = await fs.stat(path)
      await fs.write(fd, content, { offset: stat.size })
      await fs.close(fd)
      return true
    } catch (err) {
      BYLog.error('FileUtils writeData failed: err msg=' + err.message + ' err code=' + err.code);
      return false
    }
  }

  /**
   * 判断path文件是否存在
   *
   * @param path 文件绝对路径
   */
  exist(path: string): boolean {
    try {
      if (fs.accessSync(path)) {
        let stat = fs.statSync(path)
        return stat.isFile()
      } else {
        return false
      }
    } catch (error) {
      let err: BusinessError = error as BusinessError;
      BYLog.error('FileUtils exist failed with error message: ' + err.message + ', error code: ' + err.code);
    }
    return false
  }

  /**
   * 获取path的文件大小
   *
   * @param path 文件绝对路径
   */
  getFileSizeSync(path: string): number {
    try {
      let stat = fs.statSync(path)
      return stat.size
    } catch (e) {
      BYLog.error('FileUtils getFileSize e ' + e)
      return -1
    }
  }

  /**
   * 读取路径path的文件
   *
   * @param path 文件绝对路径
   */
  readFileSync(path: string): ArrayBuffer | undefined {
    try {
      if (fs.accessSync(path)) {
        let length = fs.statSync(path).size
        let buf = new ArrayBuffer(length);
        let fd = fs.openSync(path, fs.OpenMode.READ_ONLY).fd;
        fs.readSync(fd, buf)
        fs.closeSync(fd)
        return buf
      }
    } catch (error) {
      let err: BusinessError = error as BusinessError;
      BYLog.error('FileUtils readFileSync failed with error message: ' + err.message + ', error code: ' + err.code);
    }
    return undefined
  }

  /**
   * 读取路径path的文件
   *
   * @param path 文件绝对路径
   */
  async readFile(path: string): Promise<ArrayBuffer | undefined> {
    try {
      let stat = await fs.stat(path);
      let fd = (await fs.open(path, fs.OpenMode.READ_ONLY)).fd;
      let length = stat.size;
      let buf = new ArrayBuffer(length);
      await fs.read(fd, buf);
      await fs.close(fd)
      return buf
    } catch (error) {
      let err: BusinessError = error as BusinessError;
      BYLog.error('FileUtils readFile failed with error message: ' + err.message + ', error code: ' + err.code);
    }
    return undefined
  }

  /**
   * 创建文件夹
   *
   * @param path 文件夹绝对路径，只有是权限范围内的路径，可以生成
   * @param recursive
   */
  createFolderSync(path: string, recursive?: boolean) {
    try {
      if (recursive) {
        if (!this.existFolder(path)) {
          let lastInterval = path.lastIndexOf(BYFileUtil.SEPARATOR)
          if (lastInterval == 0) {
            return
          }
          let newPath = path.substring(0, lastInterval)
          this.createFolderSync(newPath, true)
          if (!this.existFolder(path)) {
            fs.mkdirSync(path)
          }
        }
      } else {
        if (!this.existFolder(path)) {
          fs.mkdirSync(path)
        }
      }
    } catch (e) {
      BYLog.error('FileUtils createFolder err : ' + e)
    }
  }

  createFolder(path: string): boolean {
    try {
      let isExist: boolean = fs.accessSync(path)
      if (!isExist) {
        fs.mkdirSync(path)
      }
      return true
    } catch (error) {
      let err: BusinessError = error as BusinessError;
      BYLog.error('FileUtils createFolder failed with error message: ' + err.message + ', error code: ' + err.code);
    }
    return false
  }

  /**
   * 判断文件夹是否存在
   *
   * @param path 文件夹绝对路径
   */
  existFolder(path: string): boolean {
    try {
      if (fs.accessSync(path)) {
        let stat = fs.statSync(path)
        return stat.isDirectory()
      } else {
        return false
      }
    } catch (error) {
      let err: BusinessError = error as BusinessError;
      BYLog.error('FileUtils existFolder failed with error message: ' + err.message + ', error code: ' + err.code);
    }
    return false
  }

  writeFileSync(path: string, content: ArrayBuffer | string): boolean {
    try {
      let fd = fs.openSync(path, fs.OpenMode.READ_WRITE | fs.OpenMode.CREATE).fd
      fs.truncateSync(fd)
      fs.writeSync(fd, content)
      fs.closeSync(fd)
      return true
    } catch (err) {
      BYLog.error('FileUtils writeFileSync failed with error message: ' + err.message + ', error code: ' + err.code);
    }
    return false
  }

  ListFileSync(path: string): string[] {
    try {
      return fs.listFileSync(path)
    } catch (err) {
      BYLog.error('FileUtils ListFileSync failed with error message: ' + err.message + ', error code: ' + err.code);
    }
    return []
  }

  async ListFile(path: string): Promise<string[]> {
    try {
      return fs.listFile(path)
    } catch (err) {
      BYLog.error('FileUtils ListFile failed with error message: ' + err.message + ', error code: ' + err.code);
    }
    return []
  }

  StatSync(path: string): fs.Stat | undefined {
    try {
      return fs.statSync(path)
    } catch (err) {
      BYLog.error('FileUtils StatSync failed with error message: ' + err.message + ', error code: ' + err.code);
    }
    return undefined
  }

  async Stat(path: string): Promise<fs.Stat | undefined> {
    try {
      return fs.stat(path)
    } catch (err) {
      BYLog.error('FileUtils Stat failed with error message: ' + err.message + ', error code: ' + err.code);
    }
    return undefined
  }
}