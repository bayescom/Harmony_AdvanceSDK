import { NodeController } from '@kit.ArkUI';
import {
  BYLog,
  AdvanceError,
  ADV_ERR_DATA_NULL,
  ADV_ERR_HUAWEI_SHOW_FAILED,
  BYConstant,
  BYDisplay,
  BYCustomNodeController,
  AdvanceCommonNativeExpressAdapter,
  AdvBidWinLossResult,
  AdvBidWinLossResultType,
} from 'advancesdk';
import { advertising, AdComponent } from '@kit.AdsKit';
import { AdvanceDeviceManager } from 'advancesdk/src/main/ets/bayes/advance/core/AdvanceDeviceManager';
import { BiddingInfo, sendBiddingResult } from './AdvHuaweiConfigAdapter';
import { AdvHuaweiDisplayData } from './Component/AdvHuaweiDisplayPageView';
import { BusinessError } from '@kit.BasicServicesKit';

const TAG = `[AdvHuaweiNativeExpressAdapter]`

export class AdvHuaweiNativeExpressAdapter extends AdvanceCommonNativeExpressAdapter {
  protected huawei_ad?: advertising.Advertisement
  protected width = 0
  protected height = 0

  async adapter_loadAd() {
    //执行广告加载流程
    let spotId = this.unitData.placementId
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
      oaid: await AdvanceDeviceManager.getOAID(),
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
          this.bridge?.nativeExpress_didAdLoaded(this, biddingInfo.price)
        } else {
          this.bridge?.nativeExpress_didAdLoadFailed(this, new AdvanceError(ADV_ERR_DATA_NULL, '广告返回内容为空'))
        }
      },
      onAdLoadFailure: (errorCode: number, errorMsg: string) => {
        BYLog.debug(TAG + `模板信息流回调 - onAdLoadFailed code: ${errorCode} message: ${errorMsg}`)
        this.bridge?.nativeExpress_didAdLoadFailed(this, new AdvanceError(errorCode, errorMsg))
      },
    })
  }

  adapter_render(context: UIContext): void {
    //Huawei广告没有渲染成功回调，load成功即认为渲染成功
    BYLog.debug(TAG + "模板信息流回调 - onAdRenderSuccess")
    this.bridge?.nativeExpress_didAdRenderSuccess(this)
  }

  adapter_getAdComponent(): NodeController | undefined {
    const data: AdvHuaweiDisplayData = {ad: this.huawei_ad, displayOptions: {mute: true}, listener: this.interactionListener, adWidth: this.width, adHeight: this.height}
    return new BYCustomNodeController(wrapBuilder(AdvHuaweiNativeViewBuilder), data)
  }

  adapter_sendNotification(result: AdvBidWinLossResult): void {
    const biddingInfo = this.huawei_ad?.biddingInfo as BiddingInfo
    if (biddingInfo && biddingInfo.lurl) {
      let url: string = biddingInfo.lurl
      if (result.bidResultType === AdvBidWinLossResultType.win) {
        // 竞胜时，其他DSP最高出价
        url = url.replace('SECOND_PRICE', result.secondPrice.toString())
      } else {
        // 竞败时，其他DSP最高出价
        url = url.replace('AUCTION_PRICE', result.winPrice.toString())
        // 102：竞价失败
          .replace('AUCTION_LOSS', '102')
      }
      // 价格币种
      url = url.replace('AUCTION_CURRENCY', 'CNY')
      sendBiddingResult(url).catch((error: BusinessError) => {
        BYLog.debug(`Failed to sendBiddingResult. Code is ${error.code}, message is ${error.message}`);
      });
    }
  }

  protected interactionListener: advertising.AdInteractionListener = {
    onStatusChanged: (status: string, ad: advertising.Advertisement, data: string) => {
      switch (status) {
        case 'onAdOpen':
          BYLog.debug(TAG + "模板信息流回调 - onAdExposure")
          this.bridge?.nativeExpress_didAdShow(this)
          break;
        case 'onAdClick':
          BYLog.debug(TAG + "模板信息流回调 - onAdClick")
          this.bridge?.nativeExpress_didAdClick(this)
          break;
        case 'onAdClose':
          BYLog.debug(TAG + `模板信息流回调 - onAdClose`)
          this.bridge?.nativeExpress_didAdClose(this)
          break;
        case 'onAdFail':
          BYLog.debug(TAG + "模板信息流回调 - onShowError")
          this.bridge?.nativeExpress_didAdRenderFail(this, new AdvanceError(ADV_ERR_HUAWEI_SHOW_FAILED, data.length ? data : '华为广告展示失败'))
          break;
        case 'onMediaStart':
          BYLog.debug(TAG + "模板信息流回调 - onVideoStart")
          this.bridge?.nativeExpress_didAdVideoPlayStart(this)
          break;
        case 'onMediaComplete':
          BYLog.debug(TAG + "模板信息流回调 - onVideoEnd")
          this.bridge?.nativeExpress_didAdVideoPlayEnd(this)
          break;
        case 'onMediaError':
          BYLog.debug(TAG + `模板信息流回调 - onVideoFailed`)
          this.bridge?.nativeExpress_didAdVideoPlayFailed(this, new AdvanceError(ADV_ERR_HUAWEI_SHOW_FAILED, data.length ? data : '华为广告播放失败'))
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