import { window } from '@kit.ArkUI';
import {
  BYLog,
  AdvanceError,
  AdvanceSplashCommonAdapter,
} from 'advancesdk';
import { MercuryCloseType, MercuryEntry, MercuryErr, MercuryRenderOption, MercurySplash, MercurySplashRenderListener } from 'mercuryadhar';


const TAG = `[AdvMercurySplashAdapter]`

export class AdvMercurySplashAdapter extends AdvanceSplashCommonAdapter {
  protected mercury_ad?: MercurySplash

  adapter_isAdValid(): boolean {
    return true
  }

  adapter_loadAd() {
    //执行广告加载流程
    let spotId = this.unitData.supplier.adspotid
    let opt = new MercuryEntry().setCodeId(spotId)
    this.mercury_ad = new MercurySplash(opt)
    this.mercury_ad.loadAd({
      onAdLoaded: () => {
        BYLog.debug(TAG + "开屏回调 - onAdLoaded")
        this.bridge?.bridge_didAdLoaded(this.unitData.supplier, this.mercury_ad?.getPrice())
      },
      onAdError: (err: MercuryErr): void => {
        BYLog.debug(TAG + `开屏回调 - onAdLoadFailed code: ${err.code} message: ${err.msg}`)
        this.bridge?.bridge_didAdLoadFailed(this.unitData.supplier, new AdvanceError(err.code, err.msg))
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

  protected interactionListener: MercurySplashRenderListener = {
    onShow: (): void => {
      BYLog.debug(TAG + "开屏回调 - onAdExposure")
      this.bridge?.bridge_didAdShow(this.unitData.supplier)
    },
    onClick: (): void => {
      BYLog.debug(TAG + "开屏回调 - onAdClick")
      this.bridge?.bridge_didAdClick(this.unitData.supplier)
    },
    onRenderErr: (err: MercuryErr): void => {
      BYLog.debug(TAG + "开屏回调 - onShowError")
      this.bridge?.bridge_didAdShowFailed(this.unitData.supplier, new AdvanceError(err.code, err.msg))
    },
    onClose: (type: MercuryCloseType): void => {
      BYLog.debug(TAG + `开屏回调 - onAdClose`)
      this.bridge?.bridge_didAdClose()
    }
  }

}