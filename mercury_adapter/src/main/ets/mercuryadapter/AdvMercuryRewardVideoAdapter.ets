import { window } from '@kit.ArkUI';
import {
  BYLog,
  AdvanceError,
  AdvanceCommonRewardVideoAdapter, AdvBidWinLossResult,
} from 'advancesdk';
import { MercuryCloseType, MercuryEntry, MercuryErr,
  MercuryReward,
  MercuryRenderOption, MercuryRewardRenderListener } from 'mercury_ad';


const TAG = `[AdvMercuryRewardVideoAdapter]`

export class AdvMercuryRewardVideoAdapter extends AdvanceCommonRewardVideoAdapter {
  protected mercury_ad?: MercuryReward

  adapter_isAdValid(): boolean {
    return true
  }

  adapter_loadAd() {
    //执行广告加载流程
    let spotId = this.unitData.placementId
    let opt = new MercuryEntry().setCodeId(spotId)
    this.mercury_ad = new MercuryReward(opt)
    this.mercury_ad.loadAd({
      onAdLoaded: () => {
        BYLog.debug(TAG + "激励视频回调 - onAdLoaded")
        this.bridge?.rewardVideo_didAdLoaded(this, this.mercury_ad?.getPrice() ?? 0)
      },
      onAdError: (err: MercuryErr): void => {
        BYLog.debug(TAG + `激励视频回调 - onAdLoadFailed code: ${err.code} message: ${err.msg}`)
        this.bridge?.rewardVideo_didAdLoadFailed(this, new AdvanceError(err.code, err.msg))
      },
      onMaterialCached: (isFromCache: boolean) => {},
    })
  }

  adapter_showAd(windowStage: window.WindowStage) {
    this.mercury_ad?.setRenderListener(this.interactionListener)
    let renOp = new MercuryRenderOption()
    renOp.windowStage = windowStage
    renOp.layoutFullScreen = false
    this.mercury_ad?.showAd(renOp)
  }

  adapter_sendNotification(result: AdvBidWinLossResult): void {

  }

  protected interactionListener: MercuryRewardRenderListener = {
    onShow: (): void => {
      BYLog.debug(TAG + "激励视频回调 - onAdExposure")
      this.bridge?.rewardVideo_didAdShow(this)
    },
    onClick: (): void => {
      BYLog.debug(TAG + "激励视频回调 - onAdClick")
      this.bridge?.rewardVideo_didAdClick(this)
    },
    onRenderErr: (err: MercuryErr): void => {
      BYLog.debug(TAG + "激励视频回调 - onShowError")
      this.bridge?.rewardVideo_didAdShowFailed(this, new AdvanceError(err.code, err.msg))
    },
    onClose: (type: MercuryCloseType): void => {
      BYLog.debug(TAG + `激励视频回调 - onAdClose`)
      this.bridge?.rewardVideo_didAdClose(this)
    },
    onReward: () => {
      BYLog.debug(TAG + `激励视频回调 - onAdReward`)
      this.bridge?.rewardVideo_didAdReward(this)
    },
    onComplete: () => {
      BYLog.debug(TAG + "激励视频回调 - onVideoComplete")
      this.bridge?.rewardVideo_didAdVideoPlayEnd(this)
    }
  }

}