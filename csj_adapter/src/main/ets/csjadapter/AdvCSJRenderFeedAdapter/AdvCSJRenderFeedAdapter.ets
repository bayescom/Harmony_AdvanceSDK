import { AdvanceRenderFeedCommonAdapter, AdvanceRenderFeedWrapper, BYLog, ADV_ERR_DATA_NULL,
  AdvanceError} from 'advancesdk';
import { AdSlot, AdSlotBuilder, CSJAdCreator,
  CSJAdInteractionListener,
  CSJAdSdk,
  CSJDislikeInteractionCallback,
  CSJFeedAd, CSJNativeAd,
  CSJVideoAdListener,
  ExpressRenderListener} from '@csj/openadsdk';
import { ArrayList } from '@kit.ArkTS';
import { AdvCSJRenderFeedAdWrapper } from './AdvCSJRenderFeedAdWrapper';

const TAG = `[AdvCSJRenderFeedAdapter] `

export class AdvCSJRenderFeedAdapter extends AdvanceRenderFeedCommonAdapter {
  protected csj_ad?: CSJFeedAd
  protected wrapper?: AdvanceRenderFeedWrapper | undefined

  adapter_loadAd() {
    //执行广告加载流程
    let spotId = this.unitData.supplier.adspotid
    let mAdCreator: CSJAdCreator = CSJAdSdk.getAdCreator()

    let adSlot: AdSlot = new AdSlotBuilder()
      .setCodeId(spotId)
      .setAdCount(1)
      .setSupportRenderControl(true)
      .build();

    mAdCreator.loadFeedAd(adSlot, {
      onFeedAdLoad: (ads: ArrayList<CSJFeedAd>) => {
        if (ads && ads.length > 0) {
          BYLog.debug(TAG + "自渲染信息流回调 - onAdLoaded")
          this.csj_ad = ads[0]
          this.wrapper = new AdvCSJRenderFeedAdWrapper(this.csj_ad)
          // 穿山甲变现SDK不提供ecpm获取
          this.bridge?.bridge_didAdLoaded(this.unitData.supplier, 0)
        } else {
          this.bridge?.bridge_didAdLoadFailed(this.unitData.supplier, new AdvanceError(ADV_ERR_DATA_NULL, '广告返回内容为空'))
        };
      },
      onError: (code: number, message: string) => {
        BYLog.debug(TAG + `自渲染息流回调 - onAdLoadFailed code: ${code} message: ${message}`)
        this.bridge?.bridge_didAdLoadFailed(this.unitData.supplier, new AdvanceError(code, message))
      }
    })
  }

  adapter_render(context: UIContext) {
    this.csj_ad?.setExpressRenderListener(this.renderListener)
    this.csj_ad?.setAdInteractionListener(this.interactionListener)
    this.csj_ad?.setDislikeCallback(this.dislikeCallback)
    this.csj_ad?.setVideoAdListener(this.videoStateListener)
    this.csj_ad?.render(context)
  }

  protected renderListener: ExpressRenderListener = {
    onRenderSuccess: (width: number, height: number, isExpress: boolean) => {
      BYLog.debug(TAG + "自渲染信息流回调 - onAdRenderSuccess")
      this.bridge?.bridge_didAdRenderSuccess(this.unitData.supplier, this.wrapper!)
    }
  }

  protected interactionListener: CSJAdInteractionListener = {
    onAdShow: (ad: CSJNativeAd) => {
      BYLog.debug(TAG + "自渲染信息流回调 - onAdExposure")
      this.bridge?.bridge_didAdShow(this.unitData.supplier)
    },
    onAdClicked: (ad: CSJNativeAd) => {
      BYLog.debug(TAG + "自渲染信息流回调 - onAdClick")
      this.bridge?.bridge_didAdClick(this.unitData.supplier)
    },
    onAdCreativeClick: (ad: CSJNativeAd) => {
      BYLog.debug(TAG + "自渲染信息流回调 - onAdClick")
      this.bridge?.bridge_didAdClick(this.unitData.supplier)
    }
  }

  protected videoStateListener: CSJVideoAdListener = {
    onVideoAdStartPlay: () => {
      BYLog.debug(TAG + "模板信息流回调 - onVideoStart")
      this.bridge?.bridge_didAdVideoPlayStart()
    },
    onVideoAdComplete: () => {
      BYLog.debug(TAG + "模板信息流回调 - onVideoEnd")
      this.bridge?.bridge_didAdVideoPlayEnd()
    },
    onVideoError: (errorCode: number, msg: string) =>  {
      BYLog.debug(TAG + `模板信息流回调 - onVideoFailed`)
      this.bridge?.bridge_didAdVideoPlayFailed(new AdvanceError(errorCode, msg))
    },
    onVideoLoad: () =>  {},
    onVideoAdPaused: () =>  {},
    onVideoAdContinuePlay: () => {},
    onProgressUpdate: (current: number, duration: number) => {},
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
      // this.bridge?.bridge_didAdClose()
    },
    onCancel: () => {

    }
  }

}