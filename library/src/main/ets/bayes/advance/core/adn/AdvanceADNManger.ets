import { BYLog } from '../../../basic/BYLog'
import { BYCacheUtil } from '../../../basic/util/BYCacheUtil'
import { AdvCSJSplashAdapter } from '../../adapter/csj/AdvCsjSplashAdapter'
import { AdvanceADNUnitData } from './AdvanceADNUnitData'
import AdvanceConstant from '../../model/AdvanceConstant'
import { AdvanceADNCommonAdapter } from './AdvanceADNCommonAdapter'

export class AdvanceADNManger {
  //获取对应adapter实现类
  static getAdnAdapter(adnData: AdvanceADNUnitData, context: Context): AdvanceADNCommonAdapter | undefined {
    let result: AdvanceADNCommonAdapter | undefined = undefined

    try {
      // let cacheKey = AdvanceADNManger.getAdnCacheKey(adnData)
      // let cacheAdapter = BYCacheUtil.get<AdvanceADNCommonAdapter | undefined>(cacheKey)
      // if (cacheAdapter && cacheAdapter.cacheValue) {
      //   BYLog.debug(`getAdnAdapter 使用已缓存得adapter`)
      //   // 使用缓存得
      //   return cacheAdapter.cacheValue
      // }
      switch (adnData.adType) {
        case AdvanceConstant.ADV_AD_TYPE_SPLASH:
          let sdkId = adnData.supplier?.id
          if (sdkId == AdvanceConstant.ADV_SDK_ID_CSJ) {
            result = new AdvCSJSplashAdapter(adnData, context.getApplicationContext())
          }
          break
      }
    } catch (e) {
      BYLog.printE(e)
    }
    BYLog.debug(`getAdnAdapter , result = ${result}`)

    return result
  }
  //
  // static getAdnCacheKey(adnData: AdvanceADNUnitData): string {
  //   let result = ''
  //   try {
  //     result += adnData.groupID
  //     let sup = adnData.supplier
  //     if (sup) {
  //       result += `-${sup.adspotid}-${sup.priority}`
  //     }
  //     BYLog.devDebug(`getAdnCacheKey , result = ${result}`)
  //   } catch (e) {
  //     BYLog.printE(e)
  //   }
  //   return result
  // }
}