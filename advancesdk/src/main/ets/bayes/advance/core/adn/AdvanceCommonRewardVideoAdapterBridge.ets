import { AdvanceError } from "../../define/AdvanceError";
import { AdvanceCommonRewardVideoAdapter } from "./AdvanceCommonAdapter";

/// 激励视频广告adapter的回调协议
export interface AdvanceCommonRewardVideoAdapterBridge {

  rewardVideo_didAdLoaded: (adapter: AdvanceCommonRewardVideoAdapter, price: number) => void

  rewardVideo_didAdLoadFailed: (adapter: AdvanceCommonRewardVideoAdapter, error: AdvanceError) => void

  rewardVideo_didAdShow: (adapter: AdvanceCommonRewardVideoAdapter) => void

  rewardVideo_didAdShowFailed: (adapter: AdvanceCommonRewardVideoAdapter, error: AdvanceError) => void

  rewardVideo_didAdClick: (adapter: AdvanceCommonRewardVideoAdapter) => void

  rewardVideo_didAdClose: (adapter: AdvanceCommonRewardVideoAdapter) => void

  rewardVideo_didAdReward: (adapter: AdvanceCommonRewardVideoAdapter) => void // 验证激励回调

  rewardVideo_didAdVideoPlayEnd: (adapter: AdvanceCommonRewardVideoAdapter) => void

}