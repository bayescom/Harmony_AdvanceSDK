import { window } from '@kit.ArkUI';
import {
  BYLog,
  AdvanceError,
  AdvanceCommonRewardVideoAdapter, AdvBidWinLossResult,
  AdvBidWinLossResultType,
} from 'advancesdk';
import { KSAdScene, KSAdSDK, KSAdScreenDirection, KSRewardAd, KSAdExposureFailCode} from 'ksadsdk';


const TAG = `[AdvKSRewardVideoAdapter]`

export class AdvKSRewardVideoAdapter extends AdvanceCommonRewardVideoAdapter {
  protected ks_ad?: KSRewardAd

  adapter_isAdValid(): boolean {
    return true
  }

  adapter_loadAd() {
    //执行广告加载流程
    let spotId = this.unitData.placementId
    const scene: KSAdScene = new KSAdScene()
      .setPosId(spotId)
      .setAdNum(1)
      .setScreenOrientation(KSAdScreenDirection.vertical)
      .setRewardExtraData({
        thirdUserId: this.unitData.rewardVideoModel?.userId,
        extraData: this.unitData.rewardVideoModel?.extra
      })
    const that = this // 参照快手demo内写法；因为callback内获取的this不是当前adpater对象，而是listener对象
    KSAdSDK.getLoadManager().loadRewardAd(scene, {
      onRequestSuccess(ad: KSRewardAd) {
        // 广告请求成功
      },
      onError(code: number, msg: string) {
        // 广告请求失败
        BYLog.debug(TAG + `激励视频回调 - onAdLoadFailed code: ${code} message: ${msg}`)
        that.bridge?.rewardVideo_didAdLoadFailed(that, new AdvanceError(code, msg))
      },
      onAdLoad(ad: KSRewardAd) {
        // 广告成功加载，可以展示
        BYLog.debug(TAG + "激励视频回调 - onAdLoaded")
        that.ks_ad = ad
        that.bridge?.rewardVideo_didAdLoaded(that, ad.getEcpm())
      }
    })
  }

  adapter_showAd(windowStage: window.WindowStage) {
    const that = this
    if (that.ks_ad) {
      that.ks_ad?.setInteractListener({
        onAdShow() {
          BYLog.debug(TAG + "激励视频回调 - onAdExposure")
          that.bridge?.rewardVideo_didAdShow(that)
        },
        onAdClick() {
          BYLog.debug(TAG + "激励视频回调 - onAdClick")
          that.bridge?.rewardVideo_didAdClick(that)
        },
        onAdClose() {
          BYLog.debug(TAG + `激励视频回调 - onAdClose`)
          that.bridge?.rewardVideo_didAdClose(that)
        },
        onRewardVerify() {
          BYLog.debug(TAG + `激励视频回调 - onAdReward`)
          that.bridge?.rewardVideo_didAdReward(that)
        },
        onVideoPlayEnd() {
          BYLog.debug(TAG + `激励视频回调 - onAdPlayEnd`)
          that.bridge?.rewardVideo_didAdVideoPlayEnd(that)
        }
      })
      that.ks_ad?.show({videoSoundEnable: false })
    }
  }

  adapter_sendNotification(result: AdvBidWinLossResult): void {
    if (result.bidResultType === AdvBidWinLossResultType.win) {
      this.ks_ad?.setBidEcpmAndHighestLoss(result.winPrice, result.secondPrice)
    } else {
      this.ks_ad?.reportExposureFail(KSAdExposureFailCode.BID_FAILED, {winEcpm: result.winPrice})
    }
  }

}