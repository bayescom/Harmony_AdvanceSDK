import { KSAdBuildSplashView, KSSplashAd, KSBuildNewInterstitialAdView,
  KSNewInterstitialAd } from "ksadsdk"

export const KS_DISPLAY_PAGE_TAG = 'AdvKSDisplayPageView'
export const KS_STORAGE_AD_KEY = 'AdvKSAdStorageKey'

@Entry({ routeName: KS_DISPLAY_PAGE_TAG })
@Component
export struct AdvKSDisplayPageView {
  private ks_ad?: object

  aboutToAppear(): void {
    // 在页面中获取共享的LocalStorage实例
    let sharedStorage = this.getUIContext().getSharedLocalStorage();
    if (sharedStorage) {
      this.ks_ad = sharedStorage.get(KS_STORAGE_AD_KEY)
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
        } else if (this.ks_ad instanceof KSNewInterstitialAd) {
          KSBuildNewInterstitialAdView(this.ks_ad)
        }
      }
    }
    .width('100%')
  }
}