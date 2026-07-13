import { BYConstant } from '../basic/BYConstant'
import { BYLifecycle } from '../basic/BYLifecycle'
import { BYLog } from '../basic/BYLog'
import { AdvanceConstant } from './define/AdvanceConstant'
import { common } from '@kit.AbilityKit'
import { AdvanceSetting } from './config/AdvanceSetting'
import { BYSetting } from '../../../../../Index'
import { AdvCustomAdnCacheManager, AdvCustomAdnListInfo } from './cache/AdvCustomAdnCacheManager'
import AdvanceNetwork from './net/AdvanceNetwork'

export class AdvanceSDK {
  //初始化SDK
  static initSDK(context: Context, appId: string) {
    AdvanceSetting.get().appId = appId
    BYConstant.context = context as common.UIAbilityContext
    BYLifecycle.registerLife(context)
    AdvanceSDK.updateCustomAdnListInfo()
  }

  //调试模式
  static debug() {
    BYSetting.get().isDev = true
    BYLog.setShowLog(true)
  }

  //使用https
  static useHttps() {
    AdvanceSetting.get().useHttps = true
  }

  //当前版本号
  static getSDKVersion(): string {
    return AdvanceConstant.ADV_SDK_VERSION_NAME
  }

  private static updateCustomAdnListInfo() {
    // 从缓存中获取adn_list信息
    const cacheInfo = AdvCustomAdnCacheManager.customAdnListInfo()
    AdvanceNetwork.shared().getCustomAdnListInfo(cacheInfo?.version).then((info: AdvCustomAdnListInfo) => {
      // 更新adn_list缓存
      if (info.custom_adn_list && info.custom_adn_list.length) {
        AdvCustomAdnCacheManager.cacheCustomAdnListInfo(info)
      }
    })
  }
}