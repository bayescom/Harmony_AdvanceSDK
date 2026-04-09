import {
  BYLog,
  ADV_ERR_DATA_NULL,
  AdvanceRenderFeedCommonAdapter,
  AdvanceError,
  AdvanceRenderFeedWrapper,
} from 'advancesdk';
import { KSAdScene, KSAdSDK, KSNativeAd, KSVideoPlayError} from 'ksadsdk';
import { AdvKSRenderFeedAdWrapper } from './AdvKSRenderFeedAdWrapper';


const TAG = `[AdvKSRenderFeedAdapter]`

export class AdvKSRenderFeedAdapter extends AdvanceRenderFeedCommonAdapter {
  protected ks_ad?: KSNativeAd
  protected wrapper?: AdvanceRenderFeedWrapper | undefined

  adapter_loadAd() {
    //执行广告加载流程
    let spotId = this.unitData.supplier.adspotid
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
        that.bridge?.bridge_didAdLoadFailed(that.unitData.supplier, new AdvanceError(code, msg))
      },
      onAdLoad(ads: KSNativeAd[]) {
        // 广告成功加载，可以展示
        if (ads && ads.length > 0) {
          BYLog.debug(TAG + "自渲染信息流回调 - onAdLoaded")
          that.ks_ad = ads[0]
          that.wrapper = new AdvKSRenderFeedAdWrapper(that.ks_ad)
          that.bridge?.bridge_didAdLoaded(that.unitData.supplier, that.ks_ad.getEcpm())
        } else {
          that.bridge?.bridge_didAdLoadFailed(that.unitData.supplier, new AdvanceError(ADV_ERR_DATA_NULL, '广告返回内容为空'))
        };
      }
    })
  }
  
  adapter_render(context: UIContext): void {
    const that = this
    if (that.ks_ad) {
      BYLog.debug(TAG + "自渲染信息流回调 - onAdRenderSuccess")
      that.bridge?.bridge_didAdRenderSuccess(that.unitData.supplier, that.wrapper!)

      that.ks_ad.setInteractListener({
        onAdShow() {
          BYLog.debug(TAG + "自渲染信息流回调 - onAdExposure")
          that.bridge?.bridge_didAdShow(that.unitData.supplier)
        },
        onAdClick() {
          BYLog.debug(TAG + "自渲染信息流回调 - onAdClick")
          that.bridge?.bridge_didAdClick(that.unitData.supplier)
        }
      })

      that.ks_ad.setVideoPlayListener({
        onVideoPlayStart() {
          BYLog.debug(TAG + "自渲染信息流回调 - onVideoStart")
          this.bridge?.bridge_didAdVideoPlayStart()
        },
        onVideoPlayComplete() {
          BYLog.debug(TAG + "自渲染信息流回调 - onVideoEnd")
          this.bridge?.bridge_didAdVideoPlayEnd()
        },
        onVideoPlayError(code: KSVideoPlayError, extra: string) {
          BYLog.debug(TAG + `自渲染信息流回调 - onVideoFailed`)
          this.bridge?.bridge_didAdVideoPlayFailed(new AdvanceError(code, extra))
        }
      })
    }
  }

}