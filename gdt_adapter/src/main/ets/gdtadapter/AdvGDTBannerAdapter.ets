import { GDTAdLoadConfig, GDTAdSDK, GDTError, GDTInteractionListener,
  GDTBannerAd,
  GDTAdSize,
  GDTRenderListener,
  GDTBiddingConstants} from '@gdt/gdt-union-sdk';
import { NodeController } from '@kit.ArkUI';
import {
  BYLog,
  AdvanceError,
  BYConstant,
  AdvanceCommonBannerAdapter,
  AdvBidWinLossResult,
  AdvBidWinLossResultType,
} from 'advancesdk';


const TAG = `[AdvGDTBannerAdapter]`

export class AdvGDTBannerAdapter extends AdvanceCommonBannerAdapter {
  protected gdt_ad?: GDTBannerAd

  adapter_isAdValid(): boolean {
    return this.gdt_ad?.isValid() ?? false
  }

  adapter_loadAd() {
    //执行广告加载流程
    let spotId = this.unitData.placementId
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
        this.bridge?.banner_didAdLoaded(this, ad.getEcpm())
      },
      onError: (err: GDTError): void => {
        BYLog.debug(TAG + `横幅回调 - onAdLoadFailed code: ${err.code} message: ${err.message}`)
        this.bridge?.banner_didAdLoadFailed(this, new AdvanceError(err.code, err.message))
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
      BYLog.debug(TAG + "横幅回调 - onAdRenderSuccess")
    },
    onRenderFail: (err: GDTError): void => {
      BYLog.debug(TAG + "横幅回调 - onAdRenderFail")
      this.bridge?.banner_didAdShowFailed(this, new AdvanceError(err.code, err.message))
    }
  };

  protected interactionListener: GDTInteractionListener = {
    onAdExposure: (): void => {
      BYLog.debug(TAG + "横幅回调 - onAdExposure")
      this.bridge?.banner_didAdShow(this)
    },
    onAdClick: (): void => {
      BYLog.debug(TAG + "横幅回调 - onAdClick")
      this.bridge?.banner_didAdClick(this)
    },
    onAdClose: (): void => {
      BYLog.debug(TAG + `横幅回调 - onAdClose`)
      this.bridge?.banner_didAdClose(this)
    },
    onError: (err: GDTError): void => {
      BYLog.debug(TAG + "横幅回调 - onShowError")
      this.bridge?.banner_didAdShowFailed(this, new AdvanceError(err.code, err.message))
    }
  }

}