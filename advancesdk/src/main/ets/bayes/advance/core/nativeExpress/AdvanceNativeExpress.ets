import { AdvanceAdBase } from '../AdvanceAdBase';
import { AdvanceNativeExpressListener } from '../AdvanceAdOpenListener';
import { NodeController } from '@kit.ArkUI';
import { BYLog } from '../../../basic/BYLog';
import { AdvanceADNUnitData } from '../adn/AdvanceADNUnitData';
import { AdvanceNativeExpressCommonAdapter } from '../adn/AdvanceNativeExpressCommonAdapter';
import { AdvanceAdType } from '../../define/AdvanceDefine';

export class AdvanceNativeExpress extends AdvanceAdBase {
  protected init(): void {
    this.adSlotType = AdvanceAdType.nativeExpress
  }
  private mListener?: AdvanceNativeExpressListener
  protected override adnWin() {
    //设置监听回调方法
    try {
      if (this.mListener) {
        let adapter = this.getCurrentAdapter() as AdvanceNativeExpressCommonAdapter
        adapter.setFeedListener(this.mListener)
      }
    } catch (e) {
      BYLog.printE(e)
    }
  }


  setListener(spl: AdvanceNativeExpressListener) {
    this.loadListener = spl
    this.mListener = spl
  }
  getAdComponent(): NodeController | undefined {
    try {
      let adapter = this.getCurrentAdapter()
      return adapter?.adapter_getAdComponent()
    } catch (e) {
      BYLog.printE(e)
    }
    return
  }

  render(context: UIContext) {
    try {
      let adapter = this.getCurrentAdapter() as AdvanceNativeExpressCommonAdapter
      adapter.render(context)
    } catch (e) {
      BYLog.printE(e)
    }
  }
}