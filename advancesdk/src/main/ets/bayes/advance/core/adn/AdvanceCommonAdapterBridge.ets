import { AdvanceError } from "../../../../../../../Index"
import { AdvanceSupplierModel } from "../../model/AdvanceNetModel"
import { AdvanceRenderFeedWrapper } from "../renderFeed/AdvanceRenderFeedWrapper"

// adapter内各回调结果通知给广告位
export interface AdvanceCommonAdapterBridge {
  bridge_didAdLoaded: (supplier: AdvanceSupplierModel, price: number) => void
  bridge_didAdLoadFailed: (supplier: AdvanceSupplierModel, error: AdvanceError) => void
  bridge_didAdShow: (supplier: AdvanceSupplierModel) => void
  bridge_didAdClick: (supplier: AdvanceSupplierModel) => void
  // 是否缓存广告对象
  bridge_cacheAdapterIfNeeded: (adapter: object, supplier: AdvanceSupplierModel, price: number) => void
}

export interface AdvanceSplashAdapterBridge extends AdvanceCommonAdapterBridge {
  bridge_didAdShowFailed: (supplier: AdvanceSupplierModel, error: AdvanceError) => void
  bridge_didAdClose: () => void
}

export interface AdvanceBannerAdapterBridge extends AdvanceCommonAdapterBridge {
  bridge_didAdShowFailed: (supplier: AdvanceSupplierModel, error: AdvanceError) => void
  bridge_didAdClose: () => void
}

export interface AdvanceInterstitialAdapterBridge extends AdvanceCommonAdapterBridge {
  bridge_didAdShowFailed: (supplier: AdvanceSupplierModel, error: AdvanceError) => void
  bridge_didAdClose: () => void
}

export interface AdvanceRewardVideoAdapterBridge extends AdvanceCommonAdapterBridge {
  bridge_didAdShowFailed: (supplier: AdvanceSupplierModel, error: AdvanceError) => void
  bridge_didAdClose: () => void
  bridge_didAdReward: () => void
  bridge_didAdVideoPlayEnd: () => void
}

export interface AdvanceNativeExpressAdapterBridge extends AdvanceCommonAdapterBridge {
  bridge_didAdRenderSuccess: (supplier: AdvanceSupplierModel) => void
  bridge_didAdRenderFail: (supplier: AdvanceSupplierModel, error: AdvanceError) => void
  bridge_didAdClose: () => void
  bridge_didAdVideoPlayStart: () => void
  bridge_didAdVideoPlayEnd: () => void
  bridge_didAdVideoPlayFailed: (error: AdvanceError) => void
}

export interface AdvanceRenderFeedAdapterBridge extends AdvanceCommonAdapterBridge {
  bridge_didAdRenderSuccess: (supplier: AdvanceSupplierModel, wrapper: AdvanceRenderFeedWrapper) => void
  bridge_didAdRenderFail: (supplier: AdvanceSupplierModel, error: AdvanceError) => void
  bridge_didAdVideoPlayStart: () => void
  bridge_didAdVideoPlayEnd: () => void
  bridge_didAdVideoPlayFailed: (error: AdvanceError) => void
}