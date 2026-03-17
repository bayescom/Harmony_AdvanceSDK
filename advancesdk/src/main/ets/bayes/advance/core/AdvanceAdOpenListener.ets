import { AdvanceError } from '../define/AdvanceError'
import { AdvanceAdInfo } from '../model/AdvanceAdInfo'
import { AdvanceDislike } from './AdvanceDislike'

// 各广告位通用的加载接口
export interface AdvanceAdLoadListener {
  /**
   * 广告加载成功
   * @param adInfo 当前渠道信息
   */
  onAdLoaded: (adInfo: AdvanceAdInfo) => void

  /**
   * 广告加载失败
   * @param error 错误信息
   */
  onAdLoadFailed: (error: AdvanceError) => void
}

// 各广告位通用的交互接口
export interface AdvanceAdInteractionListener extends AdvanceAdLoadListener {
  onAdShow: () => void // 广告曝光成功
  onAdShowFailed?: (error: AdvanceError) => void // 广告展示失败
  onAdClick: () => void // 广告点击
  onAdClose: () => void // 广告关闭
}

export interface AdvanceSplashListener extends AdvanceAdInteractionListener {}

export interface AdvanceBannerListener extends AdvanceAdInteractionListener {}

export interface AdvanceInterstitialListener extends AdvanceAdInteractionListener {}

export interface AdvanceRewardVideoListener extends AdvanceAdInteractionListener {
  onAdReward: () => void // 奖励发放
  onAdPlayEnd?: () => void // 广告播放完成
}

export interface AdvanceNativeExpressListener extends AdvanceAdInteractionListener {
  onDislike: (dislike: AdvanceDislike) => void //广告关闭回调
  onRenderSuccess: () => void // 在调用广告的render方法后，广告渲染成功，会回调该方法，此时表示广告已准备好，待展示
  onRenderFail: (error: AdvanceError) => void //广告曝光成功
}

export interface AdvanceRenderFeedListener extends AdvanceAdInteractionListener {
  onDislike: (dislike: AdvanceDislike) => void //广告关闭回调
  onRenderSuccess: () => void // 在调用广告的render方法后，广告渲染成功，会回调该方法，此时表示广告已准备好，待展示
  onRenderFail: (error: AdvanceError) => void //广告曝光成功
}

