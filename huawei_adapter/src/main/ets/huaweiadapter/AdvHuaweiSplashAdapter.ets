import { window } from '@kit.ArkUI';
import {
  BYLog,
  AdvanceError,
  BYConstant,
  ADV_ERR_DATA_NULL,
  ADV_ERR_HUAWEI_SHOW_FAILED,
  BYWindowUtil,
  AdvanceCommonSplashAdapter,
  AdvBidWinLossResult,
  AdvBidWinLossResultType
} from 'advancesdk';
import { advertising } from '@kit.AdsKit';
import { AdvanceDeviceManager } from 'advancesdk/src/main/ets/bayes/advance/core/AdvanceDeviceManager';
import { BiddingInfo, sendBiddingResult } from './AdvHuaweiConfigAdapter';
import {
  AdvHuaweiDisplayData,
  HUAWEI_DISPLAY_PAGE_TAG,
  HUAWEI_STORAGE_AD_KEY
} from './Component/AdvHuaweiDisplayPageView';
import { BusinessError } from '@kit.BasicServicesKit';


const TAG = `[AdvHuaweiSplashAdapter]`

export class AdvHuaweiSplashAdapter extends AdvanceCommonSplashAdapter {
  protected huawei_ad?: advertising.Advertisement

  adapter_isAdValid(): boolean {
    return true
  }

  async adapter_loadAd() {
    //执行广告加载流程
    let spotId = this.unitData.placementId
    const adRequestParams: advertising.AdRequestParams = {
      // 广告位ID
      adId: spotId,
      // 广告类型
      adType: 1,
      // 请求的广告数量
      adCount: 1,
      // 开放匿名设备标识符
      oaid: await AdvanceDeviceManager.getOAID()
    };
    // 创建AdLoader广告对象
    const adLoader: advertising.AdLoader = new advertising.AdLoader(BYConstant.context);
    // 调用广告请求接口
    adLoader.loadAd(adRequestParams, {}, {
      onAdLoadSuccess: (ads: Array<advertising.Advertisement>) => {
        if (ads && ads.length > 0) {
          BYLog.debug(TAG + "开屏回调 - onAdLoaded")
          this.huawei_ad = ads[0]
          const biddingInfo = this.huawei_ad.biddingInfo as BiddingInfo
          this.bridge?.splash_didAdLoaded(this, biddingInfo.price)
        } else {
          this.bridge?.splash_didAdLoadFailed(this, new AdvanceError(ADV_ERR_DATA_NULL, '广告返回内容为空'))
        }
      },
      onAdLoadFailure: (errorCode: number, errorMsg: string) => {
        BYLog.debug(TAG + `开屏回调 - onAdLoadFailed code: ${errorCode} message: ${errorMsg}`)
        this.bridge?.splash_didAdLoadFailed(this, new AdvanceError(errorCode, errorMsg))
      },
    })
  }

  adapter_showAd(windowStage: window.WindowStage) {
    const data: AdvHuaweiDisplayData =
      { ad: this.huawei_ad, displayOptions: { mute: true }, listener: this.interactionListener }
    BYWindowUtil.createWindow(HUAWEI_DISPLAY_PAGE_TAG, HUAWEI_STORAGE_AD_KEY, data)
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
          BYLog.debug(TAG + "开屏回调 - onAdExposure")
          this.bridge?.splash_didAdShow(this)
          break;
        case 'onAdClick':
          BYLog.debug(TAG + "开屏回调 - onAdClick")
          BYWindowUtil.destroySubWindow()
          this.bridge?.splash_didAdClick(this)
          break;
        case 'onAdClose':
          BYLog.debug(TAG + `开屏回调 - onAdClose`)
          BYWindowUtil.destroySubWindow()
          this.bridge?.splash_didAdClose(this)
          break;
        case 'onAdFail':
          BYLog.debug(TAG + "开屏回调 - onShowError")
          BYWindowUtil.destroySubWindow()
          this.bridge?.splash_didAdShowFailed(this, new AdvanceError(ADV_ERR_HUAWEI_SHOW_FAILED, data.length ? data : '华为广告展示失败'))
          break;
        default:
          break;
      }
    }
  }
}