import { AdvanceAdBase } from '../AdvanceAdBase';
import { AdvanceSplashListener } from '../AdvanceOpenListener';
import { NodeController } from '@kit.ArkUI';
import { BYLog } from '../../../basic/BYLog';

export class AdvanceSplash extends AdvanceAdBase {
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