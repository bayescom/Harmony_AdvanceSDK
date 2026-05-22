import {
  AdvanceError, AdvanceAdLoadConfig, AdvanceRewardVideo, AdvanceAdInfo, AdvRewardVideoModel,
  AdvanceRewardVideoListener,
  AdvRewardCallbackInfo
} from 'advancesdk'
import { PageTitleView } from '../components/PageTitleView';
import { PosIdSelector } from '../components/PosIdSelector'
import { logToast, toast } from '../util/Toast'

@Entry
@Component
struct Interstitial {
  // 10012265: 服务端激励验证
  @State placementId: string = '10014806' // bidding
  private readonly placementIdArr: Array<[string, string]> = [
    ['10014806', '激励视频-Bidding'],
    ['10014606', '激励视频-倍业'],
    ['10014605', '激励视频-穿山甲'],
    ['10014604', '激励视频-优量汇'],
    ['10014607', '激励视频-快手'],
    ['10014972', '激励视频-华为'],
  ];
  rewardVideoAd?: AdvanceRewardVideo = undefined

  listener: AdvanceRewardVideoListener = {
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
    onAdRewardSuccess: (rewardInfo: AdvRewardCallbackInfo) => {
      logToast(`onAdRewardSuccess`)
    },
    onAdServerRewardFail: (error: AdvanceError) => {
      logToast(`onAdServerRewardFail`)
    },
    onVideoPlayEnd: () => {
      logToast(`onVideoPlayEnd`)
    }
  }

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
          // 奖励设置（可选）
          const model: AdvRewardVideoModel = {
            userId: '123456',
            rewardAmount: 100,
            rewardName: '福利',
            extra: JSON.stringify({"key1": "value1"}) // 透传参数
            }
          let config: AdvanceAdLoadConfig = {
            placementId: this.placementId,
            rewardVideoModel: model
          }
          this.rewardVideoAd = new AdvanceRewardVideo(config)
          this.rewardVideoAd.setAdListener(this.listener)
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