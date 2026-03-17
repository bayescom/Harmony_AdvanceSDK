import {
  AdvanceError, AdvanceRequestOption, AdvanceRewardVideo, AdvanceAdInfo
} from 'AdvanceSDK'
import { PageTitleView } from '../components/PageTitleView';
import { PosIdSelector } from '../components/PosIdSelector'
import { logToast, toast } from '../util/Toast'

@Entry
@Component
struct Interstitial {
  @State placementId: string = '10014606' // mercury
  private readonly placementIdArr: Array<[string, string]> = [
    ['10014606', '激励视频-倍业'],
    ['10014605', '激励视频-穿山甲'],
    ['10014604', '激励视频-优量汇'],
    ['10014607', '激励视频-快手'],
  ];
  rewardVideoAd?: AdvanceRewardVideo = undefined

  build() {
    Column({ space: 20 }) {
      PageTitleView({title: '激励视频广告'})
      PosIdSelector({
        posId: this.placementId,
        posIdArr: this.placementIdArr,
      })
      Button('加载广告')
        .width('100%')
        .onClick(() => {
          let opt = new AdvanceRequestOption(this.placementId)
          this.rewardVideoAd = new AdvanceRewardVideo(opt)
          this.rewardVideoAd.setAdListener({
            onAdLoaded: (adInfo: AdvanceAdInfo) => {
              logToast(`onAdLoaded, adInfo: ${JSON.stringify(adInfo)}`)
            },
            onAdLoadFailed: (err: AdvanceError) => {
              logToast(`onAdLoadFailed, err: ${err.toString()}`)
              this.rewardVideoAd = undefined
            },
            onAdShow: () => {
              logToast(`onAdShow`)
            },
            onAdShowFailed: (error: AdvanceError) => {
              logToast(`onAdShowFailed, err: ${error.toString()}`)
              this.rewardVideoAd = undefined
            },
            onAdClick: () => {
              logToast(`onAdClick`)
            },
            onAdClose: () => {
              // logToast(`onAdClose`)
              this.rewardVideoAd = undefined
            },
            onAdReward: () => {
              logToast(`onAdReward`)
            },
            onAdPlayEnd: () => {
              logToast(`onAdPlayEnd`)
            }
          })
          this.rewardVideoAd.loadAd()
        })
      Button('展示广告')
        .width('100%')
        .onClick(() => {
          if (!this.rewardVideoAd) {
            toast(`请先请求广告`)
            return
          }
          if (this.rewardVideoAd.isAdValid()) {
            this.rewardVideoAd.showAd()
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