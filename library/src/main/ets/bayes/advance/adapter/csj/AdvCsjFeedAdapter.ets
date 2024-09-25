import { AdvanceRenderOption } from '../../config/AdvanceOption';
import { AdvanceADNCommonFeedAdapter } from '../../core/adn/AdvanceADNCommonFeedAdapter';
import { AdvanceAdnResult } from '../../model/AdvanceSendModel';
import { NodeController, UIContext } from '@kit.ArkUI';
import { AdvCsjUtil } from './AdvCsjUtil';
import { BYLog } from '../../../basic/BYLog';
import { BYDisplay } from '../../../basic/BYDisplay';
import { AdSlotBuilder, CSJAdCreator, CSJAdSdk, CSJNativeExpressAd } from '@csj/openadsdk';
import { ArrayList } from '@kit.ArkTS';
import AdvanceConstant from '../../model/AdvanceConstant';
import { AdvanceError, ADV_ERR_DATA_NULL, ADV_ERR_EXCEPTION_LOAD } from '../../model/AdvanceError';
import { AdvanceDislike } from '../../core/AdvanceDislike';

const TAG = `[AdvCsjFeedAdapter] `

export class AdvCsjFeedAdapter extends AdvanceADNCommonFeedAdapter {
  mFeedAd ?: CSJNativeExpressAd

  render(context: UIContext): void {
    this.mFeedAd?.render(context)
  }

  loadAd(): Promise<AdvanceAdnResult> {
    BYLog.devDebug(TAG + ` loadAd start`)
    return new Promise<AdvanceAdnResult>(async (resolve, reject) => {
      let result = new AdvanceAdnResult()
      try {
        let initResult = await AdvCsjUtil.canLoadAD(this)
        BYLog.debug(TAG + ` csj初始化执行结果：${JSON.stringify(initResult)}`)

        //
        if (initResult.initSucc == true) {
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

                result.resultStatus = AdvanceConstant.ADV_ADN_RESULT_FAILED
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
                  result.resultStatus = AdvanceConstant.ADV_ADN_RESULT_FAILED

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

                    this.callAdClick()
                  },

                  /**
                   * 广告的展示回调 每个广告仅回调一次
                   * @param type 广告的交互类型
                   */
                  onAdShow: (type: number) => {
                    BYLog.debug(TAG + "   onAdShow......");

                    this.callAdShow()
                  },

                  /**
                   * 模板渲染失败
                   */
                  onRenderFail: (code: number, msg: string) => {
                    BYLog.debug(TAG + "   onRenderFail...code=" + code + ",msg=" + msg);

                    this.callAdRenderFailed(new AdvanceError(code, msg))
                  },

                  /**
                   * 模板渲染成功
                   * @param width  返回view的宽 单位 vp
                   * @param height 返回view的高 单位 vp
                   */
                  onRenderSuccess: (width: number, height: number) => {

                    BYLog.debug(TAG + "   onRenderSuccess......width=" + width + ",height=" + height);

                    this.callAdRenderSuccess()
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

                result.resultStatus = AdvanceConstant.ADV_ADN_RESULT_SUCCESS
                resolve(result)

                BYLog.devDebug(TAG + 'after resolve')
              }
            })
          } else {
            result.resultStatus = AdvanceConstant.ADV_ADN_RESULT_FAILED

            result.errCode = ADV_ERR_DATA_NULL
            result.errMsg = '未找到该adn策略信息'
            resolve(result)
          }

        } else {
          result.resultStatus = AdvanceConstant.ADV_ADN_RESULT_FAILED
          result.errCode = initResult.errCode
          result.errMsg = initResult.errMsg
          resolve(result)
        }
      } catch (e) {
        BYLog.printE(e)
        if (result.resultStatus >= 0) {
          return
        }
        result.errCode = ADV_ERR_EXCEPTION_LOAD
        result.errMsg = 'adn请求时，代码异常'
        resolve(result)
      }

    })
  }

  //信息流用不到此方法
  showAd(advanceRenderOP: AdvanceRenderOption): void {
    // throw new Error('Method not implemented.');
  }

  getAdComponent(): NodeController | undefined {
    return this.mFeedAd?.getAdComponent()
  }
}