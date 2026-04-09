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

export enum AdvanceAdnLoadAdState {
  ready = 0, // 准备就绪
  success, // 渠道请求广告成功
  failed, // 渠道请求广告失败
  timeout, // 渠道请求广告超时
}

export enum AdvanceAdnReportTKEventType {
  loaded, // 渠道SDK启动
  succeed, // SDK广告获取成功
  failed, // SDK广告 获取/渲染/超时 失败
  exposed, // SDK广告 曝光成功
  clicked, // SDK广告 产生点击
  bidWin, // 结束bidding 某个渠道广告竞胜
}