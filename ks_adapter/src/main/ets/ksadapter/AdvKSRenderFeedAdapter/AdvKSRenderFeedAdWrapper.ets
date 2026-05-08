import { AdvanceRenderFeedWrapper, BYConstant, BYCustomNodeController } from 'advancesdk';
import { NodeController } from '@kit.ArkUI';
import { KSAdImage, KSAdInteractionType, KSAdMaterialType, KSAdSourceLogoType,
  KSBuildNativeAdVideoView,
  KSNativeAd } from 'ksadsdk';

export class AdvKSRenderFeedAdWrapper implements AdvanceRenderFeedWrapper {
  ad: KSNativeAd

  constructor(ad: KSNativeAd) {
    this.ad = ad
  }

  getTitle(): string {
    return this.ad.getInteractionType() == KSAdInteractionType.download ?
    this.ad.getAppName() : this.ad.getProductName()
  }

  getDescription(): string {
    return this.ad.getAdDescription()
  }

  getButtonText(): string {
    return this.ad.getActionDescription()
  }

  getIconUrl(): string {
    return this.ad.getAppIconUrl()
  }

  getImageUrlList(): string[] {
    return this.ad.getImageList().map((e: KSAdImage) =>{
      return e.imageUrl
    })
  }

  // getAdViewWidth(): number {
  //   if (this.isVideoAd()) {
  //     return this.ad.getCoverUrl().width
  //   }
  //   return this.ad.getImageList()[0].width
  // }
  //
  // getAdViewHeight(): number {
  //   if (this.isVideoAd()) {
  //     return this.ad.getCoverUrl().height
  //   }
  //   return this.ad.getImageList()[0].height
  // }

  isVideoAd(): boolean {
    return this.ad.getMaterialType() == KSAdMaterialType.video
  }

  getAdLogoView(): NodeController | undefined {
    return new BYCustomNodeController(wrapBuilder(AdvKSLogoViewBuilder), this.ad)
  }

  getAdComponent(): NodeController | undefined {
    return new BYCustomNodeController(wrapBuilder(KSBuildNativeAdVideoView), this.ad)
  }

  registerViewForInteraction(uiContext: UIContext, rootViewId: string, clickableViewIds:string[]) {

  }

  getClickHandler(): (event: ClickEvent) => void {
    return (event: ClickEvent) => {
      this.ad.getClickHandler()(BYConstant.context, event)
    }
  }

  getVisibleAreaRatios(): number[] {
    return this.ad.getVisibleAreaRatios()
  }

  getVisibleAreaChangeListener(): (isVisible: boolean, currentRatio: number) => void {
    return this.ad.getVisibleAreaChangeListener()
  }

}

@Builder
export function AdvKSLogoViewBuilder(ad: KSNativeAd) {
  Row() {
    Image(ad.getAdSourceLogoUrl(KSAdSourceLogoType.normal))
      .width('10vp')
      .height('10vp')
    Text(ad.getAdSource())
      .margin({ left: '2vp' })
      .fontSize('10fp')
      .fontColor("#FFFFFF")
  }
  .height(14)
  .padding({ left: '2vp', right: '2vp' })
  .alignItems(VerticalAlign.Center)
  .backgroundColor("#25000000")
  .borderRadius('2vp')
}