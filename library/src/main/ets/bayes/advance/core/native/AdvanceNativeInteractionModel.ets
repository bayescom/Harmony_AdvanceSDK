import { ArrayList } from '@kit.ArkTS';

//自渲染设置交互内容的一些参数信息
export class AdvanceNativeInteractionModel{
  //以下4个为穿山甲需要参数，必传
  rootAdComponentId?: string;
  uiContext?: UIContext;
  clickViewIds?: ArrayList<string>;
  creativeViewIds?: ArrayList<string>


}