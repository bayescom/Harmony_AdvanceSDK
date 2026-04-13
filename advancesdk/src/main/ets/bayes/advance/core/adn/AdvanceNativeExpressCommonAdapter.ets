import { AdvanceCommonAdapter } from './AdvanceCommonAdapter'
import { AdvanceNativeExpressAdapterBridge } from './AdvanceCommonAdapterBridge'

export abstract class AdvanceNativeExpressCommonAdapter extends AdvanceCommonAdapter {
  bridge?: AdvanceNativeExpressAdapterBridge

  setNativeExpressAdapterBridge(bridge: AdvanceNativeExpressAdapterBridge) {
    this.bridge = bridge
  }

}