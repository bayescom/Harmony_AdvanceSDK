import { window } from '@kit.ArkUI';
import {
  BYLog,
  AdvanceError,
  AdvanceRewardVideoCommonAdapter,
} from 'advancesdk';
import { KSAdScene, KSAdSDK, KSAdScreenDirection, KSRewardAd, KSAdExposureFailCode} from 'ksadsdk';


const TAG = `[AdvKSRewardVideoAdapter]`

export class AdvKSRewardVideoAdapter extends AdvanceRewardVideoCommonAdapter {
  protected ks_ad?: KSRewardAd

  adapter_isAdValid(): boolean {
    return true
  }

  adapter_loadAd() {
    //执行广告加载流程
    let spotId = this.unitData.supplier.adspotid
    const scene: KSAdScene = new KSAdScene()
      .setPosId(spotId)
      .setAdNum(1)
      .setScreenOrientation(KSAdScreenDirection.vertical);
    const that = this // 参照快手demo内写法；因为callback内获取的this不是当前adpater对象，而是listener对象
    KSAdSDK.getLoadManager().loadRewardAd(scene, {
      onRequestSuccess(ad: KSRewardAd) {
        // 广告请求成功
      },
      onError(code: number, msg: string) {
        // 广告请求失败
        BYLog.debug(TAG + `激励视频回调 - onAdLoadFailed code: ${code} message: ${msg}`)
        that.bridge?.bridge_didAdLoadFailed(that.unitData.supplier, new AdvanceError(code, msg))
      },
      onAdLoad(ad: KSRewardAd) {
        // 广告成功加载，可以展示
        BYLog.debug(TAG + "激励视频回调 - onAdLoaded")
        that.ks_ad = ad
        that.bridge?.bridge_cacheAdapterIfNeeded(that, that.unitData.supplier, ad.getEcpm())
        that.bridge?.bridge_didAdLoaded(that.unitData.supplier, ad.getEcpm())
      }
    })
  }

  adapter_showAd(windowStage: window.WindowStage) {
    const that = this
    if (that.ks_ad) {
      that.ks_ad?.setInteractListener({
        onAdShow() {
          BYLog.debug(TAG + "激励视频回调 - onAdExposure")
          that.bridge?.bridge_didAdShow(that.unitData.supplier)
        },
        onAdClick() {
          BYLog.debug(TAG + "激励视频回调 - onAdClick")
          that.bridge?.bridge_didAdClick(that.unitData.supplier)
        },
        onAdClose() {
          BYLog.debug(TAG + `激励视频回调 - onAdClose`)
          that.bridge?.bridge_didAdClose()
        },
        onRewardVerify() {
          BYLog.debug(TAG + `激励视频回调 - onAdReward`)
          that.bridge?.bridge_didAdReward()
        },
        onVideoPlayEnd() {
          BYLog.debug(TAG + `激励视频回调 - onAdPlayEnd`)
          that.bridge?.bridge_didAdVideoPlayEnd()
        }
      })
      that.ks_ad?.show({videoSoundEnable: false })
    }
  }

  adapter_sendWinNotification(secondPrice: number, winPrice: number): void {
    this.ks_ad?.setBidEcpmAndHighestLoss(winPrice, secondPrice)
  }

  adapter_sendLossNotification(firstPrice: number): void {
    this.ks_ad?.reportExposureFail(KSAdExposureFailCode.BID_FAILED, {winEcpm: firstPrice})
  }

}