import { CSJAdSdk, CSJCustomPrivacyController, SDKConfig, SDKConfigBuilder, StartResult } from '@csj/openadsdk'
import { AdvanceUtil } from '../../core/AdvanceUtil'
import { AdvanceADNUnitData } from '../../model/AdvanceADNUnitData'
import BYConstant from '../../../basic/BYConstant'
import { common } from '@kit.AbilityKit'
import { AdvCsjPrivacy } from './AdvCsjPrivacy'
import { BYSingleton } from '../../../basic/BYSingleton'

export class AdvCsjUtil {
  static init(adData: AdvanceADNUnitData): Promise<StartResult> {


    if (adData && adData.supplier) {

      let adConfigBuilder = new SDKConfigBuilder()
      let configBuilder: SDKConfigBuilder = adConfigBuilder
        .appId(adData.supplier.mediaid)
        .appName("name")
        .allowShowNotify(true)// .customController(  )
        .debug(BYSingleton.get().debug)

      let advPrivacy = AdvanceUtil.getAdvancePrivacy()
      if (advPrivacy) {
        let csjPrivacy = new AdvCsjPrivacy(advPrivacy)
        configBuilder.customController(csjPrivacy)
      }

      let config: SDKConfig = configBuilder.build()
      CSJAdSdk.init(BYConstant.context as common.UIAbilityContext, config)

      return CSJAdSdk.start()
    } else {

    }


    return new Promise<StartResult>((resolve) => {
      let result = new StartResult(-1, '无广告信息')
      resolve(result)
    })
  }
}