import { NodeController } from '@kit.ArkUI';
import {
  BYLog,
  AdvanceError,
  ADV_ERR_DATA_NULL,
  ADV_ERR_HUAWEI_SHOW_FAILED,
  AdvanceNativeExpressCommonAdapter,
  BYConstant,
  BYDisplay,
  BYCustomNodeController,
} from 'advancesdk';
import { advertising, AdComponent } from '@kit.AdsKit';
import { BYDevice } from 'advancesdk/src/main/ets/bayes/basic/BYDevice';
import { BiddingInfo } from './AdvHuaweiUtil';
import { AdvHuaweiDisplayData } from './Component/AdvHuaweiDisplayPageView';

const TAG = `[AdvHuaweiNativeExpressAdapter]`

export class AdvHuaweiNativeExpressAdapter extends AdvanceNativeExpressCommonAdapter {
  protected huawei_ad?: advertising.Advertisement
  protected width = 0
  protected height = 0

  async adapter_loadAd() {
    //执行广告加载流程
    let spotId = this.unitData.supplier.adspotid
    let width = this.unitData.vpWidth ?? 0
    let height = this.unitData.vpHeight ?? 0
    //未配置的话取屏幕宽
    if (width <= 0) {
      width = BYDisplay.px2VP(BYDisplay.getScreenWPX())
    }
    //高度0代表自适应
    if (height <= 0) {
      height = 0
    }
    this.width = width;
    this.height = height;
    const adRequestParams: advertising.AdRequestParams = {
      // 广告位ID
      adId: spotId,
      // 广告类型
      adType: 3,
      // 请求的广告数量
      adCount: 1,
      // 原生广告扩展参数，是否直接返回广告，不用等待所有广告素材下载完成
      enableDirectReturnVideoAd: true,
      // 开放匿名设备标识符
      oaid: await BYDevice.getOAID(),
      // 这边设置宽高没有用，可忽略
      // adWidth: width,
      // adHeight: height,
    };
    // 创建AdLoader广告对象
    const adLoader: advertising.AdLoader = new advertising.AdLoader(BYConstant.context);
    // 调用广告请求接口
    adLoader.loadAd(adRequestParams, {}, {
      onAdLoadSuccess: (ads: Array<advertising.Advertisement>) => {
        if (ads && ads.length > 0) {
          BYLog.debug(TAG + "模板信息流回调 - onAdLoaded")
          this.huawei_ad = ads[0]
          const biddingInfo = this.huawei_ad.biddingInfo as BiddingInfo
          this.bridge?.bridge_didAdLoaded(this.unitData.supplier, biddingInfo.price)
        } else {
          this.bridge?.bridge_didAdLoadFailed(this.unitData.supplier, new AdvanceError(ADV_ERR_DATA_NULL, '广告返回内容为空'))
        }
      },
      onAdLoadFailure: (errorCode: number, errorMsg: string) => {
        BYLog.debug(TAG + `模板信息流回调 - onAdLoadFailed code: ${errorCode} message: ${errorMsg}`)
        this.bridge?.bridge_didAdLoadFailed(this.unitData.supplier, new AdvanceError(errorCode, errorMsg))
      },
    })
  }

  adapter_render(context: UIContext): void {
    //Huawei广告没有渲染成功回调，load成功即认为渲染成功
    BYLog.debug(TAG + "模板信息流回调 - onAdRenderSuccess")
    this.bridge?.bridge_didAdRenderSuccess(this.unitData.supplier)
  }

  adapter_getAdComponent(): NodeController | undefined {
    const data: AdvHuaweiDisplayData = {ad: this.huawei_ad, displayOptions: {mute: true}, listener: this.interactionListener, adWidth: this.width, adHeight: this.height}
    return new BYCustomNodeController(wrapBuilder(AdvHuaweiNativeViewBuilder), data)
  }

  protected interactionListener: advertising.AdInteractionListener = {
    onStatusChanged: (status: string, ad: advertising.Advertisement, data: string) => {
      switch (status) {
        case 'onAdOpen':
          BYLog.debug(TAG + "模板信息流回调 - onAdExposure")
          this.bridge?.bridge_didAdShow(this.unitData.supplier)
          break;
        case 'onAdClick':
          BYLog.debug(TAG + "模板信息流回调 - onAdClick")
          this.bridge?.bridge_didAdClick(this.unitData.supplier)
          break;
        case 'onAdClose':
          BYLog.debug(TAG + `模板信息流回调 - onAdClose`)
          this.bridge?.bridge_didAdClose()
          break;
        case 'onAdFail':
          BYLog.debug(TAG + "模板信息流回调 - onShowError")
          this.bridge?.bridge_didAdRenderFail(this.unitData.supplier, new AdvanceError(ADV_ERR_HUAWEI_SHOW_FAILED, data.length ? data : '华为广告展示失败'))
          break;
        case 'onMediaStart':
          BYLog.debug(TAG + "模板信息流回调 - onVideoStart")
          this.bridge?.bridge_didAdVideoPlayStart()
          break;
        case 'onMediaComplete':
          BYLog.debug(TAG + "模板信息流回调 - onVideoEnd")
          this.bridge?.bridge_didAdVideoPlayEnd()
          break;
        case 'onMediaError':
          BYLog.debug(TAG + `模板信息流回调 - onVideoFailed`)
          this.bridge?.bridge_didAdVideoPlayFailed(new AdvanceError(ADV_ERR_HUAWEI_SHOW_FAILED, data.length ? data : '华为广告播放失败'))
          break;
        default:
          break;
      }
    }
  }

}

@Builder
export function AdvHuaweiNativeViewBuilder(data: AdvHuaweiDisplayData) {
  Column() {
    AdComponent({
      ads: data.ad? [data.ad] : undefined,
      displayOptions: data.displayOptions,
      interactionListener: data.listener
    })
  }
  .width(data.adWidth)
  .height((data.adHeight != undefined && data.adHeight > 0) ? data.adHeight : undefined)
}