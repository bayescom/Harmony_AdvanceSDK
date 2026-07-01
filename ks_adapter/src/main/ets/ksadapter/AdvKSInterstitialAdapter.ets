import { window } from '@kit.ArkUI';
import {
  BYLog,
  BYWindowUtil,
  AdvanceError,
  AdvanceCommonInterstitialAdapter,
  AdvBidWinLossResult,
  AdvBidWinLossResultType,
} from 'advancesdk';
import { KSAdScene, KSAdSDK, KSAdScreenDirection, KSNewInterstitialAd, KSAdExposureFailCode} from 'ksadsdk';
import { KS_DISPLAY_PAGE_TAG, KS_STORAGE_AD_KEY } from './Component/AdvKSDisplayPageView';


const TAG = `[AdvKSInterstitialAdapter]`

export class AdvKSInterstitialAdapter extends AdvanceCommonInterstitialAdapter {
  protected ks_ad?: KSNewInterstitialAd

  adapter_isAdValid(): boolean {
    return true
  }

  adapter_loadAd() {
    //执行广告加载流程
    let spotId = this.unitData.placementId
    const scene: KSAdScene = new KSAdScene()
      .setPosId(spotId)
      .setAdNum(1)
      .setScreenOrientation(KSAdScreenDirection.vertical);
    const that = this // 参照快手demo内写法；因为callback内获取的this不是当前adpater对象，而是listener对象
    KSAdSDK.getLoadManager().loadNewInterstitialAd(scene, {
      onRequestSuccess(ad: KSNewInterstitialAd) {
        // 广告请求成功
      },
      onError(code: number, msg: string) {
        // 广告请求失败
        BYLog.debug(TAG + `插屏回调 - onAdLoadFailed code: ${code} message: ${msg}`)
        that.bridge?.interstitial_didAdLoadFailed(that, new AdvanceError(code, msg))
      },
      onAdLoad(ad: KSNewInterstitialAd) {
        // 广告成功加载，可以展示
        BYLog.debug(TAG + "插屏回调 - onAdLoaded")
        that.ks_ad = ad
        that.bridge?.interstitial_didAdLoaded(that, ad.getEcpm())
      }
    })
  }

  adapter_showAd(windowStage: window.WindowStage) {
    const that = this
    if (that.ks_ad) {
      that.ks_ad?.setInteractListener({
        onAdShow() {
          BYLog.debug(TAG + "插屏回调 - onAdExposure")
          that.bridge?.interstitial_didAdShow(that)
        },
        onAdClick() {
          BYLog.debug(TAG + "插屏回调 - onAdClick")
          that.bridge?.interstitial_didAdClick(that)
        },
        onAdClose() {
          BYLog.debug(TAG + `插屏回调 - onAdClose`)
          BYWindowUtil.destroySubWindow()
          that.bridge?.interstitial_didAdClose(that)
        },
        onVideoPlayStart() {},
        onVideoPlayEnd() {},
      })
      BYWindowUtil.createWindow(KS_DISPLAY_PAGE_TAG, KS_STORAGE_AD_KEY, that.ks_ad)
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