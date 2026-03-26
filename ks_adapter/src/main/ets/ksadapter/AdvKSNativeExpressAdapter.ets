import {
  BYLog,
  AdvanceAdnStatusResult,
  ADV_ERR_DATA_NULL,
  AdvanceAdLoadState,
  AdvanceNativeExpressCommonAdapter,
  BYDisplay,
} from 'advancesdk';
import { KSAdScene, KSAdSDK, KSBuildFeedAdView, KSFeedAd} from 'ksadsdk';
import { AdvKSUtil } from './AdvKSUtil';
import { NodeController } from '@kit.ArkUI';
import { AdvKSNodeController } from './Component/AdvKSNodeController';


const TAG = `[AdvKSNativeExpressAdapter]`

export class AdvKSNativeExpressAdapter extends AdvanceNativeExpressCommonAdapter {
  protected ks_ad?: KSFeedAd

  adapter_loadAd(): Promise<AdvanceAdnStatusResult> {
    BYLog.debug(TAG + ` adapter_loadAd start`)
    return new Promise<AdvanceAdnStatusResult>(async (resolve) => {
      let result = new AdvanceAdnStatusResult()
      let initResult = await AdvKSUtil.loadKSSDK(this)
      BYLog.debug(TAG + `ks初始化执行结果：${JSON.stringify(initResult)}`)

      if (initResult.success) { // 初始化成功
        //执行广告加载流程
        let sup = this.unitData.supplier
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
        if (sup) {
          const scene: KSAdScene = new KSAdScene()
            .setPosId(sup.adspotid)
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
              result.status = AdvanceAdLoadState.failed
              result.errCode = code
              result.errMsg = msg
              resolve(result)
            },
            onAdLoad(ads: KSFeedAd[]) {
              // 广告成功加载，可以展示
              if (ads && ads.length > 0) {
                BYLog.debug(TAG + "模板信息流回调 - onAdLoaded")
                that.ks_ad = ads[0]
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
      BYLog.debug(TAG + "模板信息流回调 - onAdRenderSuccess")
      that.bridge?.bridge_didAdRenderSuccess()

      that.ks_ad.setInteractListener({
        onAdShow() {
          BYLog.debug(TAG + "模板信息流回调 - onAdExposure")
          that.bridge?.bridge_didAdShow()
        },
        onAdClick() {
          BYLog.debug(TAG + "模板信息流回调 - onAdClick")
          that.bridge?.bridge_didAdClick()
        },
        onDislikeClicked() {
          BYLog.debug(TAG + `模板信息流回调 - onAdClose`)
          that.bridge?.bridge_didAdClose()
        }
      })
    }
  }

  adapter_getAdComponent(): NodeController | undefined {
    const that = this
    return new AdvKSNodeController(wrapBuilder(KSBuildFeedAdView), that.ks_ad)
  }

}