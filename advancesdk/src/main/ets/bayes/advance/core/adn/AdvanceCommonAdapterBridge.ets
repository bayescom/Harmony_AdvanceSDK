import { AdvanceError } from "../../../../../../../Index"

// adapter内各回调结果通知给广告位
export interface AdvanceCommonAdapterBridge {
  bridge_didAdShow: () => void
  bridge_didAdShowFailed: (error: AdvanceError) => void
  bridge_didAdClick: () => void
  bridge_didAdClose: () => void
}
export interface AdvanceSplashAdapterBridge extends AdvanceCommonAdapterBridge {}

export interface AdvanceBannerAdapterBridge extends AdvanceCommonAdapterBridge {}

export interface AdvanceInterstitialAdapterBridge extends AdvanceCommonAdapterBridge {}

export interface AdvanceRewardVideoAdapterBridge extends AdvanceCommonAdapterBridge {
  bridge_didAdReward: () => void
  bridge_didAdPlayEnd: () => void
}