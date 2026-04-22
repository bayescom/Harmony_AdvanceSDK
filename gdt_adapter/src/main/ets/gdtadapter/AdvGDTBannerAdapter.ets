import { GDTAdLoadConfig, GDTAdSDK, GDTError, GDTInteractionListener,
  GDTBannerAd,
  GDTAdSize,
  GDTRenderListener} from '@gdt/gdt-union-sdk';
import { NodeController } from '@kit.ArkUI';
import {
  BYLog,
  AdvanceError,
  ADV_ERR_AD_Invalid_Expired,
  AdvanceBannerCommonAdapter,
  BYConstant,
} from 'advancesdk';


const TAG = `[AdvGDTBannerAdapter]`

export class AdvGDTBannerAdapter extends AdvanceBannerCommonAdapter {
  protected gdt_ad?: GDTBannerAd

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
    let width = this.unitData.vpWidth ?? 0
    let height = this.unitData.vpHeight ?? 0
    const config: GDTAdLoadConfig = {
      posId: spotId,
      adSize: new GDTAdSize(width, height)
    };
    GDTAdSDK.getAdLoader().loadBannerAd(config, {
      onAdLoad: (ad: GDTBannerAd): void => {
        BYLog.debug(TAG + "横幅回调 - onAdLoaded")
        ad.setRefresh(0);
        this.gdt_ad = ad
        this.bridge?.bridge_didAdLoaded(this.unitData.supplier, ad.getEcpm())
      },
      onError: (err: GDTError): void => {
        BYLog.debug(TAG + `横幅回调 - onAdLoadFailed code: ${err.code} message: ${err.message}`)
        this.bridge?.bridge_didAdLoadFailed(this.unitData.supplier, new AdvanceError(err.code, err.message))
      }
    })
  }

  adapter_render(context: UIContext): void {
    this.gdt_ad?.setInteractionListener(this.interactionListener);
    this.gdt_ad?.setRenderListener(this.renderListener);
    this.gdt_ad?.render(BYConstant.windowStage, context);
  }

  adapter_getAdComponent(): NodeController | undefined {
    return this.gdt_ad?.getAdComponent()
  }

  protected renderListener: GDTRenderListener = {
    onRenderSuccess: (): void => {
      BYLog.debug(TAG + "横幅回调 - onAdRenderSuccess")
    },
    onRenderFail: (err: GDTError): void => {
      BYLog.debug(TAG + "横幅回调 - onAdRenderFail")
      this.bridge?.bridge_didAdShowFailed(this.unitData.supplier, new AdvanceError(err.code, err.message))
    }
  };

  protected interactionListener: GDTInteractionListener = {
    onAdExposure: (): void => {
      BYLog.debug(TAG + "横幅回调 - onAdExposure")
      this.bridge?.bridge_didAdShow(this.unitData.supplier)
    },
    onAdClick: (): void => {
      BYLog.debug(TAG + "横幅回调 - onAdClick")
      this.bridge?.bridge_didAdClick(this.unitData.supplier)
    },
    onAdClose: (): void => {
      BYLog.debug(TAG + `横幅回调 - onAdClose`)
      this.bridge?.bridge_didAdClose()
    },
    onError: (err: GDTError): void => {
      BYLog.debug(TAG + "横幅回调 - onShowError")
      this.bridge?.bridge_didAdShowFailed(this.unitData.supplier, new AdvanceError(err.code, err.message))
    }
  }

}