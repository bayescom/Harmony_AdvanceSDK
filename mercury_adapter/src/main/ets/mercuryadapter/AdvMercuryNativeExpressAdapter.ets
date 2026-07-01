import { NodeController } from '@kit.ArkUI';
import {
  BYLog,
  AdvanceError,
  BYDisplay,
  AdvanceCommonNativeExpressAdapter,
  AdvBidWinLossResult,
} from 'advancesdk';
import { MercuryCloseType, MercuryEntry, MercuryErr, MercuryFeed, MercuryVideoPlayListener, MercuryFeedRenderListener } from 'mercury_ad';


const TAG = `[AdvMercuryNativeExpressAdapter]`

export class AdvMercuryNativeExpressAdapter extends AdvanceCommonNativeExpressAdapter {
  protected mercury_ad?: MercuryFeed

  adapter_loadAd() {
    //执行广告加载流程
    let spotId = this.unitData.placementId
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
        this.bridge?.nativeExpress_didAdLoaded(this, this.mercury_ad?.getPrice() ?? 0)
      },
      onAdError: (err: MercuryErr): void => {
        BYLog.debug(TAG + `模板信息流回调 - onAdLoadFailed code: ${err.code} message: ${err.msg}`)
        this.bridge?.nativeExpress_didAdLoadFailed(this, new AdvanceError(err.code, err.msg))
      },
      onMaterialCached: (isFromCache: boolean) => {},
    })
  }

  adapter_render(context: UIContext): void {
    //Mercury广告没有渲染成功回调，load成功即认为渲染成功
    BYLog.debug(TAG + "模板信息流回调 - onAdRenderSuccess")
    this.bridge?.nativeExpress_didAdRenderSuccess(this)
    this.mercury_ad?.setRenderListener(this.interactionListener)
    this.mercury_ad?.setVideoPlayListener(this.videoStateListener)
  }

  adapter_sendNotification(result: AdvBidWinLossResult): void {

  }

  protected interactionListener: MercuryFeedRenderListener = {
    onShow: (): void => {
      BYLog.debug(TAG + "模板信息流回调 - onAdExposure")
      this.bridge?.nativeExpress_didAdShow(this)
    },
    onClick: (): void => {
      BYLog.debug(TAG + "模板信息流回调 - onAdClick")
      this.bridge?.nativeExpress_didAdClick(this)
    },
    onRenderErr: (err: MercuryErr): void => {
      BYLog.debug(TAG + "模板信息流回调 - onShowError")
      this.bridge?.nativeExpress_didAdRenderFail(this, new AdvanceError(err.code, err.msg))
    },
    onClose: (type: MercuryCloseType): void => {
      BYLog.debug(TAG + `模板信息流回调 - onAdClose`)
      this.bridge?.nativeExpress_didAdClose(this)
    }
  }

  protected videoStateListener: MercuryVideoPlayListener = {
    onStart: (): void => {
      BYLog.debug(TAG + "模板信息流回调 - onVideoStart")
      this.bridge?.nativeExpress_didAdVideoPlayStart(this)
    },
    onEnd: (): void => {
      BYLog.debug(TAG + "模板信息流回调 - onVideoEnd")
      this.bridge?.nativeExpress_didAdVideoPlayEnd(this)
    },
    onError: (err: MercuryErr): void => {
      BYLog.debug(TAG + `模板信息流回调 - onVideoFailed`)
      this.bridge?.nativeExpress_didAdVideoPlayFailed(this, new AdvanceError(err.code, err.msg))
    },
    onPause: (): void => {}
  }

  adapter_getAdComponent(): NodeController | undefined {
    return this.mercury_ad?.getAdComponent()
  }

}