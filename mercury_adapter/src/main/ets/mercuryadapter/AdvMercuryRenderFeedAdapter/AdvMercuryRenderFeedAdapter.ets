import {
  BYLog,
  AdvanceAdnStatusResult,
  AdvanceError,
  ADV_ERR_DATA_NULL,
  AdvanceAdLoadState,
  AdvanceRenderFeedCommonAdapter,
  AdvanceRenderFeedWrapper,
} from 'advancesdk';
import { MercuryCloseType, MercuryEntry, MercuryErr, MercuryNative } from 'mercuryadhar';
import { AdvMercuryUtil } from '../AdvMercuryUtil';
import { AdvMercuryRenderFeedAdWrapper } from './AdvMercuryRenderFeedAdWrapper';


const TAG = `[AdvMercuryRenderFeedAdapter]`

export class AdvMercuryRenderFeedAdapter extends AdvanceRenderFeedCommonAdapter {
  protected mercury_ad?: MercuryNative
  protected wrapper?: AdvanceRenderFeedWrapper | undefined

  adapter_loadAd(): Promise<AdvanceAdnStatusResult> {
    BYLog.debug(TAG + ` adapter_loadAd start`)
    return new Promise<AdvanceAdnStatusResult>(async (resolve) => {
      let result = new AdvanceAdnStatusResult()
      let initResult = await AdvMercuryUtil.loadMercurySDK(this)
      BYLog.debug(TAG + `mercury初始化执行结果：${JSON.stringify(initResult)}`)

      if (initResult.success) { // 初始化成功
        //执行广告加载流程
        let sup = this.unitData.supplier
        if (sup) {
          let opt = new MercuryEntry()
            .setCodeId(sup.adspotid)
          this.mercury_ad = new MercuryNative(opt)
          this.mercury_ad.loadAd({
            onAdLoaded: () => {
              BYLog.debug(TAG + "自渲染信息流回调 - onAdLoaded")
              this.wrapper = new AdvMercuryRenderFeedAdWrapper(this.mercury_ad)
              result.status = AdvanceAdLoadState.success
              resolve(result)
            },
            onAdError: (err: MercuryErr): void => {
              BYLog.debug(TAG + `自渲染信息流回调 - onAdLoadFailed code: ${err.code} message: ${err.msg}`)
              result.status = AdvanceAdLoadState.failed
              result.errCode = err.code
              result.errMsg = err.msg
              resolve(result)
            },
            onMaterialCached: (isFromCache: boolean) => {},
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
    //Mercury广告没有渲染成功回调，load成功即认为渲染成功
    BYLog.debug(TAG + "模板信息流回调 - onAdRenderSuccess")
    this.bridge?.bridge_didAdRenderSuccess(this.wrapper!)

    this.mercury_ad?.setRenderListener({
      onShow: (): void => {
        BYLog.debug(TAG + "自渲染信息流回调 - onAdExposure")
        this.bridge?.bridge_didAdShow()
      },
      onClick: (): void => {
        BYLog.debug(TAG + "自渲染信息流回调 - onAdClick")
        this.bridge?.bridge_didAdClick()
      },
      onRenderErr: (err: MercuryErr): void => {
        BYLog.debug(TAG + "自渲染信息流回调 - onShowError")
        this.bridge?.bridge_didAdRenderFail(new AdvanceError(err.code, err.msg))
      },
      onClose: (type: MercuryCloseType): void => {
        BYLog.debug(TAG + `自渲染信息流回调 - onAdClose`)
        // this.bridge?.bridge_didAdClose()
      }
    })
  }

}