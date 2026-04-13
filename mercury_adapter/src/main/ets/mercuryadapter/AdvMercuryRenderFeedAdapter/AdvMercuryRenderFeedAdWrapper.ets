import { AdvanceRenderFeedWrapper, BYConstant, BYCustomNodeController } from 'advancesdk';
import { NodeController } from '@kit.ArkUI';
import { MercuryNative, MercuryNativeData } from 'mercuryadhar';

export class AdvMercuryRenderFeedAdWrapper implements AdvanceRenderFeedWrapper {
  data: MercuryNativeData | undefined

  constructor(ad: MercuryNative) {
    this.data = ad.getSelfRenderData()
  }

  getTitle(): string {
    return this.data?.getTitle() ?? ""
  }

  getDescription(): string {
    return this.data?.getDesc() ?? ""
  }

  getButtonText(): string {
    return '查看详情'
  }

  getIconUrl(): string {
    return this.data?.getIconUrl() ?? ""
  }

  getImageUrlList(): string[] {
    return this.data?.getImgList() ?? []
  }

  isVideoAd(): boolean {
    return this.data?.isVideo() ?? false
  }

  getAdLogoView(): NodeController | undefined {
    return new BYCustomNodeController(wrapBuilder(AdvMercuryLogoViewBuilder), this.data)
  }

  getAdComponent(): NodeController | undefined {
    return undefined
  }

  registerViewForInteraction(uiContext: UIContext, rootViewId: string, clickableViewIds:string[]) {

  }

  getClickHandler(): (event: ClickEvent) => void {
    return (event: ClickEvent) => {
      this.data?.handleClick(BYConstant.context, event)
    }
  }

  getVisibleAreaRatios(): number[] {
    return this.data?.getVisibleAreaRatios() ?? []
  }

  getVisibleAreaChangeListener(): (isVisible: boolean, currentRatio: number) => void {
    return (isVisible: boolean, currentRatio: number) => {
      this.data?.handleVisibleAreaChange(isVisible, currentRatio)
    }
  }

}

@Builder
export function AdvMercuryLogoViewBuilder(data: MercuryNativeData) {
  Row() {
    if (data.getADSourceLogo()) {
      Image(data.getADSourceLogo())
        .width(10)
        .height(10)
        .margin({
          right: 2
        })
    }
    Text(data.getADSource())
      .fontSize(10)
      .textAlign(TextAlign.Center)
      .fontColor($r('app.color.mry_color_white'))
  }
  .height(14)
  .padding({ left: '2vp', right: '2vp' })
  .alignItems(VerticalAlign.Center)
  .backgroundColor("#25000000")
  .borderRadius('2vp')
}