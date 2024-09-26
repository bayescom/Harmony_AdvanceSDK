import { ArrayList } from '@kit.ArkTS';
import { NodeController } from '@kit.ArkUI';
import { AdvanceNativeCompliance } from './AdvanceNativeCompliance';
import { AdvanceNativeInteractionModel } from './AdvanceNativeInteractionModel';

//自渲染对外暴露参数设置
export interface AdvanceNativeData {

  getVideoCoverImageUrl(): string;

  getAdLogo(): Resource | string; //todo 修改为NodeController 方式返回，方便兼容多家adn返回结构

  getTitle(): string;

  getDescription(): string;

  getButtonText(): string;

  getAppScore(): number;

  getAppCommentNum(): number;

  getAppSize(): number;

  getSource(): string;

  getIconUrl(): string;

  getImageUrlList(): ArrayList<string> ;

  getInteractionType(): number;

  isVideo():boolean
  // getImageMode(): number;

  //下载六要素合规信息
  getComplianceInfo(): AdvanceNativeCompliance | undefined;

  getAdComponent(): NodeController | undefined;

  onAdClick(clickType: number, eventClick: ClickEvent): void;

  getMediaExtraInfo(): Map<string, object>;

  showDislikeDialog(context: object):void;
  // getDislikeDialog(): CSJAdDislike | undefined;
  //
  // setDislikeCallback(dislikeInteractionCallback: CSJDislikeInteractionCallback): void;

  destroy(): void;

  registerViewForInteraction(interactModel :AdvanceNativeInteractionModel): void;

  isExpressAd(): boolean;

  render(context: UIContext): void;

  // setExpressRenderListener(expressRenderListener: ExpressRenderListener): void;

  // setAdInteractionListener(listener: CSJAdInteractionListener): void;
}