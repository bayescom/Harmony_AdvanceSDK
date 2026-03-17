import { window } from '@kit.ArkUI';
import {
  BYLog,
  AdvanceAdnStatusResult,
  ADV_ERR_DATA_NULL,
  AdvanceAdLoadState,
  BYWindowUtil,
  AdvanceRewardVideoCommonAdapter,
} from 'AdvanceSDK';
import { KSAdScene, KSAdSDK, KSAdScreenDirection, KSRewardAd} from 'ksadsdk';
import { KS_DISPLAY_PAGE_TAG, STORAGE_AD_KEY } from './AdvKSDisplayPageView';
import { AdvKSUtil } from './AdvKSUtil';


const TAG = `[AdvKSRewardVideoAdapter]`

export class AdvKSRewardVideoAdapter extends AdvanceRewardVideoCommonAdapter {
  protected ks_ad?: KSRewardAd

  adapter_isAdValid(): boolean {
    return true
  }

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
            .setScreenOrientation(KSAdScreenDirection.vertical);
          const that = this // 参照快手demo内写法；因为callback内获取的this不是当前adpater对象，而是listener对象
          KSAdSDK.getLoadManager().loadRewardAd(scene, {
            onRequestSuccess(ad: KSRewardAd) {
              // 广告请求成功
            },
            onError(code: number, msg: string) {
              // 广告请求失败
              BYLog.debug(TAG + `激励视频回调 - onAdLoadFailed code: ${code} message: ${msg}`)
              result.status = AdvanceAdLoadState.failed
              result.errCode = code
              result.errMsg = msg
              resolve(result)
            },
            onAdLoad(ad: KSRewardAd) {
              // 广告成功加载，可以展示
              BYLog.debug(TAG + "激励视频回调 - onAdLoaded")
              that.ks_ad = ad
              result.status = AdvanceAdLoadState.success
              resolve(result)
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

  adapter_showAd(windowStage: window.WindowStage) {
    const that = this
    if (that.ks_ad) {
      that.ks_ad?.setInteractListener({
        onAdShow() {
          BYLog.debug(TAG + "激励视频回调 - onAdExposure")
          that.bridge?.bridge_didAdShow()
        },
        onAdClick() {
          BYLog.debug(TAG + "激励视频回调 - onAdClick")
          that.bridge?.bridge_didAdClick()
        },
        onAdClose() {
          BYLog.debug(TAG + `激励视频回调 - onAdClose`)
          that.bridge?.bridge_didAdClose()
        },
        onRewardVerify() {
          BYLog.debug(TAG + `激励视频回调 - onAdReward`)
          that.bridge?.bridge_didAdReward()
        },
        onVideoPlayEnd() {
          BYLog.debug(TAG + `激励视频回调 - onAdPlayEnd`)
          that.bridge?.bridge_didAdPlayEnd()
        }
      })
      that.ks_ad?.show({videoSoundEnable: false })
    }
  }

}