import { GDTAdLoadConfig, GDTAdSDK, GDTError, GDTInteractionListener,
  GDTBannerAd,
  GDTAdSize,
  GDTRenderListener} from '@gdt/gdt-union-sdk';
import { NodeController } from '@kit.ArkUI';
import {
  BYLog,
  AdvanceAdnStatusResult,
  AdvanceError,
  ADV_ERR_DATA_NULL,
  ADV_ERR_AD_Invalid_Expired,
  AdvanceAdLoadState,
  AdvanceBannerCommonAdapter,
  BYConstant,
  BYApp,
} from 'AdvanceSDK';
import { AdvGDTUtil } from './AdvGDTUtil';


const TAG = `[AdvGDTBannerAdapter]`

export class AdvGDTBannerAdapter extends AdvanceBannerCommonAdapter {
  protected gdt_ad?: GDTBannerAd

  adapter_isAdValid(): boolean {
    const isAdValid = this.gdt_ad?.isValid() ?? false
    if (!isAdValid) {
      this.bridge?.bridge_didAdShowFailed(new AdvanceError(ADV_ERR_AD_Invalid_Expired, '广告展示前广告已失效过期'))
    }
    return isAdValid
  }

  adapter_loadAd(): Promise<AdvanceAdnStatusResult> {
    BYLog.debug(TAG + ` adapter_loadAd start`)
    return new Promise<AdvanceAdnStatusResult>(async (resolve) => {
      let result = new AdvanceAdnStatusResult()
      let initResult = await AdvGDTUtil.loadGDTSDK(this)
      BYLog.debug(TAG + `gdt初始化执行结果：${JSON.stringify(initResult)}`)

      if (initResult.success) { // 初始化成功
        //执行广告加载流程
        let sup = this.unitData.supplier
        let width = this.unitData.ext?.vpWidth ?? 0
        let height = this.unitData.ext?.vpHeight ?? 0
        if (sup) {
          const config: GDTAdLoadConfig = {
            posId: sup.adspotid,
            adSize: new GDTAdSize(width, height)
          };
          GDTAdSDK.getAdLoader().loadBannerAd(config, {
            onAdLoad: (ad: GDTBannerAd): void => {
              BYLog.debug(TAG + "横幅回调 - onAdLoaded")
              ad.setRefresh(0);
              ad.setInteractionListener(this.interactionListener);
              ad.setRenderListener(this.renderListener);
              ad.render(BYConstant.windowStage, BYApp.getUIContext());
              this.gdt_ad = ad
              result.status = AdvanceAdLoadState.success
              resolve(result)
            },
            onError: (err: GDTError): void => {
              BYLog.debug(TAG + `横幅回调 - onAdLoadFailed code: ${err.code} message: ${err.message}`)
              result.status = AdvanceAdLoadState.failed
              result.errCode = err.code
              result.errMsg = err.message
              resolve(result)
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
    return this.gdt_ad?.getAdComponent()
  }

  protected renderListener: GDTRenderListener = {
    onRenderSuccess: (): void => {
      BYLog.debug(TAG + "横幅回调 - onAdRenderSuccess")
    },
    onRenderFail: (err: GDTError): void => {
      BYLog.debug(TAG + "横幅回调 - onAdRenderFail")
      this.bridge?.bridge_didAdShowFailed(new AdvanceError(err.code, err.message))
    }
  };

  protected interactionListener: GDTInteractionListener = {
    onAdExposure: (): void => {
      BYLog.debug(TAG + "横幅回调 - onAdExposure")
      this.bridge?.bridge_didAdShow()
    },
    onAdClick: (): void => {
      BYLog.debug(TAG + "横幅回调 - onAdClick")
      this.bridge?.bridge_didAdClick()
    },
    onAdClose: (): void => {
      BYLog.debug(TAG + `横幅回调 - onAdClose`)
      this.bridge?.bridge_didAdClose()
    },
    onError: (err: GDTError): void => {
      BYLog.debug(TAG + "横幅回调 - onShowError")
      this.bridge?.bridge_didAdShowFailed(new AdvanceError(err.code, err.message))
    }
  }

}