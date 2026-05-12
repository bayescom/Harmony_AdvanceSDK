import { window } from '@kit.ArkUI';
import {
  BYLog,
  AdvanceError,
  AdvanceInterstitialCommonAdapter, BYConstant,
  ADV_ERR_DATA_NULL, ADV_ERR_HUAWEI_SHOW_FAILED
} from 'advancesdk';
import { advertising } from '@kit.AdsKit';
import { AdvanceDeviceManager } from 'advancesdk/src/main/ets/bayes/advance/core/AdvanceDeviceManager';
import { BiddingInfo } from './AdvHuaweiUtil';
import { BusinessError, commonEventManager } from '@kit.BasicServicesKit';

const TAG = `[AdvHuaweiInterstitialAdapter]`

export class AdvHuaweiInterstitialAdapter extends AdvanceInterstitialCommonAdapter {
  protected huawei_ad?: advertising.Advertisement
  protected subscriber: commonEventManager.CommonEventSubscriber | null = null

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
      adType: 12,
      // 开放匿名设备标识符
      oaid: await AdvanceDeviceManager.getOAID()
    };
    // 创建AdLoader广告对象
    const adLoader: advertising.AdLoader = new advertising.AdLoader(BYConstant.context);
    // 调用广告请求接口
    adLoader.loadAd(adRequestParams, {}, {
      onAdLoadSuccess: (ads: Array<advertising.Advertisement>) => {
        if (ads && ads.length > 0) {
          BYLog.debug(TAG + "插屏回调 - onAdLoaded")
          this.huawei_ad = ads[0]
          const biddingInfo = this.huawei_ad.biddingInfo as BiddingInfo
          this.bridge?.bridge_cacheAdapterIfNeeded(this, this.unitData.supplier, biddingInfo.price)
          this.bridge?.bridge_didAdLoaded(this.unitData.supplier, biddingInfo.price)
        } else {
          this.bridge?.bridge_didAdLoadFailed(this.unitData.supplier, new AdvanceError(ADV_ERR_DATA_NULL, '广告返回内容为空'))
        }
      },
      onAdLoadFailure: (errorCode: number, errorMsg: string) => {
        BYLog.debug(TAG + `插屏回调 - onAdLoadFailed code: ${errorCode} message: ${errorMsg}`)
        this.bridge?.bridge_didAdLoadFailed(this.unitData.supplier, new AdvanceError(errorCode, errorMsg))
      },
    })
  }

  adapter_showAd(windowStage: window.WindowStage) {
    this.registerPPSReceiver()
    advertising.showAd(this.huawei_ad, {mute: true}, BYConstant.context)
  }

  protected registerPPSReceiver(): void {
    if (this.subscriber) {
      this.unRegisterPPSReceiver();
    }
    // 订阅者信息
    const subscribeInfo: commonEventManager.CommonEventSubscribeInfo = {
      events: ['com.huawei.hms.pps.action.PPS_INTERSTITIAL_STATUS_CHANGED'],
      publisherBundleName: 'com.huawei.hms.adsservice'
    };
    // 创建订阅者回调
    commonEventManager.createSubscriber(subscribeInfo,
      (err: BusinessError, commonEventSubscriber: commonEventManager.CommonEventSubscriber) => {
        if (err) {
          BYLog.debug( TAG + `Failed to create subscriber. Code is ${err.code}, message is ${err.message}`);
          return;
        }
        this.subscriber = commonEventSubscriber;
        // 订阅公共事件回调
        commonEventManager.subscribe(this.subscriber,
          (err: BusinessError, commonEventData: commonEventManager.CommonEventData) => {
            if (err) {
              BYLog.debug( TAG + `Failed to subscribe. Code is ${err.code}, message is ${err.message}`);
              return
            }
            // 获取插屏广告变化状态
            const status: string = commonEventData?.parameters?.['interstitial_ad_status'];
            switch (status) {
              case 'onAdOpen':
                BYLog.debug(TAG + "插屏回调 - onAdExposure")
                this.bridge?.bridge_didAdShow(this.unitData.supplier)
                break;
              case 'onAdClick':
                BYLog.debug(TAG + "插屏回调 - onAdClick")
                this.bridge?.bridge_didAdClick(this.unitData.supplier)
                break;
              case 'onAdClose':
                BYLog.debug(TAG + `插屏回调 - onAdClose`)
                this.bridge?.bridge_didAdClose()
                this.unRegisterPPSReceiver()
                break;
              case 'onAdFail':
                BYLog.debug(TAG + "插屏回调 - onShowError")
                this.bridge?.bridge_didAdShowFailed(this.unitData.supplier, new AdvanceError(ADV_ERR_HUAWEI_SHOW_FAILED, '华为广告展示失败'))
                this.unRegisterPPSReceiver()
                break;
              default:
                break;
            }
          });
      });
  }

  protected unRegisterPPSReceiver(): void {
    commonEventManager.unsubscribe(this.subscriber, (err: BusinessError) => {
      if (err) {
        BYLog.debug( TAG + `Failed to unsubscribe. Code is ${err.code}, message is ${err.message}`);
      } else {
        BYLog.debug( TAG + 'Succeeded in unsubscribing');
        this.subscriber = null;
      }
    });
  }

}