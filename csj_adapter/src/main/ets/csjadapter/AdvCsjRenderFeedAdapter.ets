import { AdvanceRenderOption, AdvanceRenderFeedCommonAdapter, AdvanceAdnStatusResult, AdvanceRenderFeedData, BYLog, ADV_ERR_DATA_NULL, ADV_ERR_EXCEPTION_LOAD,
  AdvanceConstant, BYDisplay, AdvanceDislike } from 'AdvanceSDK';
import { NodeController, window } from '@kit.ArkUI';
import { AdSlot, AdSlotBuilder, CSJAdCreator, CSJAdSdk, CSJFeedAd, CSJNativeAd } from '@csj/openadsdk';
import { AdvCSJUtil } from './AdvCSJUtil';
import { ArrayList } from '@kit.ArkTS';
import { AdvCsjRenderFeedConvert } from './AdvCsjRenderFeedConvert';

const TAG = `[AdvCsjRenderFeedAdapter] `

export class AdvCsjRenderFeedAdapter extends AdvanceRenderFeedCommonAdapter {
  mNativeData: AdvanceRenderFeedData | undefined

  getNativeData(): AdvanceRenderFeedData | undefined {
    return this.mNativeData
  }

  adapter_isAdValid(): boolean {
    return true
  }

  adapter_loadAd(): Promise<AdvanceAdnStatusResult> {
    BYLog.devDebug(TAG + ` adapter_loadAd start`)
    return new Promise<AdvanceAdnStatusResult>(async (resolve, reject) => {
      let result = new AdvanceAdnStatusResult()
      try {

        let initResult = await AdvCSJUtil.loadCSJSDK(this)
        BYLog.debug(TAG + ` csj初始化执行结果：${JSON.stringify(initResult)}`)
        if (initResult.initSuccess == true) {
          //执行广告加载流程
          let sup = this.unitData.supplier
          if (!sup) {
            result.status = AdvanceConstant.ADV_ADN_STATUS_FAILED

            result.errCode = ADV_ERR_DATA_NULL
            result.errMsg = '未找到该adn策略信息'
            resolve(result)
            return
          }

          let w = this.unitData.ext?.vpWidth ?? 0
          let h = this.unitData.ext?.vpHeight ?? 0

          //未配置的话取屏幕宽
          if (w <= 0) {
            w = BYDisplay.px2VP(BYDisplay.getScreenWPX())
          }

          //高度0代表自适应
          if (h <= 0) {
            h = 0
          }
          let mAdCreator: CSJAdCreator = CSJAdSdk.getAdCreator()
          let adSlot: AdSlot = new AdSlotBuilder().setCodeId(sup.adspotid)
            .setAcceptSize(w, h)
            .setAdCount(1)
            .setSupportRenderControl(true)
            .build();
          mAdCreator.loadFeedAd(adSlot, {
            onError: (code: number, message: string) => {
              BYLog.debug(TAG + "  code=" + code + ",message-" + message);

              result.status = AdvanceConstant.ADV_ADN_STATUS_FAILED
              result.errCode = code + ''
              result.errMsg = message
              resolve(result)
            },
            /**
             * 广告加载成功的回调，接入方可以在这个回调中进行渲染
             *
             * @param ads 返回的广告列表
             */
            onFeedAdLoad: (ads: ArrayList<CSJFeedAd>) => {
              BYLog.debug(TAG + "  onFeedAdLoad......success");


              if (!ads || ads.length == 0 || !ads[0]) {
                result.status = AdvanceConstant.ADV_ADN_STATUS_FAILED

                result.errCode = ADV_ERR_DATA_NULL
                result.errMsg = '广告返回内容为空'
                resolve(result)
                return
              }

              this.onLoaded(ads[0])

              result.status = AdvanceConstant.ADV_ADN_STATUS_SUCCESS
              resolve(result)
            }
          })

        } else {
          result.status = AdvanceConstant.ADV_ADN_STATUS_FAILED
          result.errCode = initResult.code
          result.errMsg = initResult.msg
          resolve(result)
        }


      } catch (e) {
        BYLog.printE(e)
        if (result.status >= 0) {
          return
        }
        result.errCode = ADV_ERR_EXCEPTION_LOAD
        result.errMsg = 'adn请求时，代码异常'
        resolve(result)
      }

    })
  }


  private onLoaded(nativeAd: CSJFeedAd) {
    try { //赋值转换后数据信息
      this.mNativeData = new AdvCsjRenderFeedConvert(nativeAd)
      nativeAd.setExpressRenderListener({
        onRenderSuccess: (width: number, height: number, isExpress: boolean) => {
          BYLog.debug(TAG +
            `---setExpressRenderListener---  onRenderSuccess...... isExpress = ${isExpress} , width = ${width} , height = ${height} `);

          // this.callAdRenderSuccess()
        }
      })

      nativeAd.setDislikeCallback({
        /**
         * dislike show
         */
        onShow: () => {
          BYLog.debug(TAG + "   dislike......show");
        },

        /**
         * @param position 选择的位置
         * @param value 选择的内容
         * @param enforceRemove 是否强制关闭广告
         */
        onSelected: (position: number, value: string, enforceRemove: boolean) => {
          BYLog.debug(TAG + "   dislike......onSelected:position=" + position + ",value:" + value +
            ",enforce=" + enforceRemove);

          let advanceDislike = new AdvanceDislike()
          advanceDislike.reason = value
          advanceDislike.enforceRemove = enforceRemove
          this.nativeListener?.onDislike(advanceDislike)
        },

        /**
         * 点击取消
         */
        onCancel: () => {
          BYLog.debug(TAG + "   dislike......onCancel");
        }
      })
      nativeAd.setAdInteractionListener({
        onAdClicked: (ad: CSJNativeAd) => {
          BYLog.debug(TAG + "   onAdClicked......");

          // this.callAdClick()
        },

        /**
         * 创意点击事件
         * @param ad
         */
        onAdCreativeClick: (ad: CSJNativeAd) => {
          BYLog.debug(TAG + "   onAdCreativeClick......");

          // this.callAdClick()
        },

        /**
         * show展示回调
         * @param ad
         */
        onAdShow: (ad: CSJNativeAd) => {
          BYLog.debug(TAG + "   onAdShow......");

          // this.callAdShow()
        }
      })
    } catch (e) {
      BYLog.printE(e)
    }

  }

}