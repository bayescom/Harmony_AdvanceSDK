import { BYAbsCall } from './itf/BYAbsCall'
import { BYLog } from './BYLog';
import { BYCall } from './itf/BYCall';
import { crypto } from './util/crypto';
import { CryptoUtil } from './util/CryptoUtil';
import { Decimal, util } from '@kit.ArkTS';
import { BYStrUtil } from './util/BYStrUtil';
import { BYDevice } from './BYDevice';
import { window } from '@kit.ArkUI';
import { BYSetting } from './BYSetting';
import { BYConstant, BY_CACHE_KEY_UA } from './BYConstant';
import { BYDisplay } from './BYDisplay';
import { BYCacheUtil, CACHE_TIME_MONTH } from './cache/BYCacheUtil';

export class BYUtil {
  static isDev(): boolean {
    return BYSetting.get().isDev
  }

  /**
   * 运行异步获取指定类型得方法，用catch方法包裹 避免出现crash
   * @param getter
   * @param defaultValue
   * @returns
   */
  static async runCatchMethod<T>(getter: BYAbsCall<T>, defaultValue: T): Promise<T> {
    let result: T = defaultValue
    try {
      //等待异步获取结果
      result = await getter.call();
    } catch (e) {
      BYLog.printE(e)
    }
    return result;
  }


  static runCatchMethodCallBack() {

  }


  static runWithCatch(caller?: BYCall) {
    try {
      caller?.call()
    } catch (e) {
      BYLog.printE(e)
    }
  }


  /**
   * MD5摘要，同步
   * @param data 待摘要的数据
   * @param resultCoding 摘要的编码方式（base64/hex），默认不传为hex。
   * @returns
   */
  static async getMD5(data: string, resultCoding: crypto.BhCoding = 'hex'): Promise<string> {
    return CryptoUtil.digest(data, 'MD5', resultCoding);
  }

  static getReqID(): string {
    let result = util.generateRandomUUID()
    try {
      result = BYStrUtil.replaceAll(result, "-", "").toLowerCase()
    } catch (e) {
      BYLog.printE(e)
    }
    return result
  }

  //将number转成整形并四舍五入
  static caseNumberInt(oriNum: number): number {
    let result = oriNum
    try {
      //减去0.5以后进行向上取整
      let calNum = oriNum - 0.5
      result = new Decimal(calNum).ceil().toNumber()
      // BYLog.debug(`caseNumberInt ,oriNum = ${oriNum} ,calNum = ${calNum} , result = ${result}`)
    } catch (e) {
      BYLog.printE(e)
    }
    return result
  }

  //将number保留两位有效数字
  static keep2PointNumber(oriNum: number): number {
    let result = oriNum
    try {
      let intResult = BYUtil.caseNumberInt(oriNum * 100)
      result = intResult / 100
    } catch (e) {
    }

    return result
  }

  static keep1PointNumber(oriNum: number): number {
    let result = oriNum
    try {
      let intResult = BYUtil.caseNumberInt(oriNum * 10)
      result = intResult / 10
    } catch (e) {
    }

    return result
  }

  static async initStatusHeight() {
    try {
      let windowStage = BYConstant.windowStage
      let mainWin = await windowStage.getMainWindow()
      let statusBarAvoidArea = mainWin.getWindowAvoidArea(window.AvoidAreaType.TYPE_SYSTEM)
      let h = statusBarAvoidArea.topRect.height
      //源单位是px
      let barHVP = BYDisplay.px2VP(h)
      BYSetting.get().statusBarHeightVP = barHVP

      let navigationBarAvoidArea = mainWin.getWindowAvoidArea(window.AvoidAreaType.TYPE_NAVIGATION_INDICATOR);
      let navH = navigationBarAvoidArea.bottomRect.height;
      let navHVP = BYDisplay.px2VP(navH)
      BYSetting.get().navigationBarHeightVP = navHVP;

      BYLog.debug(`initStatusHeight result navHVP = ${navHVP} , barHVP = ${barHVP} `)
    } catch (e) {
    }
  }
}