import { AdvanceAdBase } from '../AdvanceAdBase';
import { AdvanceBannerListener } from '../AdvanceAdOpenListener';
import { NodeController, window } from '@kit.ArkUI';
import { AdvanceAdType } from '../../define/AdvanceDefine';
import { AdvanceRequestOption } from '../../config/AdvanceOption';
import { AdvanceBannerCommonAdapter } from '../adn/AdvanceBannerCommonAdapter';
import { AdvanceError } from '../../../../../../../Index';

export class AdvanceBanner extends AdvanceAdBase {
  constructor(option: AdvanceRequestOption) {
    super(option)
    this.adSlotType = AdvanceAdType.banner
  }

  protected mListener?: AdvanceBannerListener

  protected override adnWin(): void {
    let adapter = this.getCurrentAdapter() as AdvanceBannerCommonAdapter
    adapter.setBannerAdapterBridge({
      bridge_didAdShow: () => {
        this.reportBestAdnShowTask()
        this.mListener?.onAdShow()
      },
      bridge_didAdShowFailed: (error: AdvanceError) => {
        this.reportBestAdnShowFailedTask(error)
        if (this.mListener?.onAdShowFailed) {
          this.mListener?.onAdShowFailed(error)
        }
        // 销毁各渠道Adapter对象
        this.destroyAdapters()
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
  }

  setAdListener(listener: AdvanceBannerListener) {
    this.loadListener = listener
    this.mListener = listener
  }

  isAdValid() : boolean {
    let adapter = this.getCurrentAdapter()
    if (adapter) {
      return adapter.adapter_isAdValid()
    }
    return false
  }

  loadAd() {
    this.loadStrategy()
  }

  getAdComponent(): NodeController | undefined {
    return this.getCurrentAdapter()?.adapter_getAdComponent()
  }

  getAcceptWidth(): number {
    return this.adOption.adWidth ?? 0
  }

  getAcceptHeight(): number {
    return this.adOption.adHeight ?? 0
  }

}