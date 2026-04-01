export enum AdvanceAdType {
  unknown,
  splash,
  banner,
  interstitial,
  rewardVideo,
  nativeExpress, // 原生模板信息流
  renderFeed, // 自渲染信息流
}

// adn初始化状态标记
export enum AdvanceAdnInitState {
  default,
  loading,
  success,
  failed
}

// 广告加载状态标记
export enum AdvanceAdLoadState {
  loading = -1,
  failed,
  success,
}