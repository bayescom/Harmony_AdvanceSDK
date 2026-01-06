import { display } from '@kit.ArkUI';
import { BYLog } from './BYLog';
import { BYUtil } from './BYUtil';

export class BYDisplay {
  static getScreenWPX(): number {
    let result = 0

    try {
      let displayClass: display.Display | null = null;

      displayClass = display.getDefaultDisplaySync();
      result = displayClass.width
    } catch (e) {
      BYLog.printE(e)
    }

    return result
  }

  static getScreenHPX(): number {
    let result = 0

    try {
      let displayClass: display.Display | null = null;

      displayClass = display.getDefaultDisplaySync();
      result = displayClass.height
    } catch (e) {
      BYLog.printE(e)
    }

    return result
  }

  static getScreenHVP(): number {
    let result = 0

    try {
      let des = BYDisplay.getScreenDensity()
      result = BYDisplay.getScreenHPX() / des
    } catch (e) {
      BYLog.printE(e)
    }

    return result
  }


  static getScreenWVP(): number {
    let result = 0

    try {
      let des = BYDisplay.getScreenDensity()
      result = BYDisplay.getScreenWPX() / des
    } catch (e) {
      BYLog.printE(e)
    }

    return result
  }

//   static getStatusHeight():number{
//     let result = 0
//
//   const statusBarAvoidArea = windowClass.getWindowAvoidArea(window.AvoidAreaType.TYPE_SYSTEM);
//     result = statusBarAvoidArea.topRect.height;
//
//     return result
// }


  static getScreenDPI(): number {
    let result = 0

    try {
      let displayClass: display.Display | null = null;

      displayClass = display.getDefaultDisplaySync();
      result = displayClass.densityDPI
    } catch (e) {
      BYLog.printE(e)
    }

    return result
  }

  static getScreenDensity(): number {
    let result = 0

    try {
      let displayClass: display.Display | null = null;

      displayClass = display.getDefaultDisplaySync();
      result = displayClass.densityPixels
    } catch (e) {
      BYLog.printE(e)
    }

    return result
  }


  static getScreenPPI(): number {
    let result = 0

    try {
      let displayClass: display.Display | null = null;

      displayClass = display.getDefaultDisplaySync();

      let w = displayClass.width;
      let h = displayClass.height;
      //获取宽高的英寸
      let width = w / displayClass.xDPI;
      let height = h / displayClass.yDPI;
      //对接线英寸值，即手机英寸
      let size = Math.sqrt(width * width + height * height);
      //对接线像素值/英寸 得到像素密度
      result = (Math.sqrt(w * w + h * h) / size)
      //转换小数为整数
      result = BYUtil.caseNumberInt(result)
    } catch (e) {
      BYLog.printE(e)
    }

    return result
  }

  static vp2Px(vpNum: number): number {
    let result = 0
    try {
      let des = BYDisplay.getScreenDensity()
      result = BYUtil.caseNumberInt(des * vpNum)
    } catch (e) {
    }
    return result
  }

  static px2VP(pxNum: number): number {
    let result = 0
    try {
      let des = BYDisplay.getScreenDensity()
      result = BYUtil.caseNumberInt(pxNum / des)
    } catch (e) {
    }
    return result
  }
}