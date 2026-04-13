import { window } from '@kit.ArkUI';
import {
  BYLog,
  BYWindowUtil,
  AdvanceInterstitialCommonAdapter,
  AdvanceError,
} from 'advancesdk';
import { KSAdScene, KSAdSDK, KSAdScreenDirection, KSNewInterstitialAd} from 'ksadsdk';
import { KS_DISPLAY_PAGE_TAG, STORAGE_AD_KEY } from './Component/AdvKSDisplayPageView';


const TAG = `[AdvKSInterstitialAdapter]`

export class AdvKSInterstitialAdapter extends AdvanceInterstitialCommonAdapter {
  protected ks_ad?: KSNewInterstitialAd

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
    KSAdSDK.getLoadManager().loadNewInterstitialAd(scene, {
      onRequestSuccess(ad: KSNewInterstitialAd) {
        // 广告请求成功
      },
      onError(code: number, msg: string) {
        // 广告请求失败
        BYLog.debug(TAG + `插屏回调 - onAdLoadFailed code: ${code} message: ${msg}`)
        that.bridge?.bridge_didAdLoadFailed(that.unitData.supplier, new AdvanceError(code, msg))
      },
      onAdLoad(ad: KSNewInterstitialAd) {
        // 广告成功加载，可以展示
        BYLog.debug(TAG + "插屏回调 - onAdLoaded")
        that.ks_ad = ad
        that.bridge?.bridge_didAdLoaded(that.unitData.supplier, ad.getEcpm())
      }
    })
  }

  adapter_showAd(windowStage: window.WindowStage) {
    const that = this
    if (that.ks_ad) {
      that.ks_ad?.setInteractListener({
        onAdShow() {
          BYLog.debug(TAG + "插屏回调 - onAdExposure")
          that.bridge?.bridge_didAdShow(that.unitData.supplier)
        },
        onAdClick() {
          BYLog.debug(TAG + "插屏回调 - onAdClick")
          that.bridge?.bridge_didAdClick(that.unitData.supplier)
        },
        onAdClose() {
          BYLog.debug(TAG + `插屏回调 - onAdClose`)
          BYWindowUtil.destroySubWindow()
          that.bridge?.bridge_didAdClose()
        },
        onVideoPlayStart() {},
        onVideoPlayEnd() {},
      })
      BYWindowUtil.createWindow(KS_DISPLAY_PAGE_TAG, STORAGE_AD_KEY, that.ks_ad)
    }
  }

}