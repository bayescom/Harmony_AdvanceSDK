import {
  BYLog,
  AdvanceAdnStatusResult,
  ADV_ERR_DATA_NULL,
  AdvanceAdLoadState,
  AdvanceBannerCommonAdapter,
  AdvanceError,
  BYApp,
} from 'AdvanceSDK';
import {
  AdSlotBuilder, CSJAdCreator, CSJAdSdk,
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

  adapter_loadAd(): Promise<AdvanceAdnStatusResult> {
    BYLog.debug(TAG + ` adapter_loadAd start`)
    return new Promise<AdvanceAdnStatusResult>(async (resolve) => {
      let result = new AdvanceAdnStatusResult()
      let initResult = await AdvCSJUtil.loadCSJSDK(this)
      BYLog.debug(TAG + ` csj初始化执行结果：${JSON.stringify(initResult)}`)

      if (initResult.success) { // 初始化成功
        //执行广告加载流程
        let sup = this.unitData.supplier
        let width = this.unitData.ext?.vpWidth ?? 0
        let height = this.unitData.ext?.vpHeight ?? 0
        let mAdCreator: CSJAdCreator = CSJAdSdk.getAdCreator()

        if (sup) {
          let adSlot = new AdSlotBuilder()
            .setCodeId(sup.adspotid)
            .setAcceptSize(width, height)
            .setAdCount(1)
            .build()
          mAdCreator.loadBannerAd(adSlot, {
            onError: (code: number, message: string) => {
              BYLog.debug(TAG + `横幅回调 - onAdLoadFailed code: ${code} message: ${message}`)
              result.status = AdvanceAdLoadState.failed
              result.errCode = code
              result.errMsg = message
              resolve(result)
            },
            onNativeExpressAdLoad: (ads: ArrayList<CSJNativeExpressAd>) => {
              if (ads && ads.length > 0) {
                this.csj_ad = ads[0]
                this.csj_ad.setExpressInteractionListener(this.interactionListener)
                this.csj_ad.setDislikeCallback(this.dislikeCallback)
                this.csj_ad.render(BYApp.getUIContext())
                result.status = AdvanceAdLoadState.success
                resolve(result)
              };
            }
          })

        } else {
          result.status = AdvanceAdLoadState.failed
          result.errCode = ADV_ERR_DATA_NULL
          result.errMsg = '未找到该adn策略信息'
          resolve(result)
        }

      } else { // 初始化失败
        result.status = AdvanceAdLoadState.failed
        result.errCode = initResult.code
        result.errMsg = initResult.msg
        resolve(result)
      }
    })
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
      this.bridge?.bridge_didAdShowFailed(new AdvanceError(code, msg))
    },
    onAdShow: (type: number) => {
      BYLog.debug(TAG + "横幅回调 - onAdExposure")
      this.bridge?.bridge_didAdShow()
    },
    onAdClicked: (type: number) => {
      BYLog.debug(TAG + "横幅回调 - onAdClick")
      this.bridge?.bridge_didAdClick()
    }
  }

  protected  dislikeCallback: CSJDislikeInteractionCallback = {
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