import {
  AdvanceError, AdvanceRequestOption, AdvanceBanner, AdvanceAdInfo
} from 'AdvanceSDK'
import { PageTitleView } from '../components/PageTitleView';
import { PosIdSelector } from '../components/PosIdSelector'
import { logToast } from '../util/Toast'

@Entry
@Component
struct Banner {
  @State placementId: string = '10014620' // mercury
  private readonly placementIdArr: Array<[string, string]> = [
    ['10014620', '横幅-倍业'],
    ['10014622', '横幅-穿山甲'],
    ['10014618', '横幅-优量汇'],
  ];
  @State bannerAd?: AdvanceBanner = undefined

  build() {
    Column({ space: 20 }) {
      PageTitleView({title: 'Banner广告'})
      PosIdSelector({
        posId: this.placementId,
        posIdArr: this.placementIdArr,
      })
      Button('加载并展示广告')
        .width('100%')
        .onClick(() => {
          let opt = new AdvanceRequestOption(this.placementId, 375, 120)
          this.bannerAd = new AdvanceBanner(opt)
          this.bannerAd.setAdListener({
            onAdLoaded: (adInfo: AdvanceAdInfo) => {
              logToast(`onAdLoaded, adInfo: ${JSON.stringify(adInfo)}`)
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
            },
            onAdClick: () => {
              logToast(`onAdClick`)
            },
            onAdClose: () => {
              // logToast(`onAdClose`)
              this.bannerAd = undefined
            },
          })
          this.bannerAd.loadAd()
        })
      if (this.bannerAd?.isAdValid()) {
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