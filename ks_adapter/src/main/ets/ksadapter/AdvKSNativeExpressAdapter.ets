import {
  BYLog,
  ADV_ERR_DATA_NULL,
  AdvanceNativeExpressCommonAdapter,
  BYDisplay,
  AdvanceError,
  BYCustomNodeController,
} from 'advancesdk';
import { KSAdScene, KSAdSDK, KSBuildFeedAdView, KSFeedAd, KSVideoPlayError} from 'ksadsdk';
import { NodeController } from '@kit.ArkUI';


const TAG = `[AdvKSNativeExpressAdapter]`

export class AdvKSNativeExpressAdapter extends AdvanceNativeExpressCommonAdapter {
  protected ks_ad?: KSFeedAd

  adapter_loadAd() {
    //执行广告加载流程
    let spotId = this.unitData.supplier.adspotid
    let width = this.unitData.ext?.vpWidth ?? 0
    let height = this.unitData.ext?.vpHeight ?? 0
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
        that.bridge?.bridge_didAdLoadFailed(that.unitData.supplier, new AdvanceError(code, msg))
      },
      onAdLoad(ads: KSFeedAd[]) {
        // 广告成功加载，可以展示
        if (ads && ads.length > 0) {
          BYLog.debug(TAG + "模板信息流回调 - onAdLoaded")
          that.ks_ad = ads[0]
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
      BYLog.debug(TAG + "模板信息流回调 - onAdRenderSuccess")
      that.bridge?.bridge_didAdRenderSuccess(that.unitData.supplier)

      that.ks_ad.setInteractListener({
        onAdShow() {
          BYLog.debug(TAG + "模板信息流回调 - onAdExposure")
          that.bridge?.bridge_didAdShow(that.unitData.supplier)
        },
        onAdClick() {
          BYLog.debug(TAG + "模板信息流回调 - onAdClick")
          that.bridge?.bridge_didAdClick(that.unitData.supplier)
        },
        onDislikeClicked() {
          BYLog.debug(TAG + `模板信息流回调 - onAdClose`)
          that.bridge?.bridge_didAdClose()
        }
      })

      that.ks_ad.setVideoPlayListener({
        onVideoPlayStart() {
          BYLog.debug(TAG + "模板信息流回调 - onVideoStart")
          this.bridge?.bridge_didAdVideoPlayStart()
        },
        onVideoPlayComplete() {
          BYLog.debug(TAG + "模板信息流回调 - onVideoEnd")
          this.bridge?.bridge_didAdVideoPlayEnd()
        },
        onVideoPlayError(code: KSVideoPlayError, extra: string) {
          BYLog.debug(TAG + `模板信息流回调 - onVideoFailed`)
          this.bridge?.bridge_didAdVideoPlayFailed(new AdvanceError(code, extra))
        }
      })
    }
  }

  adapter_getAdComponent(): NodeController | undefined {
    const that = this
    return new BYCustomNodeController(wrapBuilder(KSBuildFeedAdView), that.ks_ad)
  }

}