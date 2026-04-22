import { NodeController } from '@kit.ArkUI';

export interface AdvanceRenderFeedWrapper {

  getTitle(): string;

  getDescription(): string;

  getButtonText(): string;

  getIconUrl(): string;

  getImageUrlList(): string[] ;

  isVideoAd():boolean;

  getAdLogoView(): NodeController | undefined;

  // 视频组件
  getAdComponent(): NodeController | undefined;

  // 用于注册交互事件，包括曝光和点击等操作 (csj、gdt)
  registerViewForInteraction(uiContext: UIContext, rootViewId: string, clickableViewIds:string[]): void;

  // 控件点击监听 (ks、mercury)
  getClickHandler(): (event: ClickEvent) => void;

  // 获取可⻅区域监听数组
  getVisibleAreaRatios(): number[];

  // 可见区域监听方法，用于SDK内部判断页面展示比例，处理广告曝光&视频播放等
  getVisibleAreaChangeListener(): (isVisible: boolean, currentRatio: number) => void;

}