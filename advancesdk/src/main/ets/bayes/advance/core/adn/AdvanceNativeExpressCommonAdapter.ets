import { AdvanceNativeExpressListener } from '../AdvanceAdOpenListener'
import { AdvanceCommonAdapter } from './AdvanceCommonAdapter'

export abstract class AdvanceNativeExpressCommonAdapter extends AdvanceCommonAdapter {
  feedListener?: AdvanceNativeExpressListener

  setFeedListener(feedListener: AdvanceNativeExpressListener) {
    this.feedListener = feedListener
    // this.baseListener = feedListener
  }

  abstract render(context: UIContext)
}