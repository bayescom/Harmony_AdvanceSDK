import { BYLog } from '../../../basic/BYLog'
import { AdvCSJSplashAdapter } from '../../adapter/csj/AdvCsjSplashAdapter'
import { AdvanceADNUnitData } from './AdvanceADNUnitData'
import AdvanceConstant from '../../model/AdvanceConstant'
import { AdvanceADNCommonAdapter } from './AdvanceADNCommonAdapter'
import { AdvCsjFeedAdapter } from '../../adapter/csj/AdvCsjFeedAdapter'
import { AdvCsjNativeAdapter } from '../../adapter/csj/AdvCsjNativeAdapter'

export class AdvanceADNManger {
  //生成对应adapter实现类
  static generateAdnAdapter(adnData: AdvanceADNUnitData, context: Context): AdvanceADNCommonAdapter | undefined {
    let result: AdvanceADNCommonAdapter | undefined = undefined

    try {
      let sdkId = adnData.supplier?.id
      switch (adnData.adType) {
        case AdvanceConstant.ADV_AD_TYPE_SPLASH:
          if (sdkId == AdvanceConstant.ADV_SDK_ID_CSJ) {
            result = new AdvCSJSplashAdapter(adnData, context.getApplicationContext())
          }
          break

        case AdvanceConstant.ADV_AD_TYPE_FEED:
          if (sdkId == AdvanceConstant.ADV_SDK_ID_CSJ) {
            result = new AdvCsjFeedAdapter(adnData, context.getApplicationContext())
          }
          break
        case AdvanceConstant.ADV_AD_TYPE_NATIVE:
          if (sdkId == AdvanceConstant.ADV_SDK_ID_CSJ) {
            result = new AdvCsjNativeAdapter(adnData, context.getApplicationContext())
          }
          break
      }
    } catch (e) {
      BYLog.printE(e)
    }
    BYLog.debug(`generateAdnAdapter , result = ${result}`)

    return result
  }
}