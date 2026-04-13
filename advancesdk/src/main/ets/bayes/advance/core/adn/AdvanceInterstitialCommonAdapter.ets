import { AdvanceCommonAdapter } from './AdvanceCommonAdapter';
import { AdvanceInterstitialAdapterBridge } from './AdvanceCommonAdapterBridge';

export abstract class AdvanceInterstitialCommonAdapter extends AdvanceCommonAdapter {
  bridge?: AdvanceInterstitialAdapterBridge

  setInterstitialAdapterBridge(bridge: AdvanceInterstitialAdapterBridge) {
    this.bridge = bridge
  }
}