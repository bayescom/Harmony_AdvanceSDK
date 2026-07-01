import {
  BYLog,
  ADV_ERR_DATA_NULL,
  BYDisplay,
  AdvanceError,
  BYCustomNodeController,
  AdvanceCommonNativeExpressAdapter,
  AdvBidWinLossResult,
  AdvBidWinLossResultType,
} from 'advancesdk';
import { KSAdExposureFailCode, KSAdScene, KSAdSDK, KSBuildFeedAdView, KSFeedAd, KSVideoPlayError} from 'ksadsdk';
import { NodeController } from '@kit.ArkUI';


const TAG = `[AdvKSNativeExpressAdapter]`

export class AdvKSNativeExpressAdapter extends AdvanceCommonNativeExpressAdapter {
  protected ks_ad?: KSFeedAd

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
    const scene: KSAdScene = new KSAdScene()
      .setPosId(spotId)
      .setAdNum(1)
      .setWidth(width)
      .setHeight(height) // ks bug：非0时，内容区域为height的高度，但是信息流容器高度依旧为素材自适应展示的高度
    const that = this // 参照快手demo内写法；因为callback内获取的this不是当前adpater对象，而是listener对象
    KSAdSDK.getLoadManager().loadFeedAd(scene, {
      onRequestSuccess(ads: Array<KSFeedAd>) {
        // 广告请求成功
      },
      onError(code: number, msg: string) {
        // 广告请求失败
        BYLog.debug(TAG + `模板信息流回调 - onAdLoadFailed code: ${code} message: ${msg}`)
        that.bridge?.nativeExpress_didAdLoadFailed(that, new AdvanceError(code, msg))
      },
      onAdLoad(ads: KSFeedAd[]) {
        // 广告成功加载，可以展示
        if (ads && ads.length > 0) {
          BYLog.debug(TAG + "模板信息流回调 - onAdLoaded")
          that.ks_ad = ads[0]
          that.bridge?.nativeExpress_didAdLoaded(that, that.ks_ad.getEcpm())
        } else {
          that.bridge?.nativeExpress_didAdLoadFailed(that, new AdvanceError(ADV_ERR_DATA_NULL, '广告返回内容为空'))
        };
      }
    })
  }
  
  adapter_render(context: UIContext): void {
    const that = this
    if (that.ks_ad) {
      BYLog.debug(TAG + "模板信息流回调 - onAdRenderSuccess")
      that.bridge?.nativeExpress_didAdRenderSuccess(that)

      that.ks_ad.setInteractListener({
        onAdShow() {
          BYLog.debug(TAG + "模板信息流回调 - onAdExposure")
          that.bridge?.nativeExpress_didAdShow(that)
        },
        onAdClick() {
          BYLog.debug(TAG + "模板信息流回调 - onAdClick")
          that.bridge?.nativeExpress_didAdClick(that)
        },
        onDislikeClicked() {
          BYLog.debug(TAG + `模板信息流回调 - onAdClose`)
          that.bridge?.nativeExpress_didAdClose(that)
        }
      })

      that.ks_ad.setVideoPlayListener({
        onVideoPlayStart() {
          BYLog.debug(TAG + "模板信息流回调 - onVideoStart")
          that.bridge?.nativeExpress_didAdVideoPlayStart(that)
        },
        onVideoPlayComplete() {
          BYLog.debug(TAG + "模板信息流回调 - onVideoEnd")
          that.bridge?.nativeExpress_didAdVideoPlayEnd(that)
        },
        onVideoPlayError(code: KSVideoPlayError, extra: string) {
          BYLog.debug(TAG + `模板信息流回调 - onVideoFailed`)
          that.bridge?.nativeExpress_didAdVideoPlayFailed(that, new AdvanceError(code, extra))
        }
      })
    }
  }

  adapter_getAdComponent(): NodeController | undefined {
    return new BYCustomNodeController(wrapBuilder(KSBuildFeedAdView), this.ks_ad)
  }

  adapter_sendNotification(result: AdvBidWinLossResult): void {
    if (result.bidResultType === AdvBidWinLossResultType.win) {
      this.ks_ad?.setBidEcpmAndHighestLoss(result.winPrice, result.secondPrice)
    } else {
      this.ks_ad?.reportExposureFail(KSAdExposureFailCode.BID_FAILED, {winEcpm: result.winPrice})
    }
  }

}