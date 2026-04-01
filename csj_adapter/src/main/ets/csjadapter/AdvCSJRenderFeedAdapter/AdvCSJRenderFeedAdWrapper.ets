import { CSJArrayList, CSJConstant, CSJFeedAd } from '@csj/openadsdk';
import { AdvanceRenderFeedWrapper, BYCustomNodeController, BYStrUtil } from 'advancesdk';
import { NodeController } from '@kit.ArkUI';

export class AdvCSJRenderFeedAdWrapper implements AdvanceRenderFeedWrapper {
  ad: CSJFeedAd

  constructor(ad: CSJFeedAd) {
    this.ad = ad
  }

  getTitle(): string {
    return this.ad.getTitle()
  }

  getDescription(): string {
    return this.ad.getDescription()
  }

  getButtonText(): string {
    return this.ad.getButtonText()
  }

  getIconUrl(): string {
    return this.ad.getIcon()?.getImageUrl() ?? ``
  }

  getImageUrlList(): string[] {
    let result = new Array<string>()
    let imageList = this.ad.getImageList()
    if (imageList) {
      for (const element of imageList) {
        if (element && BYStrUtil.isNotEmpty(element.getImageUrl())) {
          result.push(element.getImageUrl())
        }
      }
    }
    return result
  }

  // getAdViewWidth(): number {
  //   return this.ad.getAdViewWidth()
  // }
  //
  // getAdViewHeight(): number {
  //   return this.ad.getAdViewHeight()
  // }

  isVideoAd(): boolean {
    let result = false
    let imgMode = this.ad.getImageMode()
    if (imgMode == CSJConstant.IMAGE_MODE_VIDEO
      || imgMode == CSJConstant.IMAGE_MODE_VIDEO_VERTICAL
      || imgMode == CSJConstant.IMAGE_MODE_SQUARE_VIDEO) {
      result = true
    }
    return result
  }

  getAdLogoView(): NodeController {
    return new BYCustomNodeController(wrapBuilder(AdvCSJLogoViewBuilder), this.ad)
  }

  getAdComponent(): NodeController | undefined {
    return this.ad.getAdComponent()
  }

  registerViewForInteraction(uiContext: UIContext, rootViewId: string, clickableViewIds:string[]) {
    let clickIds = new CSJArrayList<string>()
    for (const element of clickableViewIds) {
      clickIds.addAdId(element)
    }
    this.ad.registerViewForInteraction(rootViewId, uiContext, clickIds, new CSJArrayList())
  }

  getClickHandler(): (event: ClickEvent) => void {
    return () => {}
  }

  getVisibleAreaRatios(): number[] {
    return []
  }

  getVisibleAreaChangeListener(): (isVisible: boolean, currentRatio: number) => void {
    return () => {}
  }

}

@Builder
export function AdvCSJLogoViewBuilder(ad: CSJFeedAd) {
  Row() {
    if (typeof ad.getAdLogo() === "string") {
      Text(ad.getAdLogo())
        .fontSize(8)
        .height(14)
        .width(30)
        .fontColor(Color.White)
        .backgroundColor('rgba(0, 0, 0, 0.3)')
        .textAlign(TextAlign.Center)
    } else {
      Image(ad.getAdLogo())
        .height(20)
        .width(30)
        .objectFit(ImageFit.Auto)
    }
  }
  .justifyContent(FlexAlign.Center)
}