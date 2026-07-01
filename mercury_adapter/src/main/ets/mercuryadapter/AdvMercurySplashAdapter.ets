import { window } from '@kit.ArkUI';
import {
  BYLog,
  AdvanceError, AdvanceCommonSplashAdapter, AdvBidWinLossResult,
} from 'advancesdk';
import { MercuryCloseType, MercuryEntry, MercuryErr, MercuryRenderOption, MercurySplash, MercurySplashRenderListener } from 'mercury_ad';


const TAG = `[AdvMercurySplashAdapter]`

export class AdvMercurySplashAdapter extends AdvanceCommonSplashAdapter {
  protected mercury_ad?: MercurySplash

  adapter_isAdValid(): boolean {
    return true
  }

  adapter_loadAd() {
    //执行广告加载流程
    let spotId = this.unitData.placementId
    let opt = new MercuryEntry().setCodeId(spotId)
    this.mercury_ad = new MercurySplash(opt)
    this.mercury_ad.loadAd({
      onAdLoaded: () => {
        BYLog.debug(TAG + "开屏回调 - onAdLoaded")
        this.bridge?.splash_didAdLoaded(this, this.mercury_ad?.getPrice() ?? 0)
      },
      onAdError: (err: MercuryErr): void => {
        BYLog.debug(TAG + `开屏回调 - onAdLoadFailed code: ${err.code} message: ${err.msg}`)
        this.bridge?.splash_didAdLoadFailed(this, new AdvanceError(err.code, err.msg))
      },
      onMaterialCached: (isFromCache: boolean) => {},
    })
  }

  adapter_showAd(windowStage: window.WindowStage) {
    this.mercury_ad?.setRenderListener(this.interactionListener)
    let renOp = new MercuryRenderOption()
    renOp.windowStage = windowStage
    this.mercury_ad?.showAd(renOp)
  }

  adapter_sendNotification(result: AdvBidWinLossResult): void {

  }

  protected interactionListener: MercurySplashRenderListener = {
    onShow: (): void => {
      BYLog.debug(TAG + "开屏回调 - onAdExposure")
      this.bridge?.splash_didAdShow(this)
    },
    onClick: (): void => {
      BYLog.debug(TAG + "开屏回调 - onAdClick")
      this.bridge?.splash_didAdClick(this)
    },
    onRenderErr: (err: MercuryErr): void => {
      BYLog.debug(TAG + "开屏回调 - onShowError")
      this.bridge?.splash_didAdShowFailed(this, new AdvanceError(err.code, err.msg))
    },
    onClose: (type: MercuryCloseType): void => {
      BYLog.debug(TAG + `开屏回调 - onAdClose`)
      this.bridge?.splash_didAdClose(this)
    }
  }

}