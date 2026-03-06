import { AdvanceAdBase } from '../AdvanceAdBase';
import { AdvanceRenderFeedListener } from '../AdvanceAdOpenListener';
import { BYLog } from '../../../basic/BYLog';
import { AdvanceADNUnitData } from '../adn/AdvanceADNUnitData';
import { AdvanceRenderFeedCommonAdapter } from '../adn/AdvanceRenderFeedCommonAdapter';
import { AdvanceRenderFeedData } from './AdvanceRenderFeedData';
import { AdvanceAdType } from '../../define/AdvanceDefine';

export class AdvanceRenderFeed extends AdvanceAdBase {
  protected init(): void {
    this.adSlotType = AdvanceAdType.selfRender
  }

  private mListener?: AdvanceRenderFeedListener

  protected override adnWin() {
    //设置监听回调方法
    try {
      if (this.mListener) {
        let adapter = this.getCurrentAdapter() as AdvanceRenderFeedCommonAdapter
        adapter.setNativeListener(this.mListener)
      }
    } catch (e) {
      BYLog.printE(e)
    }
  }


  setListener(spl: AdvanceRenderFeedListener) {
    this.loadListener = spl
    this.mListener = spl
  }

  //获取源数据，用来自渲染广告信息
  getNativeData(): AdvanceRenderFeedData | undefined {
    try {
      let adapter = this.getCurrentAdapter() as AdvanceRenderFeedCommonAdapter
      return adapter.getNativeData()
    } catch (e) {
      BYLog.printE(e)
    }
    return
  }
}