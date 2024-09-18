import { BYLog } from '../../basic/BYLog'
import { AdvCSJSplashAdapter } from '../adapter/csj/AdvCsjSplashAdapter'
import { AdvanceADNUnitData } from '../model/AdvanceADNUnitData'
import AdvanceConstant from '../model/AdvanceConstant'
import { AdvanceADNCommonAdapter } from './AdvanceADNCommonAdapter'

export class AdvanceADNManger{
  //获取对应adapter实现类
  static getAdnAdapter(adnData: AdvanceADNUnitData): AdvanceADNCommonAdapter | undefined {
    let result: AdvanceADNCommonAdapter | undefined = undefined

    try {
      switch (adnData.adType){
        case AdvanceConstant.ADV_AD_TYPE_SPLASH:
          let sdkId = adnData.supplier?.id
          if (sdkId == AdvanceConstant.ADV_SDK_ID_CSJ) {
            result = new AdvCSJSplashAdapter(adnData)
          }
          break
      }
    } catch (e) {
      BYLog.printE(e)
    }
    BYLog.debug(`getAdnAdapter , result = ${result}`)

    return result
  }
}