import { AdvanceError } from "../../../../../../../Index"

// adapter内各回调结果通知给广告位
export interface AdvanceCommonAdapterBridge {
  bridge_didAdShow: () => void
  bridge_didAdClick: () => void
  bridge_didAdClose: () => void
}
export interface AdvanceSplashAdapterBridge extends AdvanceCommonAdapterBridge {
  bridge_didAdShowFailed: (error: AdvanceError) => void
}

export interface AdvanceBannerAdapterBridge extends AdvanceCommonAdapterBridge {
  bridge_didAdShowFailed: (error: AdvanceError) => void
}

export interface AdvanceInterstitialAdapterBridge extends AdvanceCommonAdapterBridge {
  bridge_didAdShowFailed: (error: AdvanceError) => void
}

export interface AdvanceRewardVideoAdapterBridge extends AdvanceCommonAdapterBridge {
  bridge_didAdShowFailed: (error: AdvanceError) => void
  bridge_didAdReward: () => void
  bridge_didAdVideoPlayEnd: () => void
}

export interface AdvanceNativeExpressAdapterBridge extends AdvanceCommonAdapterBridge {
  bridge_didAdRenderSuccess: () => void
  bridge_didAdRenderFail: (error: AdvanceError) => void
  bridge_didAdVideoPlayStart: () => void
  bridge_didAdVideoPlayEnd: () => void
  bridge_didAdVideoPlayFailed: (error: AdvanceError) => void
}