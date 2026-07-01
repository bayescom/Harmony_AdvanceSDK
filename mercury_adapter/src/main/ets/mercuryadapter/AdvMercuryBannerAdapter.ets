import { NodeController } from '@kit.ArkUI';
import {
  BYLog,
  AdvanceError, AdvanceCommonBannerAdapter, AdvBidWinLossResult,
} from 'advancesdk';
import { MercuryCloseType, MercuryEntry, MercuryErr,
  MercuryBanner, MercuryBannerRenderListener } from 'mercury_ad';


const TAG = `[AdvMercuryBannerAdapter]`

export class AdvMercuryBannerAdapter extends AdvanceCommonBannerAdapter {
  protected mercury_ad?: MercuryBanner

  adapter_isAdValid(): boolean {
    return true
  }

  adapter_loadAd() {
    //执行广告加载流程
    let spotId = this.unitData.placementId
    let width = this.unitData.vpWidth ?? 0
    let height = this.unitData.vpHeight ?? 0
    let opt = new MercuryEntry()
      .setCodeId(spotId)
      .setAdSize(width, height)
    this.mercury_ad = new MercuryBanner(opt)
    this.mercury_ad.loadAd({
      onAdLoaded: () => {
        BYLog.debug(TAG + "横幅回调 - onAdLoaded")
        this.bridge?.banner_didAdLoaded(this, this.mercury_ad?.getPrice() ?? 0)
      },
      onAdError: (err: MercuryErr): void => {
        BYLog.debug(TAG + `横幅回调 - onAdLoadFailed code: ${err.code} message: ${err.msg}`)
        this.bridge?.banner_didAdLoadFailed(this, new AdvanceError(err.code, err.msg))
      },
      onMaterialCached: (isFromCache: boolean) => {},
    })
  }

  adapter_render(context: UIContext): void {
    this.mercury_ad?.setRenderListener(this.interactionListener)
  }

  adapter_sendNotification(result: AdvBidWinLossResult): void {

  }

  protected interactionListener: MercuryBannerRenderListener = {
    onShow: (): void => {
      BYLog.debug(TAG + "横幅回调 - onAdExposure")
      this.bridge?.banner_didAdShow(this)
    },
    onClick: (): void => {
      BYLog.debug(TAG + "横幅回调 - onAdClick")
      this.bridge?.banner_didAdClick(this)
    },
    onRenderErr: (err: MercuryErr): void => {
      BYLog.debug(TAG + "横幅回调 - onShowError")
      this.bridge?.banner_didAdShowFailed(this, new AdvanceError(err.code, err.msg))
    },
    onClose: (type: MercuryCloseType): void => {
      BYLog.debug(TAG + `横幅回调 - onAdClose`)
      this.bridge?.banner_didAdClose(this)
    }
  }

  adapter_getAdComponent(): NodeController | undefined {
    return this.mercury_ad?.getAdComponent()
  }

}