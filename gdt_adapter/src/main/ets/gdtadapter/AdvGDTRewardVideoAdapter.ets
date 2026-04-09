import { GDTAdLoadConfig, GDTAdSDK, GDTError, GDTInteractionListener,
  GDTRewardAd,
  GDTVideoStateListener} from '@gdt/gdt-union-sdk';
import { window } from '@kit.ArkUI';
import {
  BYLog,
  AdvanceError,
  ADV_ERR_AD_Invalid_Expired,
  AdvanceRewardVideoCommonAdapter,
} from 'advancesdk';
import { AdvGDTUtil } from './AdvGDTUtil';


const TAG = `[AdvGDTRewardVideoAdapter]`

export class AdvGDTRewardVideoAdapter extends AdvanceRewardVideoCommonAdapter {
  protected gdt_ad?: GDTRewardAd

  adapter_isAdValid(): boolean {
    const isAdValid = this.gdt_ad?.isValid() ?? false
    if (!isAdValid) {
      this.bridge?.bridge_didAdShowFailed(this.unitData.supplier, new AdvanceError(ADV_ERR_AD_Invalid_Expired, '广告展示前广告已失效过期'))
    }
    return isAdValid
  }

  async adapter_loadAd() {
    let initResult = await AdvGDTUtil.loadGDTSDK(this)
    BYLog.debug(TAG + `gdt初始化执行结果：${JSON.stringify(initResult)}`)

    if (initResult.success) { // 初始化成功
      //执行广告加载流程
      let spotId = this.unitData.supplier.adspotid
      const config: GDTAdLoadConfig = {
        posId: spotId
      };
      GDTAdSDK.getAdLoader().loadRewardAd(config, {
        onAdLoad: (ad: GDTRewardAd): void => {
          BYLog.debug(TAG + "激励视频 - onAdLoaded")
          this.gdt_ad = ad
          this.bridge?.bridge_didAdLoaded(this.unitData.supplier, ad.getEcpm())
        },
        onError: (err: GDTError): void => {
          BYLog.debug(TAG + `激励视频 - onAdLoadFailed code: ${err.code} message: ${err.message}`)
          this.bridge?.bridge_didAdLoadFailed(this.unitData.supplier, new AdvanceError(err.code, err.message))
        }
      })

    } else { // 初始化失败
      this.bridge?.bridge_didAdLoadFailed(this.unitData.supplier, new AdvanceError(initResult.code, initResult.msg))
    }
  }

  adapter_showAd(windowStage: window.WindowStage) {
    this.gdt_ad?.setInteractionListener(this.interactionListener)
    this.gdt_ad?.setVideoStateListener(this.videoStateListener)
    this.gdt_ad?.show(windowStage)
  }

  protected interactionListener: GDTInteractionListener = {
    onAdExposure: (): void => {
      BYLog.debug(TAG + "激励视频回调 - onAdExposure")
      this.bridge?.bridge_didAdShow(this.unitData.supplier)
    },
    onAdClick: (): void => {
      BYLog.debug(TAG + "激励视频回调 - onAdClick")
      this.bridge?.bridge_didAdClick(this.unitData.supplier)
    },
    onAdClose: (): void => {
      BYLog.debug(TAG + `激励视频回调 - onAdClose`)
      this.bridge?.bridge_didAdClose()
    },
    onError: (err: GDTError): void => {
      BYLog.debug(TAG + "激励视频回调 - onShowError")
      this.bridge?.bridge_didAdShowFailed(this.unitData.supplier, new AdvanceError(err.code, err.message))
    },
    onReward: (map: Map<string, string>): void => {
      BYLog.debug(TAG + "激励视频回调 - onReward")
      this.bridge?.bridge_didAdReward()
    },
  }

  videoStateListener: GDTVideoStateListener = {
    onVideoComplete: (): void => {
      BYLog.debug(TAG + "激励视频回调 - onVideoComplete")
      this.bridge?.bridge_didAdVideoPlayEnd()
    }
  }

}