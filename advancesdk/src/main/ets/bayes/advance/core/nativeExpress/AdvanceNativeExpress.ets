import { AdvanceAdBase } from '../AdvanceAdBase';
import { AdvanceNativeExpressListener } from '../AdvanceAdOpenListener';
import { NodeController } from '@kit.ArkUI';
import { AdvanceNativeExpressCommonAdapter } from '../adn/AdvanceNativeExpressCommonAdapter';
import { AdvanceAdType } from '../../define/AdvanceDefine';
import { AdvanceError, AdvanceAdLoadConfig, BYApp } from '../../../../../../../Index';

export class AdvanceNativeExpress extends AdvanceAdBase {
  constructor(option: AdvanceAdLoadConfig) {
    super(option)
    this.adSlotType = AdvanceAdType.nativeExpress
  }

  private mListener?: AdvanceNativeExpressListener

  protected override adnWin(): void {
    let adapter = this.getCurrentAdapter() as AdvanceNativeExpressCommonAdapter
    adapter.setNativeExpressAdapterBridge({
      bridge_didAdRenderSuccess: () => {
        this.mListener?.onRenderSuccess()
      },
      bridge_didAdRenderFail: (error: AdvanceError) => {
        this.reportBestAdnShowFailedTask(error)
        this.mListener?.onRenderFail(error)
        // 销毁各渠道Adapter对象
        this.destroyAdapters()
      },
      bridge_didAdShow: () => {
        this.reportBestAdnShowTask()
        this.mListener?.onAdShow()
      },
      bridge_didAdClick: () => {
        this.reportBestAdnClickTask()
        this.mListener?.onAdClick()
      },
      bridge_didAdClose: () => {
        this.mListener?.onAdClose()
        // 销毁各渠道Adapter对象
        this.destroyAdapters()
      }
    })
    // 竞胜的广告源渲染广告
    adapter.adapter_render(BYApp.getUIContext())
  }

  setAdListener(listener: AdvanceNativeExpressListener) {
    this.loadListener = listener
    this.mListener = listener
  }

  loadAd() {
    this.loadStrategy()
  }

  getAdComponent(): NodeController | undefined {
    return this.getCurrentAdapter()?.adapter_getAdComponent()
  }

}