import {
  BYLog,
  AdvanceAdnStatusResult,
  ADV_ERR_DATA_NULL,
  AdvanceAdLoadState,
  AdvanceRenderFeedCommonAdapter,
  AdvanceError,
  AdvanceRenderFeedWrapper,
} from 'advancesdk';
import { KSAdScene, KSAdSDK, KSNativeAd, KSVideoPlayError} from 'ksadsdk';
import { AdvKSUtil } from '../AdvKSUtil';
import { AdvKSRenderFeedAdWrapper } from './AdvKSRenderFeedAdWrapper';


const TAG = `[AdvKSRenderFeedAdapter]`

export class AdvKSRenderFeedAdapter extends AdvanceRenderFeedCommonAdapter {
  protected ks_ad?: KSNativeAd
  protected wrapper?: AdvanceRenderFeedWrapper | undefined

  adapter_loadAd(): Promise<AdvanceAdnStatusResult> {
    BYLog.debug(TAG + ` adapter_loadAd start`)
    return new Promise<AdvanceAdnStatusResult>(async (resolve) => {
      let result = new AdvanceAdnStatusResult()
      let initResult = await AdvKSUtil.loadKSSDK(this)
      BYLog.debug(TAG + `ks初始化执行结果：${JSON.stringify(initResult)}`)

      if (initResult.success) { // 初始化成功
        //执行广告加载流程
        let sup = this.unitData.supplier
        if (sup) {
          const scene: KSAdScene = new KSAdScene()
            .setPosId(sup.adspotid)
            .setAdNum(1)
          const that = this // 参照快手demo内写法；因为callback内获取的this不是当前adpater对象，而是listener对象
          KSAdSDK.getLoadManager().loadNativeAd(scene, {
            onRequestSuccess(ads: Array<KSNativeAd>) {
              // 广告请求成功
            },
            onError(code: number, msg: string) {
              // 广告请求失败
              BYLog.debug(TAG + `自渲染信息流回调 - onAdLoadFailed code: ${code} message: ${msg}`)
              result.status = AdvanceAdLoadState.failed
              result.errCode = code
              result.errMsg = msg
              resolve(result)
            },
            onAdLoad(ads: KSNativeAd[]) {
              // 广告成功加载，可以展示
              if (ads && ads.length > 0) {
                BYLog.debug(TAG + "自渲染信息流回调 - onAdLoaded")
                that.ks_ad = ads[0]
                that.wrapper = new AdvKSRenderFeedAdWrapper(that.ks_ad)
                result.status = AdvanceAdLoadState.success
                resolve(result)
              } else {
                result.status = AdvanceAdLoadState.failed
                result.errCode = ADV_ERR_DATA_NULL
                result.errMsg = '广告返回内容为空'
                resolve(result)
              };
            }
          })
        } else {
          result.status = AdvanceAdLoadState.failed
          result.errCode = ADV_ERR_DATA_NULL
          result.errMsg = '未找到该adn策略信息'
          resolve(result)
        }

      } else { // 初始化失败
        result.status = AdvanceAdLoadState.failed
        result.errCode = initResult.code
        result.errMsg = initResult.msg
        resolve(result)
      }
    })
  }
  
  adapter_render(context: UIContext): void {
    const that = this
    if (that.ks_ad) {
      BYLog.debug(TAG + "自渲染信息流回调 - onAdRenderSuccess")
      that.bridge?.bridge_didAdRenderSuccess(that.wrapper!)

      that.ks_ad.setInteractListener({
        onAdShow() {
          BYLog.debug(TAG + "自渲染信息流回调 - onAdExposure")
          that.bridge?.bridge_didAdShow()
        },
        onAdClick() {
          BYLog.debug(TAG + "自渲染信息流回调 - onAdClick")
          that.bridge?.bridge_didAdClick()
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