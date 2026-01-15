import hilog from '@ohos.hilog'
import { BYSetting } from './BYSetting'
import { BYSingleton } from './BYSingleton'

const LOGGER_DOMAIN: number = 0x0000
const LOGGER_TAG: string = 'BYLog'

/**
 * 日志工具类
 */
export class BYLog {
  private static domain: number = LOGGER_DOMAIN
  private static tag: string = LOGGER_TAG //日志Tag
  private static format: string = '%{public}s'
  private static showLog: boolean = false //是否显示打印日志


  /**
   * 初始化日志参数（该方法建议在Ability里调用）
   * @param domain
   * @param tag
   * @param showLog
   */
  static init(domain: number = LOGGER_DOMAIN, tag: string = LOGGER_TAG, showLog: boolean = true) {
    BYLog.domain = domain
    BYLog.tag = tag
    BYLog.showLog = showLog
  }

  /**
   * 设置日志对应的领域标识，范围是0x0~0xFFFF。（该方法建议在Ability里调用）
   * @param domain
   */
  static setDomain(domain: number = LOGGER_DOMAIN) {
    BYLog.domain = domain
  }

  /**
   * 设置日志标识（该方法建议在Ability里调用）
   * @param tag
   */
  static setTag(tag: string = LOGGER_TAG) {
    BYLog.tag = tag
  }

  /**
   * 是否打印日志（该方法建议在Ability里调用）
   * @param showLog
   */
  static setShowLog(showLog: boolean = true) {
    BYLog.showLog = showLog
  }

  /**
   * 打印DEBUG级别日志
   * @param args
   */
  static debug(...args: string[]): void {
    if (BYLog.showLog) {
      BYLog.logInfo(args.toString())
      // hilog.debug(BYLog.domain, BYLog.tag, BYLog.format.repeat(args.length), args)
    }
  }

  static devDebug(...args: string[]): void {
    if (BYLog.showDevLog()) {
      BYLog.logInfo("-dev-" + args.toString())
      // hilog.debug(BYLog.domain, BYLog.tag + "-dev", BYLog.format.repeat(args.length), args)
    }
  }

  static showDevLog(): boolean {
    return BYLog.showLog && BYSetting.get().isDev && BYSingleton.get().debug
  }


  /**
   * 打印INFO级别日志
   * @param args
   */
  static info(...args: string[]): void {
    if (BYLog.showLog) {
      hilog.info(BYLog.domain, BYLog.tag, BYLog.format.repeat(args.length), args)
    }
  }

  /**
   * 打印WARN级别日志
   * @param args
   */
  static warn(...args: string[]): void {
    if (BYLog.showLog) {
      hilog.warn(BYLog.domain, BYLog.tag, BYLog.format.repeat(args.length), args)
    }
  }

  /**
   * 打印ERROR级别日志
   * @param args
   */
  static error(...args: string[]): void {
    if (BYLog.showLog) {
      hilog.error(BYLog.domain, BYLog.tag, BYLog.format.repeat(args.length), args)
    }
  }

  /**
   * 打印FATAL级别日志
   * @param args
   */
  static fatal(...args: string[]): void {
    if (BYLog.showLog) {
      hilog.fatal(BYLog.domain, BYLog.tag, BYLog.format.repeat(args.length), args)
    }
  }

  static printJson(resp: object) {
    try {
      if (BYLog.showLog) {
        BYLog.debug('printJson:' + JSON.stringify(resp))
      }
    } catch (e) {
    }
  }

  static printE(e: object) {
    try {
      if (BYLog.showLog) {
        let error = e as Error;
        let name = error.name;
        let msg = error.message;
        let stack = error.stack

        let inf = `printE , name : ${name} , msg : ${msg} , stack =  ` + stack
        BYLog.error(inf)
      }
    } catch (e) {
    }

  }

  /**
   * 打印JSON对象和JSON字符串
   * @param obj
   */
  // static printJson(obj: object | string) {
  //   try {
  //     if (typeof obj === 'object') {
  //       let str = JSON.stringify(obj, null, 2)
  //       let arr: string[] = str.split('\n')
  //       for (let index = 0; index < arr.length; index++) {
  //         console.debug(arr[index])
  //       }
  //     } else {
  //       obj = JSON.parse(obj)
  //       let str = JSON.stringify(obj, null, 2)
  //       let arr = str.split('\n')
  //       for (let index = 0; index < arr.length; index++) {
  //         console.debug(arr[index])
  //       }
  //     }
  //   } catch (err) {
  //     let error = err as BusinessError; //异常了，说明不是JSON字符串
  //     LogUtil.error(`LogUtil-print-异常 ~ code: ${error.code} -·- message: ${error.message}`);
  //   }
  // }

  static logInfo(content: string) {
    const maxSize = 3072; // 日志内容的最大长度限制

    // 如果内容长度小于等于最大长度限制，直接打印
    if (content.length <= maxSize) {
      hilog.info(BYLog.domain, BYLog.tag, '%{public}s', content);
    } else {
      // 循环分段打印
      while (content.length > maxSize) {
        let logContent = content.substring(0, maxSize); // 获取当前段的内容
        content = content.substring(maxSize); // 更新剩余内容（注意这里使用substring而不是replace）
        hilog.info(BYLog.domain, BYLog.tag, '%{public}s', logContent); // 打印当前段
      }

      // 打印剩余日志（如果最后一段不为空）
      if (content.length > 0) {
        hilog.info(BYLog.domain, BYLog.tag, '%{public}s', content);
      }
    }
  }
}

// export default new LogUtil() //单例（在ES6模块中，当你使用 import 导入一个模块时，实际上是在导入该模块的值的一个引用。这意味着在另一个模块中修改该值会影响原始模块中的值。）