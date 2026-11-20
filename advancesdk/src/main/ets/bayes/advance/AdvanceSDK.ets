import { BYConstant } from '../basic/BYConstant'
import { BYLifecycle } from '../basic/BYLifecycle'
import { BYLog } from '../basic/BYLog'
import { AdvanceConstant } from './define/AdvanceConstant'
import { common } from '@kit.AbilityKit'
import { AdvanceSetting } from './config/AdvanceSetting'
import { BYSetting } from '../basic/BYSetting'
import { AdvCustomAdnCacheManager, AdvCustomAdnListInfo } from './cache/AdvCustomAdnCacheManager'
import AdvanceNetwork from './net/AdvanceNetwork'
import { AdvanceError, ADV_ERR_SDK_INIT_FAILED } from './define/AdvanceError'
import { AdvanceAdapterRepository } from './core/adn/AdvanceAdapterRepository'

export class AdvanceSDK {

  static start(context: Context, appId: string): Promise<AdvanceError | undefined> {
    return new Promise<AdvanceError | undefined>((resolve) => {
      if (!appId) {
        resolve(new AdvanceError(ADV_ERR_SDK_INIT_FAILED, 'SDK初始化失败：appId不能为空'))
        return
      }

      AdvanceSetting.get().appId = appId
      BYConstant.context = context as common.UIAbilityContext
      BYLifecycle.registerLife(context)
      AdvanceAdapterRepository.loadBuiltInAdapterDescriptors()

      const cacheInfo = AdvCustomAdnCacheManager.customAdnListInfo()
      if (cacheInfo) {
        AdvanceAdapterRepository.syncCustomAdaptersWithAdnList(cacheInfo.custom_adn_list)
        resolve(undefined)
        AdvanceSDK.updateCustomAdnListInfo(cacheInfo.version)
        return
      }

      // 首次无缓存，获取并保存自定义渠道配置后才完成初始化。
      AdvanceNetwork.shared().getCustomAdnListInfo().then((info: AdvCustomAdnListInfo) => {
        AdvCustomAdnCacheManager.cacheCustomAdnListInfo(info)
        AdvanceAdapterRepository.syncCustomAdaptersWithAdnList(info.custom_adn_list)
        resolve(undefined)
      }).catch((error: AdvanceError) => {
        resolve(error)
      })
    })
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

  private static updateCustomAdnListInfo(version?: string) {
    AdvanceNetwork.shared().getCustomAdnListInfo(version).then((info: AdvCustomAdnListInfo) => {
      if (info.custom_adn_list && info.custom_adn_list.length) {
        AdvCustomAdnCacheManager.cacheCustomAdnListInfo(info)
        AdvanceAdapterRepository.syncCustomAdaptersWithAdnList(info.custom_adn_list)
      }
    }).catch((error: AdvanceError) => {
      BYLog.printE(error)
    })
  }
}
