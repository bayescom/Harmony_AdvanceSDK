import { common } from "@kit.AbilityKit";
import { BYConstant } from "./BYConstant";
import { window } from "@kit.ArkUI";

export class BYApp {
  /**
   * 获取上下文，common.UIAbilityContext
   * @returns
   */
  static getContext(): common.UIAbilityContext {
    if (!BYConstant.context) {
      BYConstant.context = getContext() as common.UIAbilityContext; //兜底
    }
    return BYConstant.context;
  }

  /**
   * 获取应用级别的上下文的能力，ApplicationContext
   * @returns
   */
  static getApplicationContext():common.ApplicationContext{
    return BYApp.getContext().getApplicationContext();
  }

  /**
   * 获取UIContext
   * @returns
   */
  static getUIContext(): UIContext {
    return BYApp.getMainWindow().getUIContext();
  }

  /**
   * 获取WindowStage
   * @returns
   */
  static getWindowStage(): window.WindowStage {
    return BYApp.getContext().windowStage;
  }

  /**
   * 获取主窗口
   */
  static getMainWindow(): window.Window {
    return BYApp.getContext().windowStage.getMainWindowSync();
  }

}