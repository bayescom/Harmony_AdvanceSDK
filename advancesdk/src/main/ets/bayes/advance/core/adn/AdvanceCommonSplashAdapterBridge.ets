import { AdvanceError } from "../../define/AdvanceError";
import { AdvanceCommonSplashAdapter } from "./AdvanceCommonAdapter";

/// 开屏广告adapter的回调协议
export interface AdvanceCommonSplashAdapterBridge {

  splash_didAdLoaded: (adapter: AdvanceCommonSplashAdapter, price: number) => void

  splash_didAdLoadFailed: (adapter: AdvanceCommonSplashAdapter, error: AdvanceError) => void

  splash_didAdShow: (adapter: AdvanceCommonSplashAdapter) => void

  splash_didAdShowFailed: (adapter: AdvanceCommonSplashAdapter, error: AdvanceError) => void

  splash_didAdClick: (adapter: AdvanceCommonSplashAdapter) => void

  splash_didAdClose: (adapter: AdvanceCommonSplashAdapter) => void

}