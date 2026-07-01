import { GDTAdLoadConfig, GDTAdSDK,
  GDTBiddingConstants,
  GDTError, GDTInteractionListener,
  GDTRewardAd,
  GDTVideoStateListener} from '@gdt/gdt-union-sdk';
import { window } from '@kit.ArkUI';
import {
  BYLog,
  AdvanceError,
  AdvanceCommonRewardVideoAdapter,
  AdvBidWinLossResult,
  AdvBidWinLossResultType,
} from 'advancesdk';


const TAG = `[AdvGDTRewardVideoAdapter]`

export class AdvGDTRewardVideoAdapter extends AdvanceCommonRewardVideoAdapter {
  protected gdt_ad?: GDTRewardAd

  adapter_isAdValid(): boolean {
    return this.gdt_ad?.isValid() ?? false
  }

  adapter_loadAd() {
    //执行广告加载流程
    let spotId = this.unitData.placementId
    const config: GDTAdLoadConfig = {
      posId: spotId
    };
    GDTAdSDK.getAdLoader().loadRewardAd(config, {
      onAdLoad: (ad: GDTRewardAd): void => {
        BYLog.debug(TAG + "激励视频回调 - onAdLoaded")
        this.gdt_ad = ad
        this.bridge?.rewardVideo_didAdLoaded(this, ad.getEcpm())
      },
      onError: (err: GDTError): void => {
        BYLog.debug(TAG + `激励视频回调 - onAdLoadFailed code: ${err.code} message: ${err.message}`)
        this.bridge?.rewardVideo_didAdLoadFailed(this, new AdvanceError(err.code, err.message))
      }
    })
  }

  adapter_showAd(windowStage: window.WindowStage) {
    this.gdt_ad?.setInteractionListener(this.interactionListener)
    this.gdt_ad?.setVideoStateListener(this.videoStateListener)
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
      BYLog.debug(TAG + "激励视频回调 - onAdExposure")
      this.bridge?.rewardVideo_didAdShow(this)
    },
    onAdClick: (): void => {
      BYLog.debug(TAG + "激励视频回调 - onAdClick")
      this.bridge?.rewardVideo_didAdClick(this)
    },
    onAdClose: (): void => {
      BYLog.debug(TAG + `激励视频回调 - onAdClose`)
      this.bridge?.rewardVideo_didAdClose(this)
    },
    onError: (err: GDTError): void => {
      BYLog.debug(TAG + "激励视频回调 - onShowError")
      this.bridge?.rewardVideo_didAdShowFailed(this, new AdvanceError(err.code, err.message))
    },
    onReward: (map: Map<string, string>): void => {
      BYLog.debug(TAG + "激励视频回调 - onReward")
      this.bridge?.rewardVideo_didAdReward(this)
    },
  }

  videoStateListener: GDTVideoStateListener = {
    onVideoComplete: (): void => {
      BYLog.debug(TAG + "激励视频回调 - onVideoComplete")
      this.bridge?.rewardVideo_didAdVideoPlayEnd(this)
    }
  }

}