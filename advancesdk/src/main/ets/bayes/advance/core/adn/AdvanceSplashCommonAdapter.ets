import { AdvanceError } from '../../../../../../../Index';
import { AdvanceCommonAdapter } from './AdvanceCommonAdapter';

// adapter内各回调结果通知给开屏广告位
export interface AdvanceSplashAdapterBridge {
  splashAdapter_didAdShow: () => void
  splashAdapter_didAdShowFailed: (error: AdvanceError) => void
  splashAdapter_didAdClick: () => void
  splashAdapter_didAdClose: () => void
}

export abstract class AdvanceSplashCommonAdapter extends AdvanceCommonAdapter {
  bridge?: AdvanceSplashAdapterBridge

  setSplashAdapterBridge(bridge: AdvanceSplashAdapterBridge) {
    this.bridge = bridge
  }
}