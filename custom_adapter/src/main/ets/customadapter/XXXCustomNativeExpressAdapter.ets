import { BYLog, BYDisplay,
  ADV_ERR_DATA_NULL, AdvanceError,
  AdvanceCommonNativeExpressAdapter,
  AdvBidWinLossResult,
  AdvBidWinLossResultType} from 'advancesdk';
import { NodeController, UIContext } from '@kit.ArkUI';
import { AdSlotBuilder, CSJAdCreator, CSJAdSdk,
  CSJDislikeInteractionCallback,
  CSJNativeExpressAd,
  ExpressAdInteractionListener,
  ExpressVideoAdListener} from '@csj/openadsdk';
import { ArrayList } from '@kit.ArkTS';

const TAG = `[XXXCustomNativeExpressAdapter] `

export class XXXCustomNativeExpressAdapter extends AdvanceCommonNativeExpressAdapter {
  protected csj_ad?: CSJNativeExpressAd

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
    let mAdCreator: CSJAdCreator = CSJAdSdk.getAdCreator()
    let adSlot = new AdSlotBuilder()
      .setCodeId(spotId)
      .setAcceptSize(width, height)
      .build()

    mAdCreator.loadExpressFeedAd(adSlot, {
      onNativeExpressAdLoad: (ads: ArrayList<CSJNativeExpressAd>) => {
        if (ads && ads.length > 0) {
          BYLog.debug(TAG + "模板信息流回调 - onAdLoaded")
          this.csj_ad = ads[0]
          // 穿山甲变现SDK不提供ecpm获取
          this.bridge?.nativeExpress_didAdLoaded(this, 0)
        } else {
          this.bridge?.nativeExpress_didAdLoadFailed(this, new AdvanceError(ADV_ERR_DATA_NULL, '广告返回内容为空'))
        };
      },
      onError: (code: number, message: string) => {
        BYLog.debug(TAG + `模板信息流回调 - onAdLoadFailed code: ${code} message: ${message}`)
        this.bridge?.nativeExpress_didAdLoadFailed(this, new AdvanceError(code, message))
      }
    })
  }

  adapter_render(context: UIContext) {
    this.csj_ad?.setExpressInteractionListener(this.interactionListener)
    this.csj_ad?.setDislikeCallback(this.dislikeCallback)
    this.csj_ad?.setVideoAdListener(this.videoStateListener)
    this.csj_ad?.render(context)
  }

  adapter_getAdComponent(): NodeController | undefined {
    return this.csj_ad?.getAdComponent()
  }

  adapter_sendNotification(result: AdvBidWinLossResult): void {
    if (result.bidResultType === AdvBidWinLossResultType.win) {
      this.csj_ad?.win(result.secondPrice)
    } else {
      this.csj_ad?.loss(result.winPrice)
    }
  }

  protected interactionListener: ExpressAdInteractionListener = {
    onRenderSuccess: (width: number, height: number) => {
      BYLog.debug(TAG + "模板信息流回调 - onAdRenderSuccess")
      this.bridge?.nativeExpress_didAdRenderSuccess(this)
    },
    onRenderFail: (code: number, msg: string) => {
      BYLog.debug(TAG + "模板信息流回调 - onAdRenderFail")
      this.bridge?.nativeExpress_didAdRenderFail(this, new AdvanceError(code, msg))
    },
    onAdShow: (type: number) => {
      BYLog.debug(TAG + "模板信息流回调 - onAdExposure")
      this.bridge?.nativeExpress_didAdShow(this)
    },
    onAdClicked: (type: number) => {
      BYLog.debug(TAG + "模板信息流回调 - onAdClick")
      this.bridge?.nativeExpress_didAdClick(this)
    }
  }

  protected videoStateListener: ExpressVideoAdListener = {
    onVideoAdStartPlay: () => {
      BYLog.debug(TAG + "模板信息流回调 - onVideoStart")
      this.bridge?.nativeExpress_didAdVideoPlayStart(this)
    },
    onVideoAdComplete: () => {
      BYLog.debug(TAG + "模板信息流回调 - onVideoEnd")
      this.bridge?.nativeExpress_didAdVideoPlayEnd(this)
    },
    onVideoError: (errorCode: number, msg: string) =>  {
      BYLog.debug(TAG + `模板信息流回调 - onVideoFailed`)
      this.bridge?.nativeExpress_didAdVideoPlayFailed(this, new AdvanceError(errorCode, msg))
    },
    onVideoLoad: () =>  {},
    onVideoAdPaused: () =>  {},
    onVideoAdContinuePlay: () => {},
    onProgressUpdate: (current: number, duration: number) => {},
    onClickReplay: () => {}
  }

  protected  dislikeCallback: CSJDislikeInteractionCallback = {
    onShow: () => {
    },
    /**
     * @param position 选择的位置
     * @param value 选择的内容
     * @param enforceRemove 是否强制关闭广告
     */
    onSelected: (position: number, value: string, enforceRemove: boolean) => {
      BYLog.debug(TAG + `模板信息流回调 - onAdClose`)
      this.bridge?.nativeExpress_didAdClose(this)
    },
    onCancel: () => {

    }
  }

}