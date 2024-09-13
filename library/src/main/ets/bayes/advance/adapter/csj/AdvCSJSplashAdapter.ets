import { AdvanceADNCommonAdapter } from '../../core/AdvanceADNCommonAdapter';
import { NodeController } from '@kit.ArkUI';
import { BYLog } from '../../../basic/BYLog';

export class AdvCSJSplashAdapter extends AdvanceADNCommonAdapter{
  loadAd(): Promise<boolean> {

    return new Promise<boolean>((resolve, reject) => {
      BYLog.devDebug(`AdvCSJSplashAdapter loadAd mock success`)
      resolve(true)
    })
    return new Promise<boolean>((resolve, reject) => {
      BYLog.devDebug(`AdvCSJSplashAdapter loadAd mock failed`)
      resolve(false)
    })


    let result = false
    BYLog.debug(`AdvCSJSplashAdapter loadAd`)

     result
    // throw new Error('Method not implemented.');
  }
  getAdComponent(): NodeController | undefined {
    throw new Error('Method not implemented.');
  }


}