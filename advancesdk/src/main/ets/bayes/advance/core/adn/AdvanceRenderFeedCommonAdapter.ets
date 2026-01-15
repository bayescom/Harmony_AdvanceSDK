import { AdvanceRenderFeedListener } from '../AdvanceOpenListener'
import { AdvanceRenderFeedData } from '../renderFeed/AdvanceRenderFeedData'
import { AdvanceCommonAdapter } from './AdvanceCommonAdapter'

export abstract class AdvanceRenderFeedCommonAdapter extends AdvanceCommonAdapter {
  nativeListener?: AdvanceRenderFeedListener

  setNativeListener(nativeListener: AdvanceRenderFeedListener) {
    this.nativeListener = nativeListener
    this.baseListener = nativeListener
  }

  abstract getNativeData(): AdvanceRenderFeedData | undefined
}