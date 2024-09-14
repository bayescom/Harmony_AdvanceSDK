import { AdvanceADNCommonAdapter } from '../../core/AdvanceADNCommonAdapter';
import { NodeController } from '@kit.ArkUI';
import { BYLog } from '../../../basic/BYLog';
import { CSJAdCreator } from '@csj/openadsdk';

export class AdvCSJSplashAdapter extends AdvanceADNCommonAdapter{
  loadAd(): Promise<boolean> {
    BYLog.devDebug(`AdvCSJSplashAdapter loadAd start`)
    let adCreator: CSJAdCreator = new CSJAdCreator()

    return new Promise<boolean>((resolve, reject) => {

      let start: number = new Date().getTime();
      while (new Date().getTime() - start < 1000) {
        continue;
      }
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