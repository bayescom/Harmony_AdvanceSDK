import { AdvanceAdBase } from '../AdvanceAdBase';
import { AdvanceSplashListener } from '../AdvanceOpenListener';
import { NodeController } from '@kit.ArkUI';
import { BYLog } from '../../../basic/BYLog';
import { AdvanceADNUnitData } from '../../model/AdvanceADNUnitData';
import { AdvanceADNCommonAdapter } from '../AdvanceADNCommonAdapter';
import AdvanceConstant from '../../model/AdvanceConstant';
import { AdvCSJSplashAdapter } from '../../adapter/csj/AdvCSJSplashAdapter';

export class AdvanceSplash extends AdvanceAdBase {
  //获取对应adapter实现类
  getAdnAdapter(adnData: AdvanceADNUnitData): AdvanceADNCommonAdapter | undefined {
    let result: AdvanceADNCommonAdapter | undefined = undefined

    try {
      let sdkId = adnData.supplier?.id
      if (sdkId == AdvanceConstant.ADV_SDK_ID_CSJ) {
        result = new AdvCSJSplashAdapter(adnData)
      }
    } catch (e) {
      BYLog.printE(e)
    }
    BYLog.debug(`getAdnAdapter , result = ${result}`)

    return result
  }

  mListener?: AdvanceSplashListener

  setListener(spl: AdvanceSplashListener) {
    this.baseListener = spl
    this.mListener = spl
  }


  getAdComponent(): NodeController | undefined {
    try {
      let adapter = this.getCurrentAdapter()
      return adapter?.getAdComponent()
    } catch (e) {
      BYLog.printE(e)
    }
    return
  }
}