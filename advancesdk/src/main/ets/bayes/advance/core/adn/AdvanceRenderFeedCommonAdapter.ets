import { AdvanceCommonAdapter } from './AdvanceCommonAdapter'
import { AdvanceRenderFeedAdapterBridge } from './AdvanceCommonAdapterBridge'

export abstract class AdvanceRenderFeedCommonAdapter extends AdvanceCommonAdapter {
  bridge?: AdvanceRenderFeedAdapterBridge

  setRenderFeedAdapterBridge(bridge: AdvanceRenderFeedAdapterBridge) {
    this.bridge = bridge
  }

}