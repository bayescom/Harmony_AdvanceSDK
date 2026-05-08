import { GDTAdLoadConfig, GDTAdSDK, GDTError, GDTInteractionListener,
  GDTInterstitialAd} from '@gdt/gdt-union-sdk';
import { window } from '@kit.ArkUI';
import {
  BYLog,
  AdvanceError,
  ADV_ERR_AD_Invalid_Expired,
  AdvanceInterstitialCommonAdapter,
} from 'advancesdk';


const TAG = `[AdvGDTInterstitialAdapter]`

export class AdvGDTInterstitialAdapter extends AdvanceInterstitialCommonAdapter {
  protected gdt_ad?: GDTInterstitialAd

  adapter_isAdValid(): boolean {
    const isAdValid = this.gdt_ad?.isValid() ?? false
    if (!isAdValid) {
      this.bridge?.bridge_didAdShowFailed(this.unitData.supplier, new AdvanceError(ADV_ERR_AD_Invalid_Expired, '广告展示前广告已失效过期'))
    }
    return isAdValid
  }

  adapter_loadAd() {
    //执行广告加载流程
    let spotId = this.unitData.supplier.adspotid
    const config: GDTAdLoadConfig = {
      posId: spotId
    };
    GDTAdSDK.getAdLoader().loadInterstitialAd(config, {
      onAdLoad: (ad: GDTInterstitialAd): void => {
        BYLog.debug(TAG + "插屏回调 - onAdLoaded")
        this.gdt_ad = ad
        this.bridge?.bridge_cacheAdapterIfNeeded(this, this.unitData.supplier, ad.getEcpm())
        this.bridge?.bridge_didAdLoaded(this.unitData.supplier, ad.getEcpm())
      },
      onError: (err: GDTError): void => {
        BYLog.debug(TAG + `插屏回调 - onAdLoadFailed code: ${err.code} message: ${err.message}`)
        this.bridge?.bridge_didAdLoadFailed(this.unitData.supplier, new AdvanceError(err.code, err.message))
      }
    })
  }

  adapter_showAd(windowStage: window.WindowStage) {
    this.gdt_ad?.setInteractionListener(this.interactionListener)
    this.gdt_ad?.show(windowStage)
  }

  protected interactionListener: GDTInteractionListener = {
    onAdExposure: (): void => {
      BYLog.debug(TAG + "插屏回调 - onAdExposure")
      this.bridge?.bridge_didAdShow(this.unitData.supplier)
    },
    onAdClick: (): void => {
      BYLog.debug(TAG + "插屏回调 - onAdClick")
      this.bridge?.bridge_didAdClick(this.unitData.supplier)
    },
    onAdClose: (): void => {
      BYLog.debug(TAG + `插屏回调 - onAdClose`)
      this.bridge?.bridge_didAdClose()
    },
    onError: (err: GDTError): void => {
      BYLog.debug(TAG + "插屏回调 - onShowError")
      this.bridge?.bridge_didAdShowFailed(this.unitData.supplier, new AdvanceError(err.code, err.message))
    }
  }

}