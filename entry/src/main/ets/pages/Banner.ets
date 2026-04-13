import {
  AdvanceError, AdvanceAdLoadConfig, AdvanceBanner, AdvanceAdInfo
} from 'advancesdk'
import { PageTitleView } from '../components/PageTitleView';
import { PosIdSelector } from '../components/PosIdSelector'
import { logToast } from '../util/Toast'

@Entry
@Component
struct Banner {
  @State placementId: string = '10014782' // bidding
  private readonly placementIdArr: Array<[string, string]> = [
    ['10014782', '横幅-Bidding'],
    ['10014620', '横幅-倍业'],
    ['10014622', '横幅-穿山甲'],
    ['10014618', '横幅-优量汇'],
  ];
  @State isShowAd: boolean = false
  bannerAd?: AdvanceBanner = undefined

  build() {
    Column({ space: 20 }) {
      PageTitleView({title: '横幅广告'})
      PosIdSelector({
        posId: this.placementId,
        posIdArr: this.placementIdArr,
      })
      Button('加载并展示广告')
        .width('100%')
        .onClick(() => {
          let config: AdvanceAdLoadConfig = {
            placementId: this.placementId,
            adWidth: 375,
            adHeight: 120
          }
          this.isShowAd = false
          this.bannerAd = new AdvanceBanner(config)
          this.bannerAd.setAdListener({
            onAdLoaded: (adInfo: AdvanceAdInfo) => {
              logToast(`onAdLoaded, adInfo: ${JSON.stringify(adInfo)}`)
              this.isShowAd = true
            },
            onAdLoadFailed: (err: AdvanceError) => {
              logToast(`onAdLoadFailed, err: ${err.toString()}`)
              this.bannerAd = undefined
            },
            onAdShow: () => {
              logToast(`onAdShow`)
            },
            onAdShowFailed: (error: AdvanceError) => {
              logToast(`onAdShowFailed, err: ${error.toString()}`)
              this.bannerAd = undefined
              this.isShowAd = false
            },
            onAdClick: () => {
              logToast(`onAdClick`)
            },
            onAdClose: () => {
              // logToast(`onAdClose`)
              this.bannerAd = undefined
              this.isShowAd = false
            },
          })
          this.bannerAd.loadAd()
        })
      if (this.isShowAd && this.bannerAd?.isAdValid()) {
        NodeContainer(this.bannerAd?.getAdComponent())
          .width(this.bannerAd?.getAcceptWidth())
          .height(this.bannerAd?.getAcceptHeight())
      }
    }.width('100%')
    .padding({
      top: 10,
      left: 20,
      right: 20,
      bottom: 10
    })
  }
}