import {
  BYLog, ADV_ERR_DATA_NULL, AdvanceBannerCommonAdapter, AdvanceError,
} from 'advancesdk';
import {
  AdSlotBuilder,
  CSJAdCreator,
  CSJAdSdk,
  CSJDislikeInteractionCallback,
  CSJNativeExpressAd,
  ExpressAdInteractionListener,
} from '@csj/openadsdk';
import { AdvCSJUtil } from './AdvCSJUtil';
import { ArrayList } from '@kit.ArkTS';
import { NodeController } from '@kit.ArkUI';

const TAG = `[AdvCSJBannerAdapter]`

export class AdvCSJBannerAdapter extends AdvanceBannerCommonAdapter {
  protected csj_ad?: CSJNativeExpressAd

  adapter_isAdValid(): boolean {
    return true
  }

  async adapter_loadAd() {
    let initResult = await AdvCSJUtil.loadCSJSDK(this)
    BYLog.debug(TAG + ` csj初始化执行结果：${JSON.stringify(initResult)}`)

    if (initResult.success) { // 初始化成功
      //执行广告加载流程
      let spotId = this.unitData.supplier.adspotid
      let width = this.unitData.ext?.vpWidth ?? 0
      let height = this.unitData.ext?.vpHeight ?? 0
      let mAdCreator: CSJAdCreator = CSJAdSdk.getAdCreator()
      let adSlot = new AdSlotBuilder()
        .setCodeId(spotId)
        .setAcceptSize(width, height)
        .setAdCount(1)
        .build()
      mAdCreator.loadBannerAd(adSlot, {
        onNativeExpressAdLoad: (ads: ArrayList<CSJNativeExpressAd>) => {
          if (ads && ads.length > 0) {
            BYLog.debug(TAG + "横幅回调 - onAdLoaded")
            this.csj_ad = ads[0]
            // 穿山甲变现SDK不提供ecpm获取
            this.bridge?.bridge_didAdLoaded(this.unitData.supplier, 0)
          } else {
            this.bridge?.bridge_didAdLoadFailed(this.unitData.supplier,
              new AdvanceError(ADV_ERR_DATA_NULL, '广告返回内容为空'))
          }
          ;
        },
        onError: (code: number, message: string) => {
          BYLog.debug(TAG + `横幅回调 - onAdLoadFailed code: ${code} message: ${message}`)
          this.bridge?.bridge_didAdLoadFailed(this.unitData.supplier, new AdvanceError(code, message))
        }
      })

    } else { // 初始化失败
      this.bridge?.bridge_didAdLoadFailed(this.unitData.supplier!, new AdvanceError(initResult.code, initResult.msg))
    }

  }

  adapter_render(context: UIContext): void {
    this.csj_ad?.setExpressInteractionListener(this.interactionListener)
    this.csj_ad?.setDislikeCallback(this.dislikeCallback)
    this.csj_ad?.render(context)
  }

  adapter_getAdComponent(): NodeController | undefined {
    return this.csj_ad?.getAdComponent()
  }

  protected interactionListener: ExpressAdInteractionListener = {
    onRenderSuccess: (width: number, height: number) => {
      BYLog.debug(TAG + "横幅回调 - onAdRenderSuccess")
    },
    onRenderFail: (code: number, msg: string) => {
      BYLog.debug(TAG + "横幅回调 - onAdRenderFail")
      this.bridge?.bridge_didAdShowFailed(this.unitData.supplier, new AdvanceError(code, msg))
    },
    onAdShow: (type: number) => {
      BYLog.debug(TAG + "横幅回调 - onAdExposure")
      this.bridge?.bridge_didAdShow(this.unitData.supplier)
    },
    onAdClicked: (type: number) => {
      BYLog.debug(TAG + "横幅回调 - onAdClick")
      this.bridge?.bridge_didAdClick(this.unitData.supplier)
    }
  }
  protected dislikeCallback: CSJDislikeInteractionCallback = {
    onShow: () => {
    },
    /**
     * @param position 选择的位置
     * @param value 选择的内容
     * @param enforceRemove 是否强制关闭广告
     */
    onSelected: (position: number, value: string, enforceRemove: boolean) => {
      BYLog.debug(TAG + `横幅回调 - onAdClose`)
      this.bridge?.bridge_didAdClose()
    },
    onCancel: () => {

    }
  }
}