import { advertising, AdComponent } from "@kit.AdsKit";

export const HUAWEI_DISPLAY_PAGE_TAG = 'AdvHuaweiDisplayPageView'
export const HUAWEI_STORAGE_AD_KEY = 'AdvHuaweiAdStorageKey'

export interface AdvHuaweiDisplayData {
  ad?: advertising.Advertisement
  displayOptions?: advertising.AdDisplayOptions
  listener?: advertising.AdInteractionListener
  adWidth?: number
  adHeight?: number
}

@Entry({ routeName: HUAWEI_DISPLAY_PAGE_TAG })
@Component
export struct AdvHuaweiDisplayPageView {
  private data?: AdvHuaweiDisplayData

  aboutToAppear(): void {
    // 在页面中获取共享的LocalStorage实例
    let sharedStorage = this.getUIContext().getSharedLocalStorage();
    if (sharedStorage) {
      this.data = sharedStorage.get(HUAWEI_STORAGE_AD_KEY)
    }
  }

  aboutToDisappear(): void {
    let sharedStorage = this.getUIContext().getSharedLocalStorage();
    if (sharedStorage) {
      sharedStorage.clear
    }
  }

  build() {
    Column() {
      if (this.data?.ad?.adType === 1) { // 开屏
        AdComponent({
          ads: [this.data.ad],
          displayOptions: this.data.displayOptions,
          interactionListener: this.data.listener
        })
      }
    }
    .width('100%')
  }
}