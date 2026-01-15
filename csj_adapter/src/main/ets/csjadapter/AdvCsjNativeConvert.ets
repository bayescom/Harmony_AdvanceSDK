import { CSJArrayList, CSJConstant, CSJFeedAd, CSJImage } from '@csj/openadsdk';
import { AdvanceNativeData, BYStrUtil, AdvanceNativeCompliance, AdvanceNativeInteractionModel, BYLog } from 'AdvanceSDK';
import { UIContext } from '@ohos.arkui.UIContext';
import ArrayList from '@ohos.util.ArrayList';
import { NodeController } from '@kit.ArkUI';
import { AdvCsjNativeComplianceConvert } from './AdvCsjNativeComplianceConvert';

//将获取的穿山甲数据类，转换成advance对外暴露的属性信息
export class AdvCsjNativeConvert implements AdvanceNativeData {
  mData: CSJFeedAd

  constructor(adData: CSJFeedAd) {
    this.mData = adData
  }

  getTitle(): string {
    return this.mData.getTitle()
  }

  getVideoCoverImageUrl(): string {
    return this.mData.getVideoCoverImage()?.getImageUrl() ?? ``
  }

  getAdLogo(): string | Resource {
    return this.mData.getAdLogo()
  }

  getDescription(): string {
    return this.mData.getDescription()
  }

  getButtonText(): string {
    return this.mData.getButtonText()
  }

  getAppScore(): number {
    return this.mData.getAppScore()
  }

  getAppCommentNum(): number {
    return this.mData.getAppCommentNum()
  }

  getAppSize(): number {
    return this.mData.getAppSize()
  }

  getSource(): string {
    return this.mData.getSource()
  }

  getIconUrl(): string {
    return this.mData.getIcon()?.getImageUrl() ?? ``
  }

  getImageUrlList(): ArrayList<string>  {
    let result = new ArrayList<string>()
    try {
      let csjImgs = this.mData.getImageList()
      if (csjImgs) {
        for (let index = 0; index < csjImgs.length; index++) {
          const element: CSJImage = csjImgs[index]

          //不为空才加入数组
          if (element && BYStrUtil.isNotEmpty(element.getImageUrl())) {
            result.add(element.getImageUrl())
          }
        }
      }
    } catch (e) {
      BYLog.printE(e)
    }
    return result
  }

  getInteractionType(): number {
    return this.mData.getInteractionType()
  }

  isVideo(): boolean {
    let result = false

    let imgMode = this.mData.getImageMode()
    if (imgMode == CSJConstant.IMAGE_MODE_VIDEO
      || imgMode == CSJConstant.IMAGE_MODE_VIDEO_VERTICAL
      || imgMode == CSJConstant.IMAGE_MODE_SQUARE_VIDEO) {
      result = true
    }

    return result
  }

  //暂不暴露图片类型，根据返回图片数量自由加载展示逻辑
  // getImageMode(): number {
  //   return this.mData.getImageMode()
  // }

  getComplianceInfo(): AdvanceNativeCompliance | undefined {
    let csjCompliance = this.mData.getComplianceInfo()
    if (csjCompliance) {
      return new AdvCsjNativeComplianceConvert(csjCompliance)
    }
    return
  }

  getAdComponent(): NodeController | undefined {
    return this.mData.getAdComponent()
  }

  onAdClick(clickType: number, eventClick: ClickEvent): void {
    this.mData.onAdClick(clickType, eventClick)
  }

  getMediaExtraInfo(): Map<string, object> {
    return this.mData.getMediaExtraInfo()
  }

  showDislikeDialog(context: object): void {
    let disDia = this.mData.getDislikeDialog()
    disDia?.showDislikeDialog(context)
  }

  destroy(): void {
    return this.mData.destroy()
  }

  registerViewForInteraction(interactModel: AdvanceNativeInteractionModel): void {
    try {
      let cliIds = new CSJArrayList<string>()
      let setClickIds = interactModel.clickViewIds
      if (setClickIds) {
        for (let index = 0; index < setClickIds.length; index++) {
          const element: string = setClickIds[index];
          cliIds.addAdId(element)
        }
      }

      let creativeIds = new CSJArrayList<string>()
      let setCreativeIds = interactModel.creativeViewIds
      if (setCreativeIds) {
        for (let index = 0; index < setCreativeIds.length; index++) {
          const element: string = setCreativeIds[index];
          creativeIds.addAdId(element)
        }
      }

      this.mData.registerViewForInteraction(interactModel.rootAdComponentId, interactModel.uiContext, cliIds,
        creativeIds)
    } catch (e) {
      BYLog.printE(e)
    }

  }

  isExpressAd(): boolean {
    return this.mData.isExpressAd()
  }

  render(context: UIContext): void {
    this.mData.render(context)
  }
}