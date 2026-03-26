import {
  AdvanceError, AdvanceAdLoadConfig, AdvanceInterstitial, AdvanceAdInfo
} from 'advancesdk'
import { PageTitleView } from '../components/PageTitleView';
import { PosIdSelector } from '../components/PosIdSelector'
import { logToast, toast } from '../util/Toast'

@Entry
@Component
struct Interstitial {
  @State placementId: string = '10014593' // mercury
  private readonly placementIdArr: Array<[string, string]> = [
    ['10014593', '插屏-倍业'],
    ['10014592', '插屏-穿山甲'],
    ['10014591', '插屏-优量汇'],
    ['10014594', '插屏-快手'],
  ];
  interstitialAd?: AdvanceInterstitial = undefined

  build() {
    Column({ space: 20 }) {
      PageTitleView({title: '插屏广告'})
      PosIdSelector({
        posId: this.placementId,
        posIdArr: this.placementIdArr,
      })
      Button('加载广告')
        .width('100%')
        .onClick(() => {
          let config: AdvanceAdLoadConfig = {
            placementId: this.placementId,
          }
          this.interstitialAd = new AdvanceInterstitial(config)
          this.interstitialAd.setAdListener({
            onAdLoaded: (adInfo: AdvanceAdInfo) => {
              logToast(`onAdLoaded, adInfo: ${JSON.stringify(adInfo)}`)
            },
            onAdLoadFailed: (err: AdvanceError) => {
              logToast(`onAdLoadFailed, err: ${err.toString()}`)
              this.interstitialAd = undefined
            },
            onAdShow: () => {
              logToast(`onAdShow`)
            },
            onAdShowFailed: (error: AdvanceError) => {
              logToast(`onAdShowFailed, err: ${error.toString()}`)
              this.interstitialAd = undefined
            },
            onAdClick: () => {
              logToast(`onAdClick`)
            },
            onAdClose: () => {
              // logToast(`onAdClose`)
              this.interstitialAd = undefined
            },
          })
          this.interstitialAd.loadAd()
        })
      Button('展示广告')
        .width('100%')
        .onClick(() => {
          if (!this.interstitialAd) {
            toast(`请先请求广告`)
            return
          }
          if (this.interstitialAd.isAdValid()) {
            this.interstitialAd.showAd()
          }
        })
    }.width('100%')
    .padding({
      top: 10,
      left: 20,
      right: 20,
      bottom: 10
    })
  }
}