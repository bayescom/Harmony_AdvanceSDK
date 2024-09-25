import { AdvanceAdBase } from '../AdvanceAdBase';
import { AdvanceNativeListener } from '../AdvanceOpenListener';
import { BYLog } from '../../../basic/BYLog';
import AdvanceConstant from '../../model/AdvanceConstant';
import { AdvanceADNUnitData } from '../adn/AdvanceADNUnitData';
import { AdvanceADNCommonNativeAdapter } from '../adn/AdvanceADNCommonNativeAdapter';
import { AdvanceNativeData } from './AdvanceNativeData';

export class AdvanceNative extends AdvanceAdBase {
  protected init(): void {
    this.adSlotType = AdvanceConstant.ADV_AD_TYPE_NATIVE
  }

  private mListener?: AdvanceNativeListener

  protected adnWin(bestAdn: AdvanceADNUnitData) {
    //设置监听回调方法
    try {
      if (this.mListener) {
        let adapter = this.getCurrentAdapter() as AdvanceADNCommonNativeAdapter
        adapter.setNativeListener(this.mListener)
      }
    } catch (e) {
      BYLog.printE(e)
    }
  }


  setListener(spl: AdvanceNativeListener) {
    this.commListener = spl
    this.mListener = spl
  }

  //获取源数据，用来自渲染广告信息
  getNativeData(): AdvanceNativeData | undefined {
    try {
      let adapter = this.getCurrentAdapter() as AdvanceADNCommonNativeAdapter
      return adapter.getNativeData()
    } catch (e) {
      BYLog.printE(e)
    }
    return
  }
}