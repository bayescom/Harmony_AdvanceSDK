import { GDTAdLoadConfig, GDTAdSDK, GDTError, GDTInteractionListener,
  GDTNativeAd,
  GDTAdSize,
  GDTRenderListener,
  GDTVideoStateListener} from '@gdt/gdt-union-sdk';
import { NodeController } from '@kit.ArkUI';
import {
  BYLog,
  AdvanceAdnStatusResult,
  AdvanceError,
  ADV_ERR_DATA_NULL,
  ADV_ERR_AD_Invalid_Expired,
  AdvanceAdLoadState,
  AdvanceNativeExpressCommonAdapter,
  BYConstant,
  BYDisplay,
} from 'advancesdk';
import { AdvGDTUtil } from './AdvGDTUtil';


const TAG = `[AdvGDTNativeExpressAdapter]`

export class AdvGDTNativeExpressAdapter extends AdvanceNativeExpressCommonAdapter {
  protected gdt_ad?: GDTNativeAd

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
        //未配置的话取屏幕宽
        if (width <= 0) {
          width = BYDisplay.px2VP(BYDisplay.getScreenWPX())
        }
        //高度GDTAdSize.AUTO_HEIGHT代表自适应
        if (height <= 0) {
          height = GDTAdSize.AUTO_HEIGHT
        }
        if (sup) {
          const config: GDTAdLoadConfig = {
            posId: sup.adspotid,
            count: 1,
            adSize: new GDTAdSize(width, height)
          };
          GDTAdSDK.getAdLoader().loadNativeAd(config, {
            onAdLoad: (ads: Array<GDTNativeAd>): void => {
              if (ads && ads.length > 0) {
                BYLog.debug(TAG + "模板信息流回调 - onAdLoaded")
                this.gdt_ad = ads[0]
                result.status = AdvanceAdLoadState.success
                resolve(result)
              } else {
                result.status = AdvanceAdLoadState.failed
                result.errCode = ADV_ERR_DATA_NULL
                result.errMsg = '广告返回内容为空'
                resolve(result)
              };
            },
            onError: (err: GDTError): void => {
              BYLog.debug(TAG + `模板信息流回调 - onAdLoadFailed code: ${err.code} message: ${err.message}`)
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

  adapter_render(context: UIContext): void {
    this.gdt_ad?.setInteractionListener(this.interactionListener);
    this.gdt_ad?.setRenderListener(this.renderListener);
    this.gdt_ad?.setVideoStateListener(this.videoStateListener)
    if (this.gdt_ad?.isValid()) {
      this.gdt_ad?.render(BYConstant.windowStage, context);
    } else {
      this.bridge?.bridge_didAdRenderFail(new AdvanceError(ADV_ERR_AD_Invalid_Expired, '广告展示前广告已失效过期'))
    }
  }

  adapter_getAdComponent(): NodeController | undefined {
    return this.gdt_ad?.getAdComponent()
  }

  protected renderListener: GDTRenderListener = {
    onRenderSuccess: (): void => {
      BYLog.debug(TAG + "模板信息流回调 - onAdRenderSuccess")
      this.bridge?.bridge_didAdRenderSuccess()
    },
    onRenderFail: (err: GDTError): void => {
      BYLog.debug(TAG + "模板信息流回调 - onAdRenderFail")
      this.bridge?.bridge_didAdRenderFail(new AdvanceError(err.code, err.message))
    }
  };

  protected interactionListener: GDTInteractionListener = {
    onAdExposure: (): void => {
      BYLog.debug(TAG + "模板信息流回调 - onAdExposure")
      this.bridge?.bridge_didAdShow()
    },
    onAdClick: (): void => {
      BYLog.debug(TAG + "模板信息流回调 - onAdClick")
      this.bridge?.bridge_didAdClick()
    },
    onAdClose: (): void => {
      BYLog.debug(TAG + `模板信息流回调 - onAdClose`)
      this.bridge?.bridge_didAdClose()
    },
    onError: (err: GDTError): void => {
      BYLog.debug(TAG + "模板信息流回调 - onShowError")
      this.bridge?.bridge_didAdRenderFail(new AdvanceError(err.code, err.message))
    }
  }

  protected videoStateListener: GDTVideoStateListener = {
    onVideoStart: (): void => {
      BYLog.debug(TAG + "模板信息流回调 - onVideoStart")
      this.bridge?.bridge_didAdVideoPlayStart()
    },
    onVideoComplete: (): void => {
      BYLog.debug(TAG + "模板信息流回调 - onVideoEnd")
      this.bridge?.bridge_didAdVideoPlayEnd()
    },
    onVideoError: (err: GDTError): void => {
      BYLog.debug(TAG + `模板信息流回调 - onVideoFailed`)
      this.bridge?.bridge_didAdVideoPlayFailed(new AdvanceError(err.code, err.message))
    }
  }

}