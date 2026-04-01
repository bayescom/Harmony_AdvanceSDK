import { AdvanceError } from "../../../../../../../Index"
import { AdvanceRenderFeedWrapper } from "../renderFeed/AdvanceRenderFeedWrapper"

// adapter内各回调结果通知给广告位
export interface AdvanceCommonAdapterBridge {
  bridge_didAdShow: () => void
  bridge_didAdClick: () => void
}
export interface AdvanceSplashAdapterBridge extends AdvanceCommonAdapterBridge {
  bridge_didAdShowFailed: (error: AdvanceError) => void
  bridge_didAdClose: () => void
}

export interface AdvanceBannerAdapterBridge extends AdvanceCommonAdapterBridge {
  bridge_didAdShowFailed: (error: AdvanceError) => void
  bridge_didAdClose: () => void
}

export interface AdvanceInterstitialAdapterBridge extends AdvanceCommonAdapterBridge {
  bridge_didAdShowFailed: (error: AdvanceError) => void
  bridge_didAdClose: () => void
}

export interface AdvanceRewardVideoAdapterBridge extends AdvanceCommonAdapterBridge {
  bridge_didAdShowFailed: (error: AdvanceError) => void
  bridge_didAdClose: () => void
  bridge_didAdReward: () => void
  bridge_didAdVideoPlayEnd: () => void
}

export interface AdvanceNativeExpressAdapterBridge extends AdvanceCommonAdapterBridge {
  bridge_didAdRenderSuccess: () => void
  bridge_didAdRenderFail: (error: AdvanceError) => void
  bridge_didAdClose: () => void
  bridge_didAdVideoPlayStart: () => void
  bridge_didAdVideoPlayEnd: () => void
  bridge_didAdVideoPlayFailed: (error: AdvanceError) => void
}

export interface AdvanceRenderFeedAdapterBridge extends AdvanceCommonAdapterBridge {
  bridge_didAdRenderSuccess: (wrapper: AdvanceRenderFeedWrapper) => void
  bridge_didAdRenderFail: (error: AdvanceError) => void
  bridge_didAdVideoPlayStart: () => void
  bridge_didAdVideoPlayEnd: () => void
  bridge_didAdVideoPlayFailed: (error: AdvanceError) => void
}