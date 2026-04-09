import {
  AdvanceError, AdvanceSplash, AdvanceAdInfo, AdvanceAdLoadConfig
} from 'advancesdk'
import { PageTitleView } from '../components/PageTitleView';
import { PosIdSelector } from '../components/PosIdSelector'
import { logToast, toast } from '../util/Toast'

@Entry
@Component
struct Splash {
  @State placementId: string = '10014760' // bidding
  private readonly placementIdArr: Array<[string, string]> = [
    ['10014760', '开屏-Bidding'],
    ['10014541', '开屏-倍业'],
    ['10014521', '开屏-穿山甲'],
    ['10014522', '开屏-优量汇'],
    ['10014526', '开屏-快手'],
  ];
  splashAd?: AdvanceSplash = undefined

  build() {
    Column({ space: 20 }) {
      PageTitleView({title: '开屏广告'})
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
          this.splashAd = new AdvanceSplash(config)
          this.splashAd.setAdListener({
            onAdLoaded: (adInfo: AdvanceAdInfo) => {
              logToast(`onAdLoaded, adInfo: ${JSON.stringify(adInfo)}`)
            },
            onAdLoadFailed: (err: AdvanceError) => {
              logToast(`onAdLoadFailed, err: ${err.toString()}`)
              this.splashAd = undefined
            },
            onAdShow: () => {
              logToast(`onAdShow`)
            },
            onAdShowFailed: (error: AdvanceError) => {
              logToast(`onAdShowFailed, err: ${error.toString()}`)
              this.splashAd = undefined
            },
            onAdClick: () => {
              logToast(`onAdClick`)
            },
            onAdClose: () => {
              // logToast(`onAdClose`)
              this.splashAd = undefined
            },
          })
          this.splashAd.loadAd()
        })
      Button('展示广告')
        .width('100%')
        .onClick(() => {
          if (!this.splashAd) {
            toast(`请先请求广告`)
            return
          }
          if (this.splashAd.isAdValid()) {
            this.splashAd.showAd()
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