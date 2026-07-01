import { AdvanceError } from "../../define/AdvanceError";
import { AdvanceCommonInterstitialAdapter } from "./AdvanceCommonAdapter";

/// 插屏广告adapter的回调协议
export interface AdvanceCommonInterstitialAdapterBridge {

  interstitial_didAdLoaded: (adapter: AdvanceCommonInterstitialAdapter, price: number) => void

  interstitial_didAdLoadFailed: (adapter: AdvanceCommonInterstitialAdapter, error: AdvanceError) => void

  interstitial_didAdShow: (adapter: AdvanceCommonInterstitialAdapter) => void

  interstitial_didAdShowFailed: (adapter: AdvanceCommonInterstitialAdapter, error: AdvanceError) => void

  interstitial_didAdClick: (adapter: AdvanceCommonInterstitialAdapter) => void

  interstitial_didAdClose: (adapter: AdvanceCommonInterstitialAdapter) => void

}