import { AdvanceCommonAdapter } from './AdvanceCommonAdapter';
import { AdvanceSplashAdapterBridge } from './AdvanceCommonAdapterBridge';

export abstract class AdvanceSplashCommonAdapter extends AdvanceCommonAdapter {
  bridge?: AdvanceSplashAdapterBridge

  setSplashAdapterBridge(bridge: AdvanceSplashAdapterBridge) {
    this.bridge = bridge
  }
}