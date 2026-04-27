import { NodeController } from '@kit.ArkUI';
import {
  BYLog,
  AdvanceError,
  AdvanceNativeExpressCommonAdapter,
  BYDisplay,
} from 'advancesdk';
import { MercuryCloseType, MercuryEntry, MercuryErr, MercuryFeed, MercuryVideoPlayListener, MercuryFeedRenderListener } from 'mercury_ad';


const TAG = `[AdvMercuryNativeExpressAdapter]`

export class AdvMercuryNativeExpressAdapter extends AdvanceNativeExpressCommonAdapter {
  protected mercury_ad?: MercuryFeed

  adapter_loadAd() {
    //执行广告加载流程
    let spotId = this.unitData.supplier.adspotid
    let width = this.unitData.vpWidth ?? 0
    let height = this.unitData.vpHeight ?? 0
    //未配置的话取屏幕宽
    if (width <= 0) {
      width = BYDisplay.px2VP(BYDisplay.getScreenWPX())
    }
    //高度0代表自适应
    if (height <= 0) {
      height = 0
    }
    let opt = new MercuryEntry()
      .setCodeId(spotId)
      .setAdSize(width, height)
    this.mercury_ad = new MercuryFeed(opt)
    this.mercury_ad.loadAd({
      onAdLoaded: () => {
        BYLog.debug(TAG + "模板信息流回调 - onAdLoaded")
        this.bridge?.bridge_didAdLoaded(this.unitData.supplier, this.mercury_ad?.getPrice())
      },
      onAdError: (err: MercuryErr): void => {
        BYLog.debug(TAG + `模板信息流回调 - onAdLoadFailed code: ${err.code} message: ${err.msg}`)
        this.bridge?.bridge_didAdLoadFailed(this.unitData.supplier, new AdvanceError(err.code, err.msg))
      },
      onMaterialCached: (isFromCache: boolean) => {},
    })
  }

  adapter_render(context: UIContext): void {
    //Mercury广告没有渲染成功回调，load成功即认为渲染成功
    BYLog.debug(TAG + "模板信息流回调 - onAdRenderSuccess")
    this.bridge?.bridge_didAdRenderSuccess(this.unitData.supplier)
    this.mercury_ad?.setRenderListener(this.interactionListener)
    this.mercury_ad?.setVideoPlayListener(this.videoStateListener)
  }

  protected interactionListener: MercuryFeedRenderListener = {
    onShow: (): void => {
      BYLog.debug(TAG + "模板信息流回调 - onAdExposure")
      this.bridge?.bridge_didAdShow(this.unitData.supplier)
    },
    onClick: (): void => {
      BYLog.debug(TAG + "模板信息流回调 - onAdClick")
      this.bridge?.bridge_didAdClick(this.unitData.supplier)
    },
    onRenderErr: (err: MercuryErr): void => {
      BYLog.debug(TAG + "模板信息流回调 - onShowError")
      this.bridge?.bridge_didAdRenderFail(this.unitData.supplier, new AdvanceError(err.code, err.msg))
    },
    onClose: (type: MercuryCloseType): void => {
      BYLog.debug(TAG + `模板信息流回调 - onAdClose`)
      this.bridge?.bridge_didAdClose()
    }
  }

  protected videoStateListener: MercuryVideoPlayListener = {
    onStart: (): void => {
      BYLog.debug(TAG + "模板信息流回调 - onVideoStart")
      this.bridge?.bridge_didAdVideoPlayStart()
    },
    onEnd: (): void => {
      BYLog.debug(TAG + "模板信息流回调 - onVideoEnd")
      this.bridge?.bridge_didAdVideoPlayEnd()
    },
    onError: (err: MercuryErr): void => {
      BYLog.debug(TAG + `模板信息流回调 - onVideoFailed`)
      this.bridge?.bridge_didAdVideoPlayFailed(new AdvanceError(err.code, err.msg))
    },
    onPause: (): void => {}
  }

  adapter_getAdComponent(): NodeController | undefined {
    return this.mercury_ad?.getAdComponent()
  }

}