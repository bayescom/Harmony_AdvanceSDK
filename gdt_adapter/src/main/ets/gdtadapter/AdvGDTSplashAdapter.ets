import { GDTAdLoadConfig, GDTAdSDK,
  GDTBiddingConstants,
  GDTError, GDTInteractionListener, GDTSplashAd } from '@gdt/gdt-union-sdk';
import { window } from '@kit.ArkUI';
import {
  BYLog,
  AdvanceError,
  AdvanceCommonSplashAdapter,
  AdvBidWinLossResult,
  AdvBidWinLossResultType,
} from 'advancesdk';


const TAG = `[AdvGDTSplashAdapter]`

export class AdvGDTSplashAdapter extends AdvanceCommonSplashAdapter {
  protected gdt_ad?: GDTSplashAd

  adapter_isAdValid(): boolean {
    return this.gdt_ad?.isValid() ?? false
  }

  adapter_loadAd() {
    //执行广告加载流程
    let spotId = this.unitData.placementId
    const config: GDTAdLoadConfig = {
      posId: spotId,
      timeoutMillis: this.unitData.timeout
    };
    GDTAdSDK.getAdLoader().loadSplashAd(config, {
      onAdLoad: (ad: GDTSplashAd): void => {
        BYLog.debug(TAG + "开屏回调 - onAdLoaded")
        this.gdt_ad = ad
        this.bridge?.splash_didAdLoaded(this, ad.getEcpm())
      },
      onError: (err: GDTError): void => {
        BYLog.debug(TAG + `开屏回调 - onAdLoadFailed code: ${err.code} message: ${err.message}`)
        this.bridge?.splash_didAdLoadFailed(this, new AdvanceError(err.code, err.message))
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
      BYLog.debug(TAG + "开屏回调 - onAdExposure")
      this.bridge?.splash_didAdShow(this)
    },
    onAdClick: (): void => {
      BYLog.debug(TAG + "开屏回调 - onAdClick")
      this.bridge?.splash_didAdClick(this)
    },
    onAdClose: (): void => {
      BYLog.debug(TAG + `开屏回调 - onAdClose`)
      this.bridge?.splash_didAdClose(this)
    },
    onError: (err: GDTError): void => {
      BYLog.debug(TAG + "开屏回调 - onShowError")
      this.bridge?.splash_didAdShowFailed(this, new AdvanceError(err.code, err.message))
    }
  }

}