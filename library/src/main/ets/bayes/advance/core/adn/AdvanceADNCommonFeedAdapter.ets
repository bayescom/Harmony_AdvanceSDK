import { AdvanceFeedListener } from '../AdvanceOpenListener'
import { AdvanceADNCommonAdapter } from './AdvanceADNCommonAdapter'

export abstract class AdvanceADNCommonFeedAdapter extends AdvanceADNCommonAdapter {
  feedListener?: AdvanceFeedListener

  setFeedListener(feedListener: AdvanceFeedListener) {
    this.feedListener = feedListener
    this.baseListener = feedListener
  }

  abstract render(context: UIContext)
}