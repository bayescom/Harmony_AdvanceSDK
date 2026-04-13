import { AdvanceCommonAdapter } from './AdvanceCommonAdapter';
import { AdvanceBannerAdapterBridge } from './AdvanceCommonAdapterBridge';

export abstract class AdvanceBannerCommonAdapter extends AdvanceCommonAdapter {
  bridge?: AdvanceBannerAdapterBridge

  setBannerAdapterBridge(bridge: AdvanceBannerAdapterBridge) {
    this.bridge = bridge
  }
}