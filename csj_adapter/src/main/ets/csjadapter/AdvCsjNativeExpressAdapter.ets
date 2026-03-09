import { AdvanceRenderOption, AdvanceNativeExpressCommonAdapter, AdvanceAdnStatusResult, BYLog, BYDisplay, AdvanceError,
  ADV_ERR_DATA_NULL, ADV_ERR_EXCEPTION_LOAD, AdvanceDislike, AdvanceConstant } from 'AdvanceSDK';
import { NodeController, UIContext, window } from '@kit.ArkUI';
import { AdvCSJUtil } from './AdvCSJUtil';
import { AdSlotBuilder, CSJAdCreator, CSJAdSdk, CSJNativeExpressAd } from '@csj/openadsdk';
import { ArrayList } from '@kit.ArkTS';

const TAG = `[AdvCsjNativeExpressAdapter] `

export class AdvCsjNativeExpressAdapter extends AdvanceNativeExpressCommonAdapter {
  mFeedAd ?: CSJNativeExpressAd

  render(context: UIContext): void {
    this.mFeedAd?.render(context)
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

        //
        if (initResult.success == true) {
          //执行广告加载流程
          let sup = this.unitData.supplier

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

          if (sup) {
            let adSlot = new AdSlotBuilder()
              .setCodeId(sup.adspotid)
              .setAcceptSize(w, h)
              .build()


            mAdCreator.loadExpressFeedAd(adSlot, {
              /**
               * 加载失败的回调
               *
               * @param code
               * @param message
               */
              onError: (code: number, message: string) => {
                BYLog.debug(TAG + "加载expressFeed 广告失败，code=" + code + "，message=" + message);

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

              onNativeExpressAdLoad: (ads: ArrayList<CSJNativeExpressAd>) => {
                BYLog.debug(TAG + "   onNativeExpressAdLoad......success");

                if (!ads || ads.length == 0 || !ads[0]) {
                  result.status = AdvanceConstant.ADV_ADN_STATUS_FAILED

                  result.errCode = ADV_ERR_DATA_NULL
                  result.errMsg = '广告返回内容为空'
                  resolve(result)
                  return
                }

                this.mFeedAd = ads[0]
                this.mFeedAd?.setExpressInteractionListener({
                  /**
                   *广告的点击回调
                   * @param type 广告的交互类型
                   */
                  onAdClicked: (type: number) => {
                    BYLog.debug(TAG + "   onAdClicked......");

                    // this.callAdClick()
                  },

                  /**
                   * 广告的展示回调 每个广告仅回调一次
                   * @param type 广告的交互类型
                   */
                  onAdShow: (type: number) => {
                    BYLog.debug(TAG + "   onAdShow......");

                    // this.callAdShow()
                  },

                  /**
                   * 模板渲染失败
                   */
                  onRenderFail: (code: number, msg: string) => {
                    BYLog.debug(TAG + "   onRenderFail...code=" + code + ",msg=" + msg);

                    // this.callAdRenderFailed(new AdvanceError(code, msg))
                  },

                  /**
                   * 模板渲染成功
                   * @param width  返回view的宽 单位 vp
                   * @param height 返回view的高 单位 vp
                   */
                  onRenderSuccess: (width: number, height: number) => {

                    BYLog.debug(TAG + "   onRenderSuccess......width=" + width + ",height=" + height);

                    // this.callAdRenderSuccess()
                  }
                })
                this.mFeedAd?.setDislikeCallback({
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
                    this.feedListener?.onDislike(advanceDislike)
                  },

                  /**
                   * 点击取消
                   */
                  onCancel: () => {
                    BYLog.debug(TAG + "   dislike......onCancel");
                  }
                })

                result.status = AdvanceConstant.ADV_ADN_STATUS_SUCCESS
                resolve(result)

                BYLog.devDebug(TAG + 'after resolve')
              }
            })
          } else {
            result.status = AdvanceConstant.ADV_ADN_STATUS_FAILED

            result.errCode = ADV_ERR_DATA_NULL
            result.errMsg = '未找到该adn策略信息'
            resolve(result)
          }

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

  adapter_getAdComponent(): NodeController | undefined {
    return this.mFeedAd?.getAdComponent()
  }
}