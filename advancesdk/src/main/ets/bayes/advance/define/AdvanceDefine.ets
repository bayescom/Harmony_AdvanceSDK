export enum AdvanceAdType {
  unknown,
  splash,
  banner,
  interstitial,
  rewardVideo,
  nativeExpress, // 原生模板信息流
  selfRender, // 自渲染信息流
}

export enum AdvanceCloseType {
  UNKNOWN = 0, //未知
  AD_CLICK = 1, //广告点击（插屏位置）
  SKIP_CLICK = 2, // 点击了跳过
  COUNT_DOWN = 3 // 倒计时结束
}