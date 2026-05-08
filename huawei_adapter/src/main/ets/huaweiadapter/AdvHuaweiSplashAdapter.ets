import { window } from '@kit.ArkUI';
import {
  BYLog,
  AdvanceError,
  AdvanceSplashCommonAdapter, BYConstant, ADV_ERR_DATA_NULL, ADV_ERR_HUAWEI_SHOW_FAILED,
  BYWindowUtil
} from 'advancesdk';
import { advertising } from '@kit.AdsKit';
import { BYDevice } from 'advancesdk/src/main/ets/bayes/basic/BYDevice';
import { BiddingInfo } from './AdvHuaweiUtil';
import { AdvHuaweiDisplayData, HUAWEI_DISPLAY_PAGE_TAG, HUAWEI_STORAGE_AD_KEY } from './Component/AdvHuaweiDisplayPageView';


const TAG = `[AdvHuaweiSplashAdapter]`

export class AdvHuaweiSplashAdapter extends AdvanceSplashCommonAdapter {
  protected huawei_ad?: advertising.Advertisement

  adapter_isAdValid(): boolean {
    return true
  }

  async adapter_loadAd() {
    //执行广告加载流程
    let spotId = this.unitData.supplier.adspotid
    const adRequestParams: advertising.AdRequestParams = {
      // 广告位ID
      adId: spotId,
      // 广告类型
      adType: 1,
      // 请求的广告数量
      adCount: 1,
      // 开放匿名设备标识符
      oaid: await BYDevice.getOAID()
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
          this.bridge?.bridge_cacheAdapterIfNeeded(this, this.unitData.supplier, biddingInfo.price)
          this.bridge?.bridge_didAdLoaded(this.unitData.supplier, biddingInfo.price)
        } else {
          this.bridge?.bridge_didAdLoadFailed(this.unitData.supplier, new AdvanceError(ADV_ERR_DATA_NULL, '广告返回内容为空'))
        }
      },
      onAdLoadFailure: (errorCode: number, errorMsg: string) => {
        BYLog.debug(TAG + `开屏回调 - onAdLoadFailed code: ${errorCode} message: ${errorMsg}`)
        this.bridge?.bridge_didAdLoadFailed(this.unitData.supplier, new AdvanceError(errorCode, errorMsg))
      },
    })
  }

  adapter_showAd(windowStage: window.WindowStage) {
    const data: AdvHuaweiDisplayData = {ad: this.huawei_ad, displayOptions: {mute: true}, listener: this.interactionListener}
    BYWindowUtil.createWindow(HUAWEI_DISPLAY_PAGE_TAG, HUAWEI_STORAGE_AD_KEY, data)
  }

  protected interactionListener: advertising.AdInteractionListener = {
    onStatusChanged: (status: string, ad: advertising.Advertisement, data: string) => {
      switch (status) {
        case 'onAdOpen':
          BYLog.debug(TAG + "开屏回调 - onAdExposure")
          this.bridge?.bridge_didAdShow(this.unitData.supplier)
          break;
        case 'onAdClick':
          BYLog.debug(TAG + "开屏回调 - onAdClick")
          BYWindowUtil.destroySubWindow()
          this.bridge?.bridge_didAdClick(this.unitData.supplier)
          break;
        case 'onAdClose':
          BYLog.debug(TAG + `开屏回调 - onAdClose`)
          BYWindowUtil.destroySubWindow()
          this.bridge?.bridge_didAdClose()
          break;
        case 'onAdFail':
          BYLog.debug(TAG + "开屏回调 - onShowError")
          BYWindowUtil.destroySubWindow()
          this.bridge?.bridge_didAdShowFailed(this.unitData.supplier, new AdvanceError(ADV_ERR_HUAWEI_SHOW_FAILED, data.length ? data : '华为广告展示失败'))
          break;
        default:
          break;
      }
    }
  }

}