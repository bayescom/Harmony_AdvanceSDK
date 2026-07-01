import { window } from '@kit.ArkUI';
import {
  BYLog,
  BYWindowUtil,
  AdvanceError,
  AdvanceCommonSplashAdapter,
  AdvBidWinLossResult,
  AdvBidWinLossResultType,
} from 'advancesdk';
import { KSAdScene, KSAdSDK, KSSplashAd, KSAdInteractionType, KSAdExposureFailCode} from 'ksadsdk';
import { KS_DISPLAY_PAGE_TAG, KS_STORAGE_AD_KEY } from './Component/AdvKSDisplayPageView';


const TAG = `[AdvKSSplashAdapter]`

export class AdvKSSplashAdapter extends AdvanceCommonSplashAdapter {
  protected ks_ad?: KSSplashAd

  adapter_isAdValid(): boolean {
    return true
  }

  adapter_loadAd() {
    //执行广告加载流程
    let spotId = this.unitData.placementId
    const scene: KSAdScene = new KSAdScene()
      .setPosId(spotId)
      .setAdNum(1);
    const that = this // 参照快手demo内写法；因为callback内获取的this不是当前adpater对象，而是listener对象
    KSAdSDK.getLoadManager().loadSplashAd(scene, {
      onRequestSuccess(splashAd: KSSplashAd) {
        // 广告请求成功
      },
      onError(code: number, msg: string) {
        // 广告请求失败
        BYLog.debug(TAG + `开屏回调 - onAdLoadFailed code: ${code} message: ${msg}`)
        that.bridge?.splash_didAdLoadFailed(that, new AdvanceError(code, msg))
      },
      onAdLoad(splashAd: KSSplashAd) {
        // 广告成功加载，可以展示
        BYLog.debug(TAG + "开屏回调 - onAdLoaded")
        that.ks_ad = splashAd
        that.bridge?.splash_didAdLoaded(that, splashAd.getEcpm())
      }
    })
  }

  adapter_showAd(windowStage: window.WindowStage) {
    const that = this
    if (that.ks_ad) {
      that.ks_ad?.setInteractListener({
        onAdShowStart() {
          BYLog.debug(TAG + "开屏回调 - onAdExposure")
          that.bridge?.splash_didAdShow(that)
        },
        onAdShowEnd() {
          BYLog.debug(TAG + "开屏回调 - onAdShowEnd")
          BYWindowUtil.destroySubWindow()
        },
        onAdClick(interactionType?: KSAdInteractionType) {
          BYLog.debug(TAG + "开屏回调 - onAdClick")
          BYWindowUtil.destroySubWindow()
          that.bridge?.splash_didAdClick(that)
        },
        onAdSkip() {
          BYLog.debug(TAG + `开屏回调 - onAdClose`)
          BYWindowUtil.destroySubWindow()
          that.bridge?.splash_didAdClose(that)
        },
        onCloseLandingPage() {}
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