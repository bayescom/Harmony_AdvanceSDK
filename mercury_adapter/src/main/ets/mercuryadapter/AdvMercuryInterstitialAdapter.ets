import { window } from '@kit.ArkUI';
import {
  BYLog,
  AdvanceError,
  AdvanceCommonInterstitialAdapter, AdvBidWinLossResult,
} from 'advancesdk';
import { MercuryCloseType, MercuryEntry, MercuryErr,
  MercuryInterstitial,
  MercuryRenderOption, MercuryInterstitialRenderListener } from 'mercury_ad';


const TAG = `[AdvMercuryInterstitialAdapter]`

export class AdvMercuryInterstitialAdapter extends AdvanceCommonInterstitialAdapter {
  protected mercury_ad?: MercuryInterstitial

  adapter_isAdValid(): boolean {
    return true
  }

  adapter_loadAd() {
    //执行广告加载流程
    let spotId = this.unitData.placementId
    let opt = new MercuryEntry().setCodeId(spotId)
    this.mercury_ad = new MercuryInterstitial(opt)
    this.mercury_ad.loadAd({
      onAdLoaded: () => {
        BYLog.debug(TAG + "插屏回调 - onAdLoaded")
        this.bridge?.interstitial_didAdLoaded(this, this.mercury_ad?.getPrice() ?? 0)
      },
      onAdError: (err: MercuryErr): void => {
        BYLog.debug(TAG + `插屏回调 - onAdLoadFailed code: ${err.code} message: ${err.msg}`)
        this.bridge?.interstitial_didAdLoadFailed(this, new AdvanceError(err.code, err.msg))
      },
      onMaterialCached: (isFromCache: boolean) => {},
    })
  }

  adapter_showAd(windowStage: window.WindowStage) {
    this.mercury_ad?.setRenderListener(this.interactionListener)
    let renOp = new MercuryRenderOption()
    renOp.windowStage = windowStage
    renOp.layoutFullScreen = false
    this.mercury_ad?.showAd(renOp)
  }

  adapter_sendNotification(result: AdvBidWinLossResult): void {

  }

  protected interactionListener: MercuryInterstitialRenderListener = {
    onShow: (): void => {
      BYLog.debug(TAG + "插屏回调 - onAdExposure")
      this.bridge?.interstitial_didAdShow(this)
    },
    onClick: (): void => {
      BYLog.debug(TAG + "插屏回调 - onAdClick")
      this.bridge?.interstitial_didAdClick(this)
    },
    onRenderErr: (err: MercuryErr): void => {
      BYLog.debug(TAG + "插屏回调 - onShowError")
      this.bridge?.interstitial_didAdShowFailed(this, new AdvanceError(err.code, err.msg))
    },
    onClose: (type: MercuryCloseType): void => {
      BYLog.debug(TAG + `插屏回调 - onAdClose`)
      this.bridge?.interstitial_didAdClose(this)
    }
  }

}