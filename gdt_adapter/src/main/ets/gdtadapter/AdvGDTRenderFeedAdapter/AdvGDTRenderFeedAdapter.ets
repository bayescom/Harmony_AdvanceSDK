import { GDTAdLoadConfig, GDTAdSDK, GDTError, GDTInteractionListener,
  GDTRenderListener,
  GDTVideoStateListener,
  GDTManualAd,
  GDTBiddingConstants} from '@gdt/gdt-union-sdk';
import {
  BYLog,
  AdvanceError,
  ADV_ERR_DATA_NULL,
  ADV_ERR_AD_Invalid_Expired,
  BYConstant,
  AdvanceRenderFeedAdWrapper,
  AdvanceCommonRenderFeedAdapter,
  AdvBidWinLossResult,
  AdvBidWinLossResultType,
} from 'advancesdk';
import { AdvGDTRenderFeedAdWrapper } from './AdvGDTRenderFeedAdWrapper';


const TAG = `[AdvGDTRenderFeedAdapter]`

export class AdvGDTRenderFeedAdapter extends AdvanceCommonRenderFeedAdapter {
  protected gdt_ad?: GDTManualAd
  protected wrapper?: AdvanceRenderFeedAdWrapper | undefined

  adapter_loadAd() {
    //执行广告加载流程
    let spotId = this.unitData.placementId
    const config: GDTAdLoadConfig = {
      posId: spotId,
      count: 1,
    };
    GDTAdSDK.getAdLoader().loadManualAd(config, {
      onAdLoad: (ads: Array<GDTManualAd>): void => {
        if (ads && ads.length > 0) {
          BYLog.debug(TAG + "自渲染信息流回调 - onAdLoaded")
          this.gdt_ad = ads[0]
          this.wrapper = new AdvGDTRenderFeedAdWrapper(this.gdt_ad)
          this.bridge?.renderFeed_didAdLoaded(this, this.gdt_ad.getEcpm())
        } else {
          this.bridge?.renderFeed_didAdLoadFailed(this, new AdvanceError(ADV_ERR_DATA_NULL, '广告返回内容为空'))
        };
      },
      onError: (err: GDTError): void => {
        BYLog.debug(TAG + `自渲染信息流回调 - onAdLoadFailed code: ${err.code} message: ${err.message}`)
        this.bridge?.renderFeed_didAdLoadFailed(this, new AdvanceError(err.code, err.message))
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
      this.bridge?.renderFeed_didAdRenderFail(this, new AdvanceError(ADV_ERR_AD_Invalid_Expired, '广告展示前广告已失效过期'))
    }
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
      BYLog.debug(TAG + "自渲染信息流回调 - onAdRenderSuccess")
      this.bridge?.renderFeed_didAdRenderSuccess(this, this.wrapper!)
    },
    onRenderFail: (err: GDTError): void => {
      BYLog.debug(TAG + "自渲染信息流回调 - onAdRenderFail")
      this.bridge?.renderFeed_didAdRenderFail(this, new AdvanceError(err.code, err.message))
    }
  };

  protected interactionListener: GDTInteractionListener = {
    onAdExposure: (): void => {
      BYLog.debug(TAG + "自渲染信息流回调 - onAdExposure")
      this.bridge?.renderFeed_didAdShow(this)
    },
    onAdClick: (): void => {
      BYLog.debug(TAG + "自渲染信息流回调 - onAdClick")
      this.bridge?.renderFeed_didAdClick(this)
    },
    onAdClose: (): void => {
      BYLog.debug(TAG + `自渲染信息流回调 - onAdClose`)
      // this.bridge?.renderFeed_didAdClose()
    },
    onError: (err: GDTError): void => {
      BYLog.debug(TAG + "自渲染信息流回调 - onShowError")
      this.bridge?.renderFeed_didAdRenderFail(this, new AdvanceError(err.code, err.message))
    }
  }

  protected videoStateListener: GDTVideoStateListener = {
    onVideoStart: (): void => {
      BYLog.debug(TAG + "自渲染信息流回调 - onVideoStart")
      this.bridge?.renderFeed_didAdVideoPlayStart(this)
    },
    onVideoComplete: (): void => {
      BYLog.debug(TAG + "自渲染信息流回调 - onVideoEnd")
      this.bridge?.renderFeed_didAdVideoPlayEnd(this)
    },
    onVideoError: (err: GDTError): void => {
      BYLog.debug(TAG + `自渲染信息流回调 - onVideoFailed`)
      this.bridge?.renderFeed_didAdVideoPlayFailed(this, new AdvanceError(err.code, err.message))
    }
  }

}