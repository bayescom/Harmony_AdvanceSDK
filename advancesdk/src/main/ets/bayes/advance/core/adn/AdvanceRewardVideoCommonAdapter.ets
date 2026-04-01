import { AdvanceCommonAdapter } from './AdvanceCommonAdapter';
import { AdvanceRewardVideoAdapterBridge } from './AdvanceCommonAdapterBridge';

export abstract class AdvanceRewardVideoCommonAdapter extends AdvanceCommonAdapter {
  bridge?: AdvanceRewardVideoAdapterBridge

  setRewardVideoAdapterBridge(bridge: AdvanceRewardVideoAdapterBridge) {
    this.bridge = bridge
  }
}