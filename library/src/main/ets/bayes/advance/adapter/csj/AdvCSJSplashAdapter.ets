import { AdvanceADNCommonAdapter } from '../../core/AdvanceADNCommonAdapter';
import { NodeController } from '@kit.ArkUI';
import { BYLog } from '../../../basic/BYLog';
import { CSJAdCreator } from '@csj/openadsdk';
import { BYUtil } from '../../../basic/BYUtil';

export class AdvCSJSplashAdapter extends AdvanceADNCommonAdapter {
  loadAd(): Promise<boolean> {
    BYLog.devDebug(`AdvCSJSplashAdapter loadAd start`)
    let adCreator: CSJAdCreator = new CSJAdCreator()

    return new Promise<boolean>((resolve, reject) => {

      let start: number = new Date().getTime();
      let delayTime = Math.random() * 2000
      let randomResult = BYUtil.caseNumberInt(Math.random() - 0.5) == 1
      while (new Date().getTime() - start < delayTime) {
        continue;
      }
      BYLog.devDebug(`AdvCSJSplashAdapter loadAd mock ${randomResult} , delayTime = ` + delayTime)
      resolve(randomResult)
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