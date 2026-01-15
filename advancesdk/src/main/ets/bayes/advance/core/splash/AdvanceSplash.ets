import { AdvanceAdBase } from '../AdvanceAdBase';
import { AdvanceSplashListener } from '../AdvanceOpenListener';
import { NodeController } from '@kit.ArkUI';
import { BYLog } from '../../../basic/BYLog';
import { AdvanceAdType } from '../../define/AdvanceDefine';
import { AdvanceRenderOption } from '../../config/AdvanceOption';
import { AdvanceADNUnitData } from '../adn/AdvanceADNUnitData';
import { AdvanceSplashCommonAdapter } from '../adn/AdvanceSplashCommonAdapter';

export class AdvanceSplash extends AdvanceAdBase {
  protected init(): void {
    this.adSlotType = AdvanceAdType.splash
  }
  protected mListener?: AdvanceSplashListener
  protected adnWin(bestAdn: AdvanceADNUnitData): void {
    //设置监听回调方法
    try {
      if (this.mListener) {
        let adapter = this.getCurrentAdapter() as AdvanceSplashCommonAdapter
        adapter.setSplashListener(this.mListener)
      }
    } catch (e) {
      BYLog.printE(e)
    }
  }

  setListener(spl: AdvanceSplashListener) {
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


  showAd(renderOP: AdvanceRenderOption) {
    this.callShow(renderOP)
  }
}