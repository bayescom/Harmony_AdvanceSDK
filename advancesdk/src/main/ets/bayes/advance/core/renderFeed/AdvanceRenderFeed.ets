import { AdvanceAdBase } from '../AdvanceAdBase';
import { AdvanceRenderFeedListener } from '../AdvanceAdOpenListener';
import { AdvanceRenderFeedCommonAdapter } from '../adn/AdvanceRenderFeedCommonAdapter';
import { AdvanceRenderFeedWrapper } from './AdvanceRenderFeedWrapper';
import { AdvanceAdType } from '../../define/AdvanceDefine';
import { AdvanceError, AdvanceAdLoadConfig, BYApp } from '../../../../../../../Index';

export class AdvanceRenderFeed extends AdvanceAdBase {
  constructor(option: AdvanceAdLoadConfig) {
    super(option)
    this.adSlotType = AdvanceAdType.renderFeed
  }

  private mListener?: AdvanceRenderFeedListener

  protected override adnWin() {
    let adapter = this.getCurrentAdapter() as AdvanceRenderFeedCommonAdapter
    adapter.setRenderFeedAdapterBridge({
      bridge_didAdRenderSuccess: (wrapper: AdvanceRenderFeedWrapper) => {
        this.mListener?.onRenderSuccess(wrapper)
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
      bridge_didAdVideoPlayStart: () => {
        if (this.mListener?.onVideoPlayStart) {
          this.mListener?.onVideoPlayStart()
        }
      },
      bridge_didAdVideoPlayEnd: () => {
        if (this.mListener?.onVideoPlayEnd) {
          this.mListener?.onVideoPlayEnd()
        }
      },
      bridge_didAdVideoPlayFailed: (error: AdvanceError) => {
        if (this.mListener?.onVideoPlayFailed) {
          this.mListener?.onVideoPlayFailed(error)
        }
      }
    })
    // 竞胜的广告源渲染广告
    adapter.adapter_render(BYApp.getUIContext())
  }

  setAdListener(listener: AdvanceRenderFeedListener) {
    this.loadListener = listener
    this.mListener = listener
  }

  loadAd() {
    this.loadStrategy()
  }

}