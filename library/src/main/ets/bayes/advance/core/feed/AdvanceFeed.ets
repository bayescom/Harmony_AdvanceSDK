import { AdvanceAdBase } from '../AdvanceAdBase';
import { AdvanceFeedListener } from '../AdvanceOpenListener';
import { NodeController } from '@kit.ArkUI';
import { BYLog } from '../../../basic/BYLog';
import AdvanceConstant from '../../model/AdvanceConstant';
import { AdvanceADNUnitData } from '../adn/AdvanceADNUnitData';
import { AdvanceADNCommonFeedAdapter } from '../adn/AdvanceADNCommonFeedAdapter';

export class AdvanceFeed extends AdvanceAdBase {
  protected init(): void {
    this.adSlotType = AdvanceConstant.ADV_AD_TYPE_FEED
  }
  private mListener?: AdvanceFeedListener
  protected adnWin(bestAdn: AdvanceADNUnitData) {
    //设置监听回调方法
    try {
      if (this.mListener) {
        let adapter = this.getCurrentAdapter() as AdvanceADNCommonFeedAdapter
        adapter.setFeedListener(this.mListener)
      }
    } catch (e) {
      BYLog.printE(e)
    }
  }


  setListener(spl: AdvanceFeedListener) {
    this.commListener = spl
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

  render(context: UIContext) {
    try {
      let adapter = this.getCurrentAdapter() as AdvanceADNCommonFeedAdapter
      adapter.render(context)
    } catch (e) {
      BYLog.printE(e)
    }
  }
}