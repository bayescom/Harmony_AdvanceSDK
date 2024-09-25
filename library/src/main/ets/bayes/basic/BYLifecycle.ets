import { AbilityLifecycleCallback, ApplicationStateChangeCallback, Context, UIAbility } from '@kit.AbilityKit'
import { window } from '@kit.ArkUI'
import BYConstant from './BYConstant'
import { BYLog } from './BYLog'
import { BYSingleton } from './BYSingleton'


const TAG = '[BYLifecycle] '

//检测当前应用的生命周期事件
export class BYLifecycle {
  static registerLife(ctx: Context) {
    try {
      let context = ctx.getApplicationContext()
      let lifecycleId = context?.on('abilityLifecycle', new BYAbilityLifecycleCallback())
      BYLog.devDebug(TAG + `registerLife ,lifecycleId = ${lifecycleId}`)

      // 监听应用程序状态变化
      // 创建一个EntryApplicationStateChangeCallback实例来处理状态变化
      context?.on('applicationStateChange', new BYApplicationStateChangeCallback());
    } catch (e) {
      BYLog.printE(e)
    }
  }
}

class BYAbilityLifecycleCallback extends AbilityLifecycleCallback {
  // 当Ability创建时触发
  onAbilityCreate(ability: UIAbility): void {
    // 在这里可以执行Ability创建后的初始化操作
    // ...
    BYLog.devDebug(TAG + `--BYAbilityLifecycleCallback-- onAbilityCreate (应用启动)，ability = ${ability}`)
  }

  // 当WindowStage创建时触发
  onWindowStageCreate(ability: UIAbility, windowStage: window.WindowStage): void {
    // 在这里可以执行WindowStage创建后的初始化操作
    // ...

    if (windowStage) {
      BYConstant.windowStage = windowStage
    }
    BYLog.devDebug(TAG +
      `--BYAbilityLifecycleCallback-- onWindowStageCreate (WindowStage创建) ，ability = ${ability} , windowStage = ${windowStage}`)

  }

  // 当页面获取到焦点时触发
  onWindowStageActive(ability: UIAbility, windowStage: window.WindowStage): void {
    // 在这里可以执行页面激活时的操作，如恢复状态、刷新数据等
    // ...
    if (windowStage) {
      BYConstant.windowStage = windowStage
    }

    BYLog.devDebug(TAG +
      `--BYAbilityLifecycleCallback-- onWindowStageActive (WindowStage获取到焦点) ，ability = ${ability} , windowStage = ${windowStage}`)

  }

  // 当WindowStage失焦时触发
  onWindowStageInactive(ability: UIAbility, windowStage: window.WindowStage): void {
    // 在这里可以执行页面失焦时的操作，如暂停动画、保存状态等
    // ...

    BYLog.devDebug(TAG +
      `--BYAbilityLifecycleCallback-- onWindowStageInactive (WindowStage失焦)，ability = ${ability} , windowStage = ${windowStage}`)

  }

  // 当WindowStage销毁时触发
  onWindowStageDestroy(ability: UIAbility, windowStage: window.WindowStage): void {
    // 在这里可以执行WindowStage销毁前的清理操作
    // ...

    BYLog.devDebug(TAG +
      `--BYAbilityLifecycleCallback-- onWindowStageDestroy (WindowStage销毁)，ability = ${ability} , windowStage = ${windowStage}`)

  }

  // 当Ability销毁时触发
  onAbilityDestroy(ability: UIAbility): void {
    // 在这里可以执行Ability销毁前的清理操作
    // ...

    BYLog.devDebug(TAG + `--BYAbilityLifecycleCallback-- onAbilityDestroy (Ability销毁)，ability = ${ability}  `)

  }

  // 当Ability进入前台时触发
  onAbilityForeground(ability: UIAbility): void {
    // 在这里可以执行Ability进入前台时的操作，如恢复暂停的动画等
    // ...

    BYLog.devDebug(TAG + `--BYAbilityLifecycleCallback-- onAbilityForeground (Ability进入前台)，ability = ${ability}  `)

  }

  // 当Ability进入后台时触发
  onAbilityBackground(ability: UIAbility): void {
    // 在这里可以执行Ability进入后台时的操作，如暂停动画、保存状态等
    // ...

    BYLog.devDebug(TAG +
      `--BYAbilityLifecycleCallback-- onAbilityForeground (Ability移入'后台‘)，ability = ${ability}  `)

  }

  // 当Ability从暂停状态恢复时触发
  onAbilityContinue(ability: UIAbility): void {
    // 在这里可以执行Ability恢复时的操作，如继续动画等
    // ...

    BYLog.devDebug(TAG +
      `--BYAbilityLifecycleCallback-- onAbilityContinue (Ability从暂停状态恢复)，ability = ${ability}  `)

  }
}


class BYApplicationStateChangeCallback extends ApplicationStateChangeCallback {
  // 当应用程序进入前台时触发
  onApplicationForeground(): void {
    // 在这里可以执行应用程序进入前台时的操作，如恢复网络请求等
    // ...

    BYLog.devDebug(TAG + `--BYApplicationStateChangeCallback-- onApplicationForeground (当应用程序进入前台时触发)  `)

  }

  // 当应用程序进入后台时触发
  onApplicationBackground(): void {
    // 在这里可以执行应用程序进入后台时的操作，如暂停动画、停止网络请求等
    // ...

    BYLog.devDebug(TAG + `--BYApplicationStateChangeCallback-- onApplicationBackground (应用程序进入’后台‘时触发)  `)

  }
}