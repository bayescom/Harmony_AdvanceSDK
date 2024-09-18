import { AdvanceADNCommonAdapter } from '../../core/AdvanceADNCommonAdapter';
import { NodeController } from '@kit.ArkUI';
import { BYLog } from '../../../basic/BYLog';
import { CSJAdCreator } from '@csj/openadsdk';
import { BYUtil } from '../../../basic/BYUtil';
import { AdvanceAdnResult } from '../../model/AdvanceSendModel';

export class AdvCSJSplashAdapter extends AdvanceADNCommonAdapter {
  loadAd(): Promise<AdvanceAdnResult> {
    BYLog.devDebug(`AdvCSJSplashAdapter loadAd start`)
    let adCreator: CSJAdCreator = new CSJAdCreator()

    return new Promise<AdvanceAdnResult>((resolve, reject) => {
      let randomResult = 0
      try {
        let start: number = new Date().getTime();
        let random = Math.random()
        let delayTime = random * 2000
        randomResult = BYUtil.caseNumberInt(random)
        // mock异步执行过程
        while (new Date().getTime() - start < delayTime) {
          continue;
        }
        BYLog.devDebug(`AdvCSJSplashAdapter loadAd mock , random = ${random} ,randomResultStatus = ${randomResult} , delayTime = ` +
          delayTime)
      } catch (e) {
      }

      let result = new AdvanceAdnResult()
      result.resultStatus = randomResult
      resolve(result)
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