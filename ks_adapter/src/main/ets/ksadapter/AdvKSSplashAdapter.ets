import { window } from '@kit.ArkUI';
import {
  BYLog,
  AdvanceSplashCommonAdapter,
  BYWindowUtil,
  AdvanceError,
} from 'advancesdk';
import { KSAdScene, KSAdSDK, KSSplashAd, KSAdInteractionType} from 'ksadsdk';
import { KS_DISPLAY_PAGE_TAG, KS_STORAGE_AD_KEY } from './Component/AdvKSDisplayPageView';


const TAG = `[AdvKSSplashAdapter]`

export class AdvKSSplashAdapter extends AdvanceSplashCommonAdapter {
  protected ks_ad?: KSSplashAd

  adapter_isAdValid(): boolean {
    return true
  }

  adapter_loadAd() {
    //执行广告加载流程
    let spotId = this.unitData.supplier.adspotid
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
        that.bridge?.bridge_didAdLoadFailed(that.unitData.supplier, new AdvanceError(code, msg))
      },
      onAdLoad(splashAd: KSSplashAd) {
        // 广告成功加载，可以展示
        BYLog.debug(TAG + "开屏回调 - onAdLoaded")
        that.ks_ad = splashAd
        that.bridge?.bridge_didAdLoaded(that.unitData.supplier, splashAd.getEcpm())
      }
    })
  }

  adapter_showAd(windowStage: window.WindowStage) {
    const that = this
    if (that.ks_ad) {
      that.ks_ad?.setInteractListener({
        onAdShowStart() {
          BYLog.debug(TAG + "开屏回调 - onAdExposure")
          that.bridge?.bridge_didAdShow(that.unitData.supplier)
        },
        onAdShowEnd() {
          BYWindowUtil.destroySubWindow()
        },
        onAdClick(interactionType?: KSAdInteractionType) {
          BYLog.debug(TAG + "开屏回调 - onAdClick")
          BYWindowUtil.destroySubWindow()
          that.bridge?.bridge_didAdClick(that.unitData.supplier)
        },
        onAdSkip() {
          BYLog.debug(TAG + `开屏回调 - onAdClose`)
          BYWindowUtil.destroySubWindow()
          that.bridge?.bridge_didAdClose()
        },
        onCloseLandingPage() {}
      })
      BYWindowUtil.createWindow(KS_DISPLAY_PAGE_TAG, KS_STORAGE_AD_KEY, that.ks_ad)
    }
  }

}