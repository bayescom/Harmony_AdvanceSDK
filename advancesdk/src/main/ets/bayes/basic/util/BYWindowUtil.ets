import { BYApp, BYConstant } from "../../../../../../Index"
import { window } from "@kit.ArkUI";


//默认的子窗口名称
export const SUB_WINDOW_NAME_DEFAULT = 'AdvanceSubWindow'

/**
 * 窗口工具类
 */
export class BYWindowUtil {

  static async createWindow(content: string, adName: string, object: object) {
    let windowStage = BYConstant.windowStage
    if (!windowStage) {
      windowStage = BYApp.getWindowStage()
    }
    try {
      //创建窗口
      let subWindow = await windowStage.createSubWindow(SUB_WINDOW_NAME_DEFAULT)
      let storage: LocalStorage = new LocalStorage()
      storage.setOrCreate(adName, object)
      await subWindow.setWindowLayoutFullScreen(true)
      await subWindow.loadContentByName(content, storage)
      //窗口设置透明
      subWindow.setWindowBackgroundColor('#00000000')
      await subWindow.showWindow()
    } catch (err) {
      console.log('创建子窗口失败')
    }
  }

  static destroySubWindow() {
    let subWindow = window.findWindow(SUB_WINDOW_NAME_DEFAULT)
    if (subWindow) {
      subWindow.destroyWindow()
    }
  }

}