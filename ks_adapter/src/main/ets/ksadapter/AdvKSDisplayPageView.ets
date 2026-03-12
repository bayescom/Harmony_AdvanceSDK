import { KSAdBuildSplashView, KSInterstitialAd, KSSplashAd, KSBuildNewInterstitialAdView } from "ksadsdk"

export const KS_DISPLAY_PAGE_TAG = 'AdvKSDisplayPageView'
export const STORAGE_AD_KEY = 'AdvKSAdStorageKey'

@Entry({ routeName: KS_DISPLAY_PAGE_TAG })
@Component
export struct AdvKSDisplayPageView {
  private ks_ad?: object

  aboutToAppear(): void {
    // 在页面中获取共享的LocalStorage实例
    let sharedStorage = this.getUIContext().getSharedLocalStorage();
    if (sharedStorage) {
      this.ks_ad = sharedStorage.get(STORAGE_AD_KEY)
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
      if (this.ks_ad) {
        if (this.ks_ad instanceof KSSplashAd) {
          KSAdBuildSplashView(this.ks_ad)
        } else if (this.ks_ad instanceof KSInterstitialAd) {
          KSBuildNewInterstitialAdView(this.ks_ad)
        }
      }
    }
    .width('100%')
  }
}