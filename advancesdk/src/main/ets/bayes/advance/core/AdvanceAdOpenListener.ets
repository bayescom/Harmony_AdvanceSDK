import { AdvanceError } from '../define/AdvanceError'
import { AdvanceAdInfo } from '../model/AdvanceAdInfo'
import { AdvanceRenderFeedWrapper } from './renderFeed/AdvanceRenderFeedWrapper'

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
  onAdClick: () => void // 广告点击
}

export interface AdvanceSplashListener extends AdvanceAdInteractionListener {
  onAdShowFailed: (error: AdvanceError) => void // 广告展示失败
  onAdClose: () => void // 广告关闭
}

export interface AdvanceBannerListener extends AdvanceAdInteractionListener {
  onAdShowFailed: (error: AdvanceError) => void // 广告展示失败
  onAdClose: () => void // 广告关闭
}

export interface AdvanceInterstitialListener extends AdvanceAdInteractionListener {
  onAdShowFailed: (error: AdvanceError) => void // 广告展示失败
  onAdClose: () => void // 广告关闭
}

export interface AdvanceRewardVideoListener extends AdvanceAdInteractionListener {
  onAdShowFailed: (error: AdvanceError) => void // 广告展示失败
  onAdClose: () => void // 广告关闭
  onAdReward: () => void // 奖励发放
  onVideoPlayEnd?: () => void // 视频播放完成
}

export interface AdvanceNativeExpressListener extends AdvanceAdInteractionListener {
  onRenderSuccess: () => void // 广告渲染成功
  onRenderFail: (error: AdvanceError) => void // 广告渲染失败
  onAdClose: () => void // 广告关闭
  onVideoPlayStart?: () => void
  onVideoPlayEnd?: () => void
  onVideoPlayFailed?: (error: AdvanceError) => void
}

export interface AdvanceRenderFeedListener extends AdvanceAdInteractionListener {
  onRenderSuccess: (wrapper: AdvanceRenderFeedWrapper) => void // 广告渲染成功
  onRenderFail: (error: AdvanceError) => void // 广告渲染失败
  onVideoPlayStart?: () => void
  onVideoPlayEnd?: () => void
  onVideoPlayFailed?: (error: AdvanceError) => void
}

