import {
  BYLog, ADV_ERR_DATA_NULL, AdvanceError,
  AdvanceCommonBannerAdapter,
  AdvBidWinLossResult,
  AdvBidWinLossResultType,
} from 'advancesdk';
import {
  AdSlotBuilder,
  CSJAdCreator,
  CSJAdSdk,
  CSJDislikeInteractionCallback,
  CSJNativeExpressAd,
  ExpressAdInteractionListener,
} from '@csj/openadsdk';
import { ArrayList } from '@kit.ArkTS';
import { NodeController } from '@kit.ArkUI';

const TAG = `[XXXCustomBannerAdapter]`

export class XXXCustomBannerAdapter extends AdvanceCommonBannerAdapter {
  protected csj_ad?: CSJNativeExpressAd

  adapter_isAdValid(): boolean {
    return true
  }

  adapter_loadAd() {
    //执行广告加载流程
    let spotId = this.unitData.placementId
    let width = this.unitData.vpWidth ?? 0
    let height = this.unitData.vpHeight ?? 0
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
          this.bridge?.banner_didAdLoaded(this, 0)
        } else {
          this.bridge?.banner_didAdLoadFailed(this, new AdvanceError(ADV_ERR_DATA_NULL, '广告返回内容为空'))
        }
        ;
      },
      onError: (code: number, message: string) => {
        BYLog.debug(TAG + `横幅回调 - onAdLoadFailed code: ${code} message: ${message}`)
        this.bridge?.banner_didAdLoadFailed(this, new AdvanceError(code, message))
      }
    })
  }

  adapter_render(context: UIContext): void {
    this.csj_ad?.setExpressInteractionListener(this.interactionListener)
    this.csj_ad?.setDislikeCallback(this.dislikeCallback)
    this.csj_ad?.render(context)
  }

  adapter_getAdComponent(): NodeController | undefined {
    return this.csj_ad?.getAdComponent()
  }

  adapter_sendNotification(result: AdvBidWinLossResult): void {
    if (result.bidResultType === AdvBidWinLossResultType.win) {
      this.csj_ad?.win(result.secondPrice)
    } else {
      this.csj_ad?.loss(result.winPrice)
    }
  }

  protected interactionListener: ExpressAdInteractionListener = {
    onRenderSuccess: (width: number, height: number) => {
      BYLog.debug(TAG + "横幅回调 - onAdRenderSuccess")
    },
    onRenderFail: (code: number, msg: string) => {
      BYLog.debug(TAG + "横幅回调 - onAdRenderFail")
      this.bridge?.banner_didAdShowFailed(this, new AdvanceError(code, msg))
    },
    onAdShow: (type: number) => {
      BYLog.debug(TAG + "横幅回调 - onAdExposure")
      this.bridge?.banner_didAdShow(this)
    },
    onAdClicked: (type: number) => {
      BYLog.debug(TAG + "横幅回调 - onAdClick")
      this.bridge?.banner_didAdClick(this)
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
      this.bridge?.banner_didAdClose(this)
    },
    onCancel: () => {

    }
  }
}