import { GDTAdLoadConfig, GDTAdSDK,
  GDTBiddingConstants,
  GDTError, GDTInteractionListener,
  GDTInterstitialAd} from '@gdt/gdt-union-sdk';
import { window } from '@kit.ArkUI';
import {
  BYLog,
  AdvanceError,
  AdvanceCommonInterstitialAdapter,
  AdvBidWinLossResult,
  AdvBidWinLossResultType,
} from 'advancesdk';


const TAG = `[AdvGDTInterstitialAdapter]`

export class AdvGDTInterstitialAdapter extends AdvanceCommonInterstitialAdapter {
  protected gdt_ad?: GDTInterstitialAd

  adapter_isAdValid(): boolean {
    return this.gdt_ad?.isValid() ?? false
  }

  adapter_loadAd() {
    //执行广告加载流程
    let spotId = this.unitData.placementId
    const config: GDTAdLoadConfig = {
      posId: spotId
    };
    GDTAdSDK.getAdLoader().loadInterstitialAd(config, {
      onAdLoad: (ad: GDTInterstitialAd): void => {
        BYLog.debug(TAG + "插屏回调 - onAdLoaded")
        this.gdt_ad = ad
        this.bridge?.interstitial_didAdLoaded(this, ad.getEcpm())
      },
      onError: (err: GDTError): void => {
        BYLog.debug(TAG + `插屏回调 - onAdLoadFailed code: ${err.code} message: ${err.message}`)
        this.bridge?.interstitial_didAdLoadFailed(this, new AdvanceError(err.code, err.message))
      }
    })
  }

  adapter_showAd(windowStage: window.WindowStage) {
    this.gdt_ad?.setInteractionListener(this.interactionListener)
    this.gdt_ad?.show(windowStage)
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

  protected interactionListener: GDTInteractionListener = {
    onAdExposure: (): void => {
      BYLog.debug(TAG + "插屏回调 - onAdExposure")
      this.bridge?.interstitial_didAdShow(this)
    },
    onAdClick: (): void => {
      BYLog.debug(TAG + "插屏回调 - onAdClick")
      this.bridge?.interstitial_didAdClick(this)
    },
    onAdClose: (): void => {
      BYLog.debug(TAG + `插屏回调 - onAdClose`)
      this.bridge?.interstitial_didAdClose(this)
    },
    onError: (err: GDTError): void => {
      BYLog.debug(TAG + "插屏回调 - onShowError")
      this.bridge?.interstitial_didAdShowFailed(this, new AdvanceError(err.code, err.message))
    }
  }

}