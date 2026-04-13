import { AdvanceRenderFeedWrapper } from 'advancesdk';
import { NodeController } from '@kit.ArkUI';
import { GDTAdPattern, GDTManualAd } from '@gdt/gdt-union-sdk';
import { GDTAdData } from '@gdt/gdt-union-sdk/src/main/ets/e/g/l2';

export class AdvGDTRenderFeedAdWrapper implements AdvanceRenderFeedWrapper {
  ad: GDTManualAd
  data: GDTAdData

  constructor(ad: GDTManualAd) {
    this.ad = ad
    this.data = ad.getAdData()
  }

  getTitle(): string {
    return this.data.getTitle()
  }

  getDescription(): string {
    return this.data.getDesc()
  }

  getButtonText(): string {
    return this.data.getButtonText()
  }

  getIconUrl(): string {
    return this.data.getIconUrl()
  }

  getImageUrlList(): string[] {
    let result = new Array<string>()
    let adPattern = this.ad.getAdPattern()
    if (adPattern === GDTAdPattern.NormalImage) {
      result.push(this.data.getImgUrl())
    } else if (adPattern === GDTAdPattern.ThreeImage) {
      result = this.data.getImgList()
    }
    return result
  }

  // getAdViewWidth(): number {
  //   return this.data.getImgWidth()
  // }
  //
  // getAdViewHeight(): number {
  //   return this.data.getImgHeight()
  // }

  isVideoAd(): boolean {
    let adPattern = this.ad.getAdPattern()
    return adPattern === GDTAdPattern.Video
  }

  getAdLogoView(): NodeController | undefined {
    return this.ad.getAdLogoView()
  }

  getAdComponent(): NodeController | undefined {
    return this.ad.getAdComponent()
  }

  registerViewForInteraction(uiContext: UIContext, rootViewId: string, clickableViewIds:string[]) {
    this.ad.registerViewForInteraction(uiContext, rootViewId, clickableViewIds)
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