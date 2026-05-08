import { GDTAdLoadConfig, GDTAdSDK, GDTError, GDTInteractionListener,
  GDTNativeAd,
  GDTAdSize,
  GDTRenderListener,
  GDTVideoStateListener} from '@gdt/gdt-union-sdk';
import { NodeController } from '@kit.ArkUI';
import {
  BYLog,
  AdvanceError,
  ADV_ERR_DATA_NULL,
  ADV_ERR_AD_Invalid_Expired,
  AdvanceNativeExpressCommonAdapter,
  BYConstant,
  BYDisplay,
} from 'advancesdk';


const TAG = `[AdvGDTNativeExpressAdapter]`

export class AdvGDTNativeExpressAdapter extends AdvanceNativeExpressCommonAdapter {
  protected gdt_ad?: GDTNativeAd

  adapter_loadAd() {
    //执行广告加载流程
    let spotId = this.unitData.supplier.adspotid
    let width = this.unitData.vpWidth ?? 0
    let height = this.unitData.vpHeight ?? 0
    //未配置的话取屏幕宽
    if (width <= 0) {
      width = BYDisplay.px2VP(BYDisplay.getScreenWPX())
    }
    //高度GDTAdSize.AUTO_HEIGHT代表自适应
    if (height <= 0) {
      height = GDTAdSize.AUTO_HEIGHT
    }
    const config: GDTAdLoadConfig = {
      posId: spotId,
      count: 1,
      adSize: new GDTAdSize(width, height)
    };
    GDTAdSDK.getAdLoader().loadNativeAd(config, {
      onAdLoad: (ads: Array<GDTNativeAd>): void => {
        if (ads && ads.length > 0) {
          BYLog.debug(TAG + "模板信息流回调 - onAdLoaded")
          this.gdt_ad = ads[0]
          this.bridge?.bridge_cacheAdapterIfNeeded(this, this.unitData.supplier, this.gdt_ad.getEcpm())
          this.bridge?.bridge_didAdLoaded(this.unitData.supplier, this.gdt_ad.getEcpm())
        } else {
          this.bridge?.bridge_didAdLoadFailed(this.unitData.supplier, new AdvanceError(ADV_ERR_DATA_NULL, '广告返回内容为空'))
        };
      },
      onError: (err: GDTError): void => {
        BYLog.debug(TAG + `模板信息流回调 - onAdLoadFailed code: ${err.code} message: ${err.message}`)
        this.bridge?.bridge_didAdLoadFailed(this.unitData.supplier, new AdvanceError(err.code, err.message))
      }
    })
  }

  adapter_render(context: UIContext): void {
    this.gdt_ad?.setInteractionListener(this.interactionListener);
    this.gdt_ad?.setRenderListener(this.renderListener);
    this.gdt_ad?.setVideoStateListener(this.videoStateListener)
    if (this.gdt_ad?.isValid()) {
      this.gdt_ad?.render(BYConstant.windowStage, context);
    } else {
      this.bridge?.bridge_didAdRenderFail(this.unitData.supplier, new AdvanceError(ADV_ERR_AD_Invalid_Expired, '广告展示前广告已失效过期'))
    }
  }

  adapter_getAdComponent(): NodeController | undefined {
    return this.gdt_ad?.getAdComponent()
  }

  protected renderListener: GDTRenderListener = {
    onRenderSuccess: (): void => {
      BYLog.debug(TAG + "模板信息流回调 - onAdRenderSuccess")
      this.bridge?.bridge_didAdRenderSuccess(this.unitData.supplier)
    },
    onRenderFail: (err: GDTError): void => {
      BYLog.debug(TAG + "模板信息流回调 - onAdRenderFail")
      this.bridge?.bridge_didAdRenderFail(this.unitData.supplier, new AdvanceError(err.code, err.message))
    }
  };

  protected interactionListener: GDTInteractionListener = {
    onAdExposure: (): void => {
      BYLog.debug(TAG + "模板信息流回调 - onAdExposure")
      this.bridge?.bridge_didAdShow(this.unitData.supplier)
    },
    onAdClick: (): void => {
      BYLog.debug(TAG + "模板信息流回调 - onAdClick")
      this.bridge?.bridge_didAdClick(this.unitData.supplier)
    },
    onAdClose: (): void => {
      BYLog.debug(TAG + `模板信息流回调 - onAdClose`)
      this.bridge?.bridge_didAdClose()
    },
    onError: (err: GDTError): void => {
      BYLog.debug(TAG + "模板信息流回调 - onShowError")
      this.bridge?.bridge_didAdRenderFail(this.unitData.supplier, new AdvanceError(err.code, err.message))
    }
  }

  protected videoStateListener: GDTVideoStateListener = {
    onVideoStart: (): void => {
      BYLog.debug(TAG + "模板信息流回调 - onVideoStart")
      this.bridge?.bridge_didAdVideoPlayStart()
    },
    onVideoComplete: (): void => {
      BYLog.debug(TAG + "模板信息流回调 - onVideoEnd")
      this.bridge?.bridge_didAdVideoPlayEnd()
    },
    onVideoError: (err: GDTError): void => {
      BYLog.debug(TAG + `模板信息流回调 - onVideoFailed`)
      this.bridge?.bridge_didAdVideoPlayFailed(new AdvanceError(err.code, err.message))
    }
  }

}