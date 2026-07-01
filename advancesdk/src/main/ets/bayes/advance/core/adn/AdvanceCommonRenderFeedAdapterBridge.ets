import { AdvanceError } from "../../define/AdvanceError";
import { AdvanceRenderFeedAdWrapper } from "../renderFeed/AdvanceRenderFeedAdWrapper";
import { AdvanceCommonRenderFeedAdapter } from "./AdvanceCommonAdapter";

/// 自渲染信息流广告adapter的回调协议
export interface AdvanceCommonRenderFeedAdapterBridge {

  renderFeed_didAdLoaded: (adapter: AdvanceCommonRenderFeedAdapter, price: number) => void

  renderFeed_didAdLoadFailed: (adapter: AdvanceCommonRenderFeedAdapter, error: AdvanceError) => void

  renderFeed_didAdRenderSuccess: (adapter: AdvanceCommonRenderFeedAdapter, wrapper: AdvanceRenderFeedAdWrapper) => void

  renderFeed_didAdRenderFail: (adapter: AdvanceCommonRenderFeedAdapter, error: AdvanceError) => void

  renderFeed_didAdShow: (adapter: AdvanceCommonRenderFeedAdapter) => void

  renderFeed_didAdClick: (adapter: AdvanceCommonRenderFeedAdapter) => void

  renderFeed_didAdVideoPlayStart: (adapter: AdvanceCommonRenderFeedAdapter) => void

  renderFeed_didAdVideoPlayEnd: (adapter: AdvanceCommonRenderFeedAdapter) => void

  renderFeed_didAdVideoPlayFailed: (adapter: AdvanceCommonRenderFeedAdapter, error: AdvanceError) => void

}