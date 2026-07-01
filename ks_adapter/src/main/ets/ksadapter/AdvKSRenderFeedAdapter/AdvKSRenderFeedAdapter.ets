import {
  BYLog,
  ADV_ERR_DATA_NULL,
  AdvanceError,
  AdvanceRenderFeedAdWrapper,
  AdvanceCommonRenderFeedAdapter,
  AdvBidWinLossResult,
  AdvBidWinLossResultType,
} from 'advancesdk';
import { KSAdExposureFailCode, KSAdScene, KSAdSDK, KSNativeAd, KSVideoPlayError} from 'ksadsdk';
import { AdvKSRenderFeedAdWrapper } from './AdvKSRenderFeedAdWrapper';


const TAG = `[AdvKSRenderFeedAdapter]`

export class AdvKSRenderFeedAdapter extends AdvanceCommonRenderFeedAdapter {
  protected ks_ad?: KSNativeAd
  protected wrapper?: AdvanceRenderFeedAdWrapper | undefined

  adapter_loadAd() {
    //执行广告加载流程
    let spotId = this.unitData.placementId
    const scene: KSAdScene = new KSAdScene()
      .setPosId(spotId)
      .setAdNum(1)
    const that = this // 参照快手demo内写法；因为callback内获取的this不是当前adpater对象，而是listener对象
    KSAdSDK.getLoadManager().loadNativeAd(scene, {
      onRequestSuccess(ads: Array<KSNativeAd>) {
        // 广告请求成功
      },
      onError(code: number, msg: string) {
        // 广告请求失败
        BYLog.debug(TAG + `自渲染信息流回调 - onAdLoadFailed code: ${code} message: ${msg}`)
        that.bridge?.renderFeed_didAdLoadFailed(that, new AdvanceError(code, msg))
      },
      onAdLoad(ads: KSNativeAd[]) {
        // 广告成功加载，可以展示
        if (ads && ads.length > 0) {
          BYLog.debug(TAG + "自渲染信息流回调 - onAdLoaded")
          that.ks_ad = ads[0]
          that.wrapper = new AdvKSRenderFeedAdWrapper(that.ks_ad)
          that.bridge?.renderFeed_didAdLoaded(that, that.ks_ad.getEcpm())
        } else {
          that.bridge?.renderFeed_didAdLoadFailed(that, new AdvanceError(ADV_ERR_DATA_NULL, '广告返回内容为空'))
        };
      }
    })
  }
  
  adapter_render(context: UIContext): void {
    const that = this
    if (that.ks_ad) {
      BYLog.debug(TAG + "自渲染信息流回调 - onAdRenderSuccess")
      that.bridge?.renderFeed_didAdRenderSuccess(that, that.wrapper!)

      that.ks_ad.setInteractListener({
        onAdShow() {
          BYLog.debug(TAG + "自渲染信息流回调 - onAdExposure")
          that.bridge?.renderFeed_didAdShow(that)
        },
        onAdClick() {
          BYLog.debug(TAG + "自渲染信息流回调 - onAdClick")
          that.bridge?.renderFeed_didAdClick(that)
        }
      })

      that.ks_ad.setVideoPlayListener({
        onVideoPlayStart() {
          BYLog.debug(TAG + "自渲染信息流回调 - onVideoStart")
          that.bridge?.renderFeed_didAdVideoPlayStart(that)
        },
        onVideoPlayComplete() {
          BYLog.debug(TAG + "自渲染信息流回调 - onVideoEnd")
          that.bridge?.renderFeed_didAdVideoPlayEnd(that)
        },
        onVideoPlayError(code: KSVideoPlayError, extra: string) {
          BYLog.debug(TAG + `自渲染信息流回调 - onVideoFailed`)
          that.bridge?.renderFeed_didAdVideoPlayFailed(that, new AdvanceError(code, extra))
        }
      })
    }
  }

  adapter_sendNotification(result: AdvBidWinLossResult): void {
    if (result.bidResultType === AdvBidWinLossResultType.win) {
      this.ks_ad?.setBidEcpmAndHighestLoss(result.winPrice, result.secondPrice)
    } else {
      this.ks_ad?.reportExposureFail(KSAdExposureFailCode.BID_FAILED, {winEcpm: result.winPrice})
    }
  }

}