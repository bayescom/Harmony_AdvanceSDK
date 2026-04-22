import { NodeController } from '@kit.ArkUI';
import {
  BYLog,
  AdvanceError,
  AdvanceBannerCommonAdapter,
} from 'advancesdk';
import { MercuryCloseType, MercuryEntry, MercuryErr,
  MercuryBanner, MercuryBannerRenderListener } from 'mercuryadhar';


const TAG = `[AdvMercuryBannerAdapter]`

export class AdvMercuryBannerAdapter extends AdvanceBannerCommonAdapter {
  protected mercury_ad?: MercuryBanner

  adapter_isAdValid(): boolean {
    return true
  }

  adapter_loadAd() {
    //执行广告加载流程
    let spotId = this.unitData.supplier.adspotid
    let width = this.unitData.vpWidth ?? 0
    let height = this.unitData.vpHeight ?? 0
    let opt = new MercuryEntry()
      .setCodeId(spotId)
      .setAdSize(width, height)
    this.mercury_ad = new MercuryBanner(opt)
    this.mercury_ad.loadAd({
      onAdLoaded: () => {
        BYLog.debug(TAG + "横幅回调 - onAdLoaded")
        this.bridge?.bridge_didAdLoaded(this.unitData.supplier, this.mercury_ad?.getPrice())
      },
      onAdError: (err: MercuryErr): void => {
        BYLog.debug(TAG + `横幅回调 - onAdLoadFailed code: ${err.code} message: ${err.msg}`)
        this.bridge?.bridge_didAdLoadFailed(this.unitData.supplier, new AdvanceError(err.code, err.msg))
      },
      onMaterialCached: (isFromCache: boolean) => {},
    })
  }

  adapter_render(context: UIContext): void {
    this.mercury_ad?.setRenderListener(this.interactionListener)
  }

  protected interactionListener: MercuryBannerRenderListener = {
    onShow: (): void => {
      BYLog.debug(TAG + "横幅回调 - onAdExposure")
      this.bridge?.bridge_didAdShow(this.unitData.supplier)
    },
    onClick: (): void => {
      BYLog.debug(TAG + "横幅回调 - onAdClick")
      this.bridge?.bridge_didAdClick(this.unitData.supplier)
    },
    onRenderErr: (err: MercuryErr): void => {
      BYLog.debug(TAG + "横幅回调 - onShowError")
      this.bridge?.bridge_didAdShowFailed(this.unitData.supplier, new AdvanceError(err.code, err.msg))
    },
    onClose: (type: MercuryCloseType): void => {
      BYLog.debug(TAG + `横幅回调 - onAdClose`)
      this.bridge?.bridge_didAdClose()
    }
  }

  adapter_getAdComponent(): NodeController | undefined {
    return this.mercury_ad?.getAdComponent()
  }

}