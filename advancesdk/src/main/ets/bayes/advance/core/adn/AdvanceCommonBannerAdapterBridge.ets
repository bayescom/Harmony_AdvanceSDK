import { AdvanceError } from "../../define/AdvanceError";
import { AdvanceCommonBannerAdapter } from "./AdvanceCommonAdapter";

/// banner广告adapter的回调协议
export interface AdvanceCommonBannerAdapterBridge {

  banner_didAdLoaded: (adapter: AdvanceCommonBannerAdapter, price: number) => void

  banner_didAdLoadFailed: (adapter: AdvanceCommonBannerAdapter, error: AdvanceError) => void

  banner_didAdShow: (adapter: AdvanceCommonBannerAdapter) => void

  banner_didAdShowFailed: (adapter: AdvanceCommonBannerAdapter, error: AdvanceError) => void

  banner_didAdClick: (adapter: AdvanceCommonBannerAdapter) => void

  banner_didAdClose: (adapter: AdvanceCommonBannerAdapter) => void

}