import {
  BYLog,
  AdvanceError,
  AdvanceRenderFeedAdWrapper,
  AdvanceCommonRenderFeedAdapter,
  AdvBidWinLossResult,
} from 'advancesdk';
import { MercuryCloseType, MercuryEntry, MercuryErr, MercuryNative, MercuryNativeRenderListener, MercuryVideoPlayListener } from 'mercury_ad';
import { AdvMercuryRenderFeedAdWrapper } from './AdvMercuryRenderFeedAdWrapper';


const TAG = `[AdvMercuryRenderFeedAdapter]`

export class AdvMercuryRenderFeedAdapter extends AdvanceCommonRenderFeedAdapter {
  protected mercury_ad?: MercuryNative
  protected wrapper?: AdvanceRenderFeedAdWrapper | undefined

  adapter_loadAd() {
    //执行广告加载流程
    let spotId = this.unitData.placementId
    let opt = new MercuryEntry()
      .setCodeId(spotId)
    this.mercury_ad = new MercuryNative(opt)
    this.mercury_ad.loadAd({
      onAdLoaded: () => {
        BYLog.debug(TAG + "自渲染信息流回调 - onAdLoaded")
        this.wrapper = new AdvMercuryRenderFeedAdWrapper(this.mercury_ad)
        this.bridge?.renderFeed_didAdLoaded(this, this.mercury_ad?.getPrice() ?? 0)
      },
      onAdError: (err: MercuryErr): void => {
        BYLog.debug(TAG + `自渲染信息流回调 - onAdLoadFailed code: ${err.code} message: ${err.msg}`)
        this.bridge?.renderFeed_didAdLoadFailed(this, new AdvanceError(err.code, err.msg))
      },
      onMaterialCached: (isFromCache: boolean) => {},
    })
  }

  adapter_render(context: UIContext): void {
    //Mercury广告没有渲染成功回调，load成功即认为渲染成功
    BYLog.debug(TAG + "自渲染信息流回调 - onAdRenderSuccess")
    this.bridge?.renderFeed_didAdRenderSuccess(this, this.wrapper!)
    this.mercury_ad?.setRenderListener(this.interactionListener)
    this.mercury_ad?.setVideoPlayListener(this.videoStateListener)
  }

  adapter_sendNotification(result: AdvBidWinLossResult): void {

  }

  protected interactionListener: MercuryNativeRenderListener = {
    onShow: (): void => {
      BYLog.debug(TAG + "自渲染信息流回调 - onAdExposure")
      this.bridge?.renderFeed_didAdShow(this)
    },
    onClick: (): void => {
      BYLog.debug(TAG + "自渲染信息流回调 - onAdClick")
      this.bridge?.renderFeed_didAdClick(this)
    },
    onRenderErr: (err: MercuryErr): void => {
      BYLog.debug(TAG + "自渲染信息流回调 - onShowError")
      this.bridge?.renderFeed_didAdRenderFail(this, new AdvanceError(err.code, err.msg))
    },
    onClose: (type: MercuryCloseType): void => {
      BYLog.debug(TAG + `自渲染信息流回调 - onAdClose`)
      // this.bridge?.renderFeed_didAdClose()
    }
  }

  protected videoStateListener: MercuryVideoPlayListener = {
    onStart: (): void => {
      BYLog.debug(TAG + "自渲染信息流回调 - onVideoStart")
      this.bridge?.renderFeed_didAdVideoPlayStart(this)
    },
    onEnd: (): void => {
      BYLog.debug(TAG + "自渲染信息流回调 - onVideoEnd")
      this.bridge?.renderFeed_didAdVideoPlayEnd(this)
    },
    onError: (err: MercuryErr): void => {
      BYLog.debug(TAG + `自渲染信息流回调 - onVideoFailed`)
      this.bridge?.renderFeed_didAdVideoPlayFailed(this, new AdvanceError(err.code, err.msg))
    },
    onPause: (): void => {}
  }

}