import { GDTAdLoadConfig, GDTAdSDK, GDTError, GDTInteractionListener,
  GDTNativeAd,
  GDTAdSize,
  GDTRenderListener,
  GDTVideoStateListener,
  GDTBiddingConstants} from '@gdt/gdt-union-sdk';
import { NodeController } from '@kit.ArkUI';
import {
  BYLog,
  AdvanceError,
  ADV_ERR_DATA_NULL,
  ADV_ERR_AD_Invalid_Expired,
  BYConstant,
  BYDisplay,
  AdvanceCommonNativeExpressAdapter,
  AdvBidWinLossResultType,
  AdvBidWinLossResult,
} from 'advancesdk';


const TAG = `[AdvGDTNativeExpressAdapter]`

export class AdvGDTNativeExpressAdapter extends AdvanceCommonNativeExpressAdapter {
  protected gdt_ad?: GDTNativeAd

  adapter_loadAd() {
    //执行广告加载流程
    let spotId = this.unitData.placementId
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
          this.bridge?.nativeExpress_didAdLoaded(this, this.gdt_ad.getEcpm())
        } else {
          this.bridge?.nativeExpress_didAdLoadFailed(this, new AdvanceError(ADV_ERR_DATA_NULL, '广告返回内容为空'))
        };
      },
      onError: (err: GDTError): void => {
        BYLog.debug(TAG + `模板信息流回调 - onAdLoadFailed code: ${err.code} message: ${err.message}`)
        this.bridge?.nativeExpress_didAdLoadFailed(this, new AdvanceError(err.code, err.message))
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
      this.bridge?.nativeExpress_didAdRenderFail(this, new AdvanceError(ADV_ERR_AD_Invalid_Expired, '广告展示前广告已失效过期'))
    }
  }

  adapter_getAdComponent(): NodeController | undefined {
    return this.gdt_ad?.getAdComponent()
  }

  adapter_sendNotification(result: AdvBidWinLossResult): void {
    if (result.bidResultType === AdvBidWinLossResultType.win) {
      this.gdt_ad?.sendWinNotification(new Map([
        [GDTBiddingConstants.EXPECT_COST_PRICE, result.winPrice.toString()],
        [GDTBiddingConstants.HIGHEST_LOSS_PRICE, result.secondPrice.toString()]
      ]))
    } else {
      this.gdt_ad?.sendLossNotification(new Map([
        [GDTBiddingConstants.WIN_PRICE, result.winPrice.toString()]
      ]))
    }
  }

  protected renderListener: GDTRenderListener = {
    onRenderSuccess: (): void => {
      BYLog.debug(TAG + "模板信息流回调 - onAdRenderSuccess")
      this.bridge?.nativeExpress_didAdRenderSuccess(this)
    },
    onRenderFail: (err: GDTError): void => {
      BYLog.debug(TAG + "模板信息流回调 - onAdRenderFail")
      this.bridge?.nativeExpress_didAdRenderFail(this, new AdvanceError(err.code, err.message))
    }
  };

  protected interactionListener: GDTInteractionListener = {
    onAdExposure: (): void => {
      BYLog.debug(TAG + "模板信息流回调 - onAdExposure")
      this.bridge?.nativeExpress_didAdShow(this)
    },
    onAdClick: (): void => {
      BYLog.debug(TAG + "模板信息流回调 - onAdClick")
      this.bridge?.nativeExpress_didAdClick(this)
    },
    onAdClose: (): void => {
      BYLog.debug(TAG + `模板信息流回调 - onAdClose`)
      this.bridge?.nativeExpress_didAdClose(this)
    },
    onError: (err: GDTError): void => {
      BYLog.debug(TAG + "模板信息流回调 - onShowError")
      this.bridge?.nativeExpress_didAdRenderFail(this, new AdvanceError(err.code, err.message))
    }
  }

  protected videoStateListener: GDTVideoStateListener = {
    onVideoStart: (): void => {
      BYLog.debug(TAG + "模板信息流回调 - onVideoStart")
      this.bridge?.nativeExpress_didAdVideoPlayStart(this)
    },
    onVideoComplete: (): void => {
      BYLog.debug(TAG + "模板信息流回调 - onVideoEnd")
      this.bridge?.nativeExpress_didAdVideoPlayEnd(this)
    },
    onVideoError: (err: GDTError): void => {
      BYLog.debug(TAG + `模板信息流回调 - onVideoFailed`)
      this.bridge?.nativeExpress_didAdVideoPlayFailed(this, new AdvanceError(err.code, err.message))
    }
  }

}