import {
  BYLog,
  AdvanceError,
  AdvanceRenderFeedCommonAdapter,
  AdvanceRenderFeedWrapper,
} from 'advancesdk';
import { MercuryCloseType, MercuryEntry, MercuryErr, MercuryNative } from 'mercuryadhar';
import { AdvMercuryRenderFeedAdWrapper } from './AdvMercuryRenderFeedAdWrapper';


const TAG = `[AdvMercuryRenderFeedAdapter]`

export class AdvMercuryRenderFeedAdapter extends AdvanceRenderFeedCommonAdapter {
  protected mercury_ad?: MercuryNative
  protected wrapper?: AdvanceRenderFeedWrapper | undefined

  adapter_loadAd() {
    //执行广告加载流程
    let spotId = this.unitData.supplier.adspotid
    let opt = new MercuryEntry()
      .setCodeId(spotId)
    this.mercury_ad = new MercuryNative(opt)
    this.mercury_ad.loadAd({
      onAdLoaded: () => {
        BYLog.debug(TAG + "自渲染信息流回调 - onAdLoaded")
        this.wrapper = new AdvMercuryRenderFeedAdWrapper(this.mercury_ad)
        this.bridge?.bridge_didAdLoaded(this.unitData.supplier, this.mercury_ad?.getPrice())
      },
      onAdError: (err: MercuryErr): void => {
        BYLog.debug(TAG + `自渲染信息流回调 - onAdLoadFailed code: ${err.code} message: ${err.msg}`)
        this.bridge?.bridge_didAdLoadFailed(this.unitData.supplier, new AdvanceError(err.code, err.msg))
      },
      onMaterialCached: (isFromCache: boolean) => {},
    })
  }

  adapter_render(context: UIContext): void {
    //Mercury广告没有渲染成功回调，load成功即认为渲染成功
    BYLog.debug(TAG + "模板信息流回调 - onAdRenderSuccess")
    this.bridge?.bridge_didAdRenderSuccess(this.unitData.supplier, this.wrapper!)

    this.mercury_ad?.setRenderListener({
      onShow: (): void => {
        BYLog.debug(TAG + "自渲染信息流回调 - onAdExposure")
        this.bridge?.bridge_didAdShow(this.unitData.supplier)
      },
      onClick: (): void => {
        BYLog.debug(TAG + "自渲染信息流回调 - onAdClick")
        this.bridge?.bridge_didAdClick(this.unitData.supplier)
      },
      onRenderErr: (err: MercuryErr): void => {
        BYLog.debug(TAG + "自渲染信息流回调 - onShowError")
        this.bridge?.bridge_didAdRenderFail(this.unitData.supplier, new AdvanceError(err.code, err.msg))
      },
      onClose: (type: MercuryCloseType): void => {
        BYLog.debug(TAG + `自渲染信息流回调 - onAdClose`)
        // this.bridge?.bridge_didAdClose()
      }
    })
  }

}