import { window } from '@kit.ArkUI';
import {
  BYLog,
  AdvanceError,
  BYApp,
  AdvanceRewardVideoCommonAdapter,
} from 'advancesdk';
import { MercuryCloseType, MercuryEntry, MercuryErr,
  MercuryReward,
  MercuryRenderOption } from 'mercuryadhar';
import { AdvMercuryUtil } from './AdvMercuryUtil';


const TAG = `[AdvMercuryRewardVideoAdapter]`

export class AdvMercuryRewardVideoAdapter extends AdvanceRewardVideoCommonAdapter {
  protected mercury_ad?: MercuryReward

  adapter_isAdValid(): boolean {
    return true
  }

  async adapter_loadAd() {
    let initResult = await AdvMercuryUtil.loadMercurySDK(this)
    BYLog.debug(TAG + `mercury初始化执行结果：${JSON.stringify(initResult)}`)

    if (initResult.success) { // 初始化成功
      //执行广告加载流程
      let spotId = this.unitData.supplier.adspotid
      let opt = new MercuryEntry().setCodeId(spotId)
      this.mercury_ad = new MercuryReward(opt)
      this.mercury_ad.loadAd({
        onAdLoaded: () => {
          BYLog.debug(TAG + "激励视频回调 - onAdLoaded")
          this.bridge?.bridge_didAdLoaded(this.unitData.supplier, this.mercury_ad?.getPrice())
        },
        onAdError: (err: MercuryErr): void => {
          BYLog.debug(TAG + `激励视频回调 - onAdLoadFailed code: ${err.code} message: ${err.msg}`)
          this.bridge?.bridge_didAdLoadFailed(this.unitData.supplier, new AdvanceError(err.code, err.msg))
        },
        onMaterialCached: (isFromCache: boolean) => {},
      })

    } else { // 初始化失败
      this.bridge?.bridge_didAdLoadFailed(this.unitData.supplier, new AdvanceError(initResult.code, initResult.msg))
    }
  }

  adapter_showAd(windowStage: window.WindowStage) {
    this.mercury_ad?.setRenderListener({
      onShow: (): void => {
        BYLog.debug(TAG + "激励视频回调 - onAdExposure")
        this.bridge?.bridge_didAdShow(this.unitData.supplier)
      },
      onClick: (): void => {
        BYLog.debug(TAG + "激励视频回调 - onAdClick")
        this.bridge?.bridge_didAdClick(this.unitData.supplier)
      },
      onRenderErr: (err: MercuryErr): void => {
        BYLog.debug(TAG + "激励视频回调 - onShowError")
        this.bridge?.bridge_didAdShowFailed(this.unitData.supplier, new AdvanceError(err.code, err.msg))
      },
      onClose: (type: MercuryCloseType): void => {
        BYLog.debug(TAG + `激励视频回调 - onAdClose`)
        this.bridge?.bridge_didAdClose()
      },
      onReward: () => {
        BYLog.debug(TAG + `激励视频回调 - onAdReward`)
        this.bridge?.bridge_didAdReward()
      }
    })
    let renOp = new MercuryRenderOption()
    renOp.windowStage = BYApp.getWindowStage()
    renOp.layoutFullScreen = false
    this.mercury_ad?.showAd(renOp)
  }

}