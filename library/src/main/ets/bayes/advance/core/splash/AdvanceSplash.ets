import { AdvanceAdBase } from '../AdvanceAdBase';
import { AdvanceSplashListener } from '../AdvanceOpenListener';
import { NodeController } from '@kit.ArkUI';
import { BYLog } from '../../../basic/BYLog';
import AdvanceConstant from '../../model/AdvanceConstant';
import { AdvanceRenderOption } from '../../config/AdvanceOption';
import { AdvanceADNUnitData } from '../adn/AdvanceADNUnitData';
import { AdvanceADNCommonSplashAdapter } from '../adn/AdvanceADNCommonSplashAdapter';

export class AdvanceSplash extends AdvanceAdBase {
  init(): void {
    this.adSlotType = AdvanceConstant.ADV_AD_TYPE_SPLASH
  }

  protected mListener?: AdvanceSplashListener

  setListener(spl: AdvanceSplashListener) {
    this.commListener = spl
    this.mListener = spl
  }


  protected adnWin(bestAdn: AdvanceADNUnitData): void {
    //设置监听回调方法
    try {
      if (this.mListener) {
        let adapter = this.getCurrentAdapter() as AdvanceADNCommonSplashAdapter
        adapter.setSplashListener(this.mListener)
      }
    } catch (e) {
      BYLog.printE(e)
    }
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