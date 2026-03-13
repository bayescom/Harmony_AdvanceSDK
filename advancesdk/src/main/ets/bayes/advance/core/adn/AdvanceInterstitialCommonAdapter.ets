import { AdvanceError } from '../../../../../../../Index';
import { AdvanceCommonAdapter } from './AdvanceCommonAdapter';

// adapter内各回调结果通知给开屏广告位
export interface AdvanceInterstitialAdapterBridge {
  interstitialAdapter_didAdShow: () => void
  interstitialAdapter_didAdShowFailed: (error: AdvanceError) => void
  interstitialAdapter_didAdClick: () => void
  interstitialAdapter_didAdClose: () => void
}

export abstract class AdvanceInterstitialCommonAdapter extends AdvanceCommonAdapter {
  bridge?: AdvanceInterstitialAdapterBridge

  setInterstitialAdapterBridge(bridge: AdvanceInterstitialAdapterBridge) {
    this.bridge = bridge
  }
}