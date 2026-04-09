import { NodeController } from '@kit.ArkUI';
import {
  BYLog,
  AdvanceError,
  AdvanceNativeExpressCommonAdapter,
  BYDisplay,
} from 'advancesdk';
import { MercuryCloseType, MercuryEntry, MercuryErr, MercuryFeed } from 'mercuryadhar';
import { AdvMercuryUtil } from './AdvMercuryUtil';


const TAG = `[AdvMercuryNativeExpressAdapter]`

export class AdvMercuryNativeExpressAdapter extends AdvanceNativeExpressCommonAdapter {
  protected mercury_ad?: MercuryFeed

  async adapter_loadAd() {
    let initResult = await AdvMercuryUtil.loadMercurySDK(this)
    BYLog.debug(TAG + `mercury初始化执行结果：${JSON.stringify(initResult)}`)

    if (initResult.success) { // 初始化成功
      //执行广告加载流程
      let spotId = this.unitData.supplier.adspotid
      let width = this.unitData.ext?.vpWidth ?? 0
      let height = this.unitData.ext?.vpHeight ?? 0
      //未配置的话取屏幕宽
      if (width <= 0) {
        width = BYDisplay.px2VP(BYDisplay.getScreenWPX())
      }
      //高度0代表自适应
      if (height <= 0) {
        height = 0
      }
      let opt = new MercuryEntry()
        .setCodeId(spotId)
        .setAdSize(width, height)
      this.mercury_ad = new MercuryFeed(opt)
      this.mercury_ad.loadAd({
        onAdLoaded: () => {
          BYLog.debug(TAG + "模板信息流回调 - onAdLoaded")
          this.bridge?.bridge_didAdLoaded(this.unitData.supplier, this.mercury_ad?.getPrice())
        },
        onAdError: (err: MercuryErr): void => {
          BYLog.debug(TAG + `模板信息流回调 - onAdLoadFailed code: ${err.code} message: ${err.msg}`)
          this.bridge?.bridge_didAdLoadFailed(this.unitData.supplier, new AdvanceError(err.code, err.msg))
        },
        onMaterialCached: (isFromCache: boolean) => {},
      })

    } else { // 初始化失败
      this.bridge?.bridge_didAdLoadFailed(this.unitData.supplier, new AdvanceError(initResult.code, initResult.msg))
    }
  }

  adapter_render(context: UIContext): void {
    //Mercury广告没有渲染成功回调，load成功即认为渲染成功
    BYLog.debug(TAG + "模板信息流回调 - onAdRenderSuccess")
    this.bridge?.bridge_didAdRenderSuccess(this.unitData.supplier)

    this.mercury_ad?.setRenderListener({
      onShow: (): void => {
        BYLog.debug(TAG + "模板信息流回调 - onAdExposure")
        this.bridge?.bridge_didAdShow(this.unitData.supplier)
      },
      onClick: (): void => {
        BYLog.debug(TAG + "模板信息流回调 - onAdClick")
        this.bridge?.bridge_didAdClick(this.unitData.supplier)
      },
      onRenderErr: (err: MercuryErr): void => {
        BYLog.debug(TAG + "模板信息流回调 - onShowError")
        this.bridge?.bridge_didAdRenderFail(this.unitData.supplier, new AdvanceError(err.code, err.msg))
      },
      onClose: (type: MercuryCloseType): void => {
        BYLog.debug(TAG + `模板信息流回调 - onAdClose`)
        this.bridge?.bridge_didAdClose()
      }
    })
  }

  adapter_getAdComponent(): NodeController | undefined {
    return this.mercury_ad?.getAdComponent()
  }

}