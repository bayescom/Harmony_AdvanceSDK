import { BYLog } from '../../basic/BYLog'
import { AdvanceAdLoadConfig } from '../config/AdvanceAdConfig'
import { AdvanceADNUnitData, AdvanceSupplierExt } from './adn/AdvanceADNUnitData'
import {
  AdvanceError,
  ADV_ERR_ADN_INIT_MISS,
  ADV_ERR_ALL_FAILED,
  ADV_ERR_DATA_NULL,
  ADV_ERR_NO_ADAPTER
} from '../define/AdvanceError'
import { AdvanceParaGroup } from '../model/AdvanceGroup'
import { AdvanceStrategyResponse } from '../model/AdvanceNetModel'
import { AdvanceRequestManger } from '../net/AdvanceRequestManger'
import { AdvanceCommonAdapter } from './adn/AdvanceCommonAdapter'
import { AdvanceAdLoadListener } from './AdvanceAdOpenListener'
import { taskpool } from '@kit.ArkTS'
import { AdvanceAdnStatusResult } from '../model/AdvanceSendModel'
import AdvanceNet from '../net/AdvanceRequest'
import { BYStrUtil } from '../../basic/util/BYStrUtil'
import { AdvanceADNManager } from './adn/AdvanceADNManager'
import { AdvanceConstant } from '../define/AdvanceConstant'
import { AdvanceUtil } from './AdvanceUtil'
import { BYConstant } from '../../basic/BYConstant'
import { window } from '@kit.ArkUI'
import { AdvanceAdLoadState } from '../../../../../../Index'


const TAG = `[AdvanceAdBase] `

export abstract class AdvanceAdBase {
  protected adConfig: AdvanceAdLoadConfig
  protected loadListener ?: AdvanceAdLoadListener
  protected adSlotType: number = 0
  protected paraTimeOut: number = AdvanceConstant.ADV_PARA_GROUP_TIMEOUT //组超时时间，单位毫秒
  //并行策略组
  protected supplierGroups: AdvanceParaGroup[] = []
  //当前执行的SDK组
  protected runningGroup ?: AdvanceParaGroup
  // currentAD ?: AdvanceADNUnitData
  protected adapterMap: Map<number, AdvanceCommonAdapter> | undefined = new Map()
  //最优adn
  protected tempBestAdn: AdvanceADNUnitData | undefined
  //当前组可用数量，用来判断是否组内全部失败
  protected currentGroupAbleSize: number = 0;

  protected abstract adnWin()

  constructor(config: AdvanceAdLoadConfig) {
    this.adConfig = config
  }


  protected loadStrategy(): void {
    try {
      if (!BYConstant.context) {
        let advErr = new AdvanceError()
        advErr.code = ADV_ERR_ADN_INIT_MISS
        advErr.msg = '未找到上下文，请先确保正确完成AdvanceSDK初始化'
        BYLog.error(TAG + advErr.msg)
        return
      }

      AdvanceRequestManger.requestStrategy(this.adConfig, (err, data) => {
        if (err) {
          BYLog.error(TAG + err.msg)
          this.loadListener?.onAdLoadFailed(err)
          return
        }
        if (!data) {
          let advErr = new AdvanceError()
          advErr.code = ADV_ERR_DATA_NULL
          advErr.msg = '获取到得策略信息为空'
          BYLog.error(TAG + advErr.msg)
          this.loadListener?.onAdLoadFailed(advErr)
          return
        }
        //将返回策略，解析成必要数据信息
        this.covertData(data)

      })
    } catch (e) {
      BYLog.printE(e)
    }
  }

  // //获取当前胜出的渠道信息
  // getWinSupplier(): AdvanceAdInfo | undefined {
  //   try {
  //     let bestSup = this.runningGroup?.bestADN?.supplier
  //     if (bestSup) {
  //       return AdvanceUtil.caseSupplier(bestSup)
  //     }
  //   } catch (e) {
  //     BYLog.printE(e)
  //   }
  //   return
  // }


  //首先映射对应adnAdapter到map。再对策略进行分组，获得并发组data
  protected async covertData(data: AdvanceStrategyResponse) {
    try {
      if (data.setting) {
        this.paraTimeOut = data.setting.parallel_timeout
        let paraGroup = data.setting.parallel_group
        let supList = data.suppliers

        let adnMap: Map<number, AdvanceADNUnitData> = new Map()

        if (supList && supList.length > 0) {
          for (let index = 0; index < supList.length; index++) {
            const element = supList[index];
            let adnData = new AdvanceADNUnitData()
            adnData.supplier = element
            adnData.ext = new AdvanceSupplierExt()
            //宽高属性值设置
            adnData.ext.vpWidth = this.adConfig.adWidth ?? 0
            adnData.ext.vpHeight = this.adConfig.adHeight ?? 0
            adnData.adType = this.adSlotType
            adnMap[element.priority] = adnData
            //生成用来加载广告adn的适配器，进行后续广告请求及展示操作
            let adapter = await AdvanceADNManager.generateAdnAdapter(adnData)
            //添加元素
            if (adapter) {
              this.adapterMap?.set(element.priority, adapter)
            }
          }
        } else {
          BYLog.warn(TAG + " suppliers empty")
        }

        let adapterSize = this.adapterMap?.size ?? 0
        BYLog.debug(TAG + ` update this.adapterMap , size = ${adapterSize}`)

        //说明无适配adapter
        if (adapterSize <= 0) {
          let advErr = new AdvanceError()
          advErr.code = ADV_ERR_NO_ADAPTER
          advErr.msg = '未找到可用广告adapter，请检查策略配置SDK与Advance已支持SDK是否一致'
          BYLog.error(TAG + advErr.msg)
          this.loadListener?.onAdLoadFailed(advErr)
          return
        }


        if (paraGroup.length > 0) {
          for (let index = 0; index < paraGroup.length; index++) {
            //单组并发
            const groupEle: number[] = paraGroup[index];
            //并发组
            let group: AdvanceParaGroup = new AdvanceParaGroup()
            //定义组id
            group.groupID = index
            for (let index = 0; index < groupEle.length; index++) {
              const priority: number = groupEle[index];
              let adnData: AdvanceADNUnitData = adnMap[priority]
              if (adnData) {
                group.adnDataGroup.push(adnData)
              } else {
                BYLog.debug(TAG + `not found adnData, priority = ${priority}`)
              }
            }

            //存在adn数据时，才加入组内
            if (group.adnDataGroup.length > 0) {
              this.supplierGroups.push(group)
            }


          }
        }

        //无并行组
        if (this.supplierGroups.length <= 0) {
          let advErr = new AdvanceError()
          advErr.code = ADV_ERR_DATA_NULL
          advErr.msg = '无可执行策略组信息'
          BYLog.error(TAG + advErr.msg)
          this.loadListener?.onAdLoadFailed(advErr)
          return
        }

        //开始加载SDK
        this.loadAdn()

        // todo  解析bidding组

      } else {

        let advErr = new AdvanceError()
        advErr.code = ADV_ERR_DATA_NULL
        advErr.msg = '策略组setting信息为空'
        BYLog.error(TAG + advErr.msg)
        this.loadListener?.onAdLoadFailed(advErr)
      }
    } catch (e) {
      BYLog.printE(e)
    }
  }

  protected async loadAdn() {

    try {
      if (!BYConstant.context) {
        let advErr = new AdvanceError()
        advErr.code = ADV_ERR_ADN_INIT_MISS
        advErr.msg = '未找到上下文，请先确保正确完成AdvanceSDK初始化'
        BYLog.error(TAG + advErr.msg)
        return
      }
      //取第一组运行
      this.runningGroup = this.supplierGroups[0]

      let adnList = this.runningGroup.adnDataGroup
      //赋值可用adn数量
      this.currentGroupAbleSize = adnList.length
      for (let index = 0; index < adnList.length; index++) {
        const adnData = adnList[index];
        let supplier = adnData.supplier

        if (adnData && supplier) {
          let adInf = `adspotid：${supplier.adspotid} (${supplier.priority})`
          BYLog.debug(TAG + `开始执行  ` + adInf)

          let adnAdapter = this.adapterMap?.get(supplier.priority)
          if (adnAdapter) {
            adnAdapter.adapter_loadAd().then((it) => {
              BYLog.debug(TAG + `${adInf} loadAdnAdapter 执行结果：${JSON.stringify(it)}`)

              this.updateResultPickBest(adnData, it as AdvanceAdnStatusResult)
            })
          }

          //上报SDK启动事件
          taskpool.execute(reportAdnLoaded, supplier.loadedtk)
        } else {
          BYLog.warn(TAG + `未找到可执行sup`)
        }


      }


      let tim = setTimeout(() => {
        try {
          if (this.runningGroup) {
            if (this.runningGroup.isGroupAllResult || this.runningGroup.isTimeOut) {
              BYLog.debug(TAG + `组内已全部返回记过，不再校验超时`)
              clearTimeout(tim)
              return
            }
            this.runningGroup.isTimeOut = true
          }
          BYLog.warn(TAG + 'loadAdn timeout，loadNextGroup')
          //本组超时，尝试加载下一组
          this.loadNextGroup()
          clearTimeout(tim)
        } catch (e) {
          BYLog.printE(e)
        }
      }, this.paraTimeOut)

    } catch (e) {
    }

  }


  // 更新结果并检查是否存在最优adn胜出，胜出后将（回调广告成功）  todo biddng返回需要重排序
  protected updateResultPickBest(adnData: AdvanceADNUnitData, adnResult?: AdvanceAdnStatusResult) {
    try {
      if (!adnResult) {
        BYLog.debug(TAG + `--updateResultCheckNext-- 请求返回为空`)
        return
      }

      if (!this.runningGroup) {
        BYLog.debug(TAG + `--updateResultCheckNext-- 当前执行组不存在`)
        return
      }
      let currentGroupId = this.runningGroup.groupID
      if (currentGroupId && currentGroupId > 0 && currentGroupId != adnData.groupID) {
        BYLog.debug(TAG + `--updateResultCheckNext-- 非当前执行组`)
        return
      }

      //更新状态信息
      adnData.resultStatus = adnResult.status

      let currentSup = adnData.supplier
      if (currentSup) {
        // BYLog.debug(TAG + `--updateResultCheckNext-- 渠道信息为空`)
        //更新bid价格 todo 竞价系数
        if (adnResult.bidPrice > 0 && currentSup) {
          BYLog.debug(TAG + `更新价格 ， adnResult.bidPrice = ${adnResult.bidPrice}`)
          currentSup.sdk_price = adnResult.bidPrice
        }

        let currentAdnInf = JSON.stringify(AdvanceUtil.getAdvanceAdInfo(currentSup))
        //上报广告成功、失败
        if (adnData.resultStatus == AdvanceAdLoadState.success) {
          BYLog.debug(TAG + `adn广告获取成功：${currentAdnInf}`)
          taskpool.execute(reportAdnSuccess, currentSup.succeedtk)
        } else if (adnData.resultStatus == AdvanceAdLoadState.failed) {
          BYLog.warn(TAG +
            `adn广告获取失败：${currentAdnInf}， code: ${adnResult.errCode}， msg: ${adnResult.errMsg}`)
          taskpool.execute(reportAdnFailed, currentSup.failedtk, new AdvanceError(adnResult.errCode, adnResult.errMsg))
        }
      }


      //****************** 以下为最优选择逻辑

      let groupAdn = this.runningGroup.adnDataGroup
      if (groupAdn.length > 0) {
        let groupSize = groupAdn.length
        this.currentGroupAbleSize = groupSize
        let allHasResult = true


        for (let index = 0; index < groupSize; index++) {
          const element = groupAdn[index];
          const eleSup = element.supplier

          //校验失败逻辑
          if (element.resultStatus == AdvanceAdLoadState.failed) {
            this.currentGroupAbleSize--
            if (eleSup && this.tempBestAdn) {
              let isBest = false
              let bestSup = this.tempBestAdn.supplier
              if (bestSup) {
                //如果优先级相同，代表了当前失败的为最优渠道
                isBest = eleSup.priority == bestSup.priority
              }
              //最优渠道失败了，则最优adn值置为空
              if (isBest) {
                BYLog.debug(TAG + `【临时最优】请求失败，重置临时最优`)
                this.tempBestAdn = undefined
              }
              BYLog.debug(TAG + ` adn广告已失败， sup_priority = ${eleSup?.priority} `)
            }
            continue
          }
          //存在且成功返回
          if (eleSup && element.resultStatus == AdvanceAdLoadState.success) {
            if (!this.tempBestAdn) {
              this.tempBestAdn = element
              BYLog.debug(TAG + ` 临时最优Adn赋值， sup_priority = ${eleSup?.priority}`)
              continue
            } else {
              let tempBestSup = this.tempBestAdn.supplier
              if (tempBestSup) {
                //寻找优先级 && 价格 高于tempBestAdn得
                // if (eleSup.priority == tempBestSup.priority) {
                //   BYLog.debug(TAG + `--最优检查-- 当前adn，跳过`)
                //   break
                // }
                //优先价格
                if (eleSup.sdk_price > 0 && eleSup.sdk_price > tempBestSup.sdk_price) {
                  BYLog.debug(TAG + `--临时最优检查-- 替换价格更优Adn ， eleSup = ${eleSup}`)
                  this.tempBestAdn = element
                } else if (eleSup.sdk_price == tempBestSup.sdk_price) {
                  //价格相同（0=0也算），看优先级
                  if (eleSup.priority > 0 && eleSup.priority < tempBestSup.priority) {
                    BYLog.debug(TAG + `--临时最优检查-- 替换排序更优Adn ， eleSup = ${eleSup}`)
                    this.tempBestAdn = element
                  }
                }
              } else {
                BYLog.debug(TAG + `--临时最优检查-- tempBestSup null`)
              }
            }
          }

          //全部都>0 代表有返回结果
          allHasResult = allHasResult && element.resultStatus >= 0
        }
        //循环遍历后 groupSize 为0代表全部失败了，需要进行下一组
        this.runningGroup.isGroupAllResult = allHasResult

        let best = this.runningGroup.bestADN
        if (best && best.chooseBest) {
          BYLog.debug(TAG + `【当前最优】已被选中`)
          return
        }


        let tempBestAdn = this.tempBestAdn
        // todo biding需要全部返回且重排序后队首
        if (tempBestAdn && tempBestAdn.supplier && tempBestAdn.resultStatus == AdvanceAdLoadState.success) {
          tempBestAdn.chooseBest = true
          this.runningGroup.bestADN = tempBestAdn
          let advanceBestSupplier = AdvanceUtil.getAdvanceAdInfo(tempBestAdn.supplier)
          BYLog.debug(TAG + `bestADN:${JSON.stringify(tempBestAdn)}`)
          BYLog.debug(TAG + `【当前最优】命中 ：${JSON.stringify(advanceBestSupplier)}`)

          //先设置adn中的listener
          this.adnWin()
          //执行回调给开发者
          this.loadListener?.onAdLoaded(advanceBestSupplier)
          //上报胜出
          taskpool.execute(reportAdnBidWin, tempBestAdn.supplier.wintk)
        } else if (tempBestAdn && tempBestAdn.resultStatus == AdvanceAdLoadState.loading) {
          BYLog.debug(TAG + `【临时最优】仍在请求中……`)
        } else if (tempBestAdn && tempBestAdn.resultStatus == AdvanceAdLoadState.failed) {
          BYLog.debug(TAG + `【临时最优】请求失败……`)
        } else {
          BYLog.debug(TAG + `未找到最优ADN……`)
        }


        if (this.currentGroupAbleSize <= 0) {
          BYLog.debug(TAG + `本组广告全部失败， 尝试加载下一组`)
          this.loadNextGroup()
        }
      }
    } catch (e) {
      BYLog.printE(e)
    }

  }

  protected loadNextGroup() {
    try { //移除第一组
      this.supplierGroups.splice(0)

      //无更多组 todo bidding组可能仍存在，如不存在此处需回调错误结果
      if (this.supplierGroups.length <= 0) {
        let msg = `全部渠道执行失败，请求结束`
        //全部渠道执行失败
        BYLog.error(TAG + msg)

        let err = new AdvanceError()
        err.code = ADV_ERR_ALL_FAILED
        err.msg = msg
        //回调广告失败
        this.loadListener?.onAdLoadFailed(err)
        // 销毁各渠道Adapter对象
        this.destroyAdapters()
        return
      }
      //继续执行
      this.loadAdn()
    } catch (e) {
      BYLog.printE(e)
    }
  }

  //根据currentAD 找到对应adapter
  protected getCurrentAdapter(): AdvanceCommonAdapter | undefined {
    try {
      //从当前执行组的最佳广告
      let key = this.runningGroup?.bestADN?.supplier?.priority
      if (key) {
        return this.adapterMap?.get(key)
      }
    } catch (e) {
      BYLog.printE(e)
    }
    return
  }

  // 销毁各渠道Adapter对象
  destroyAdapters(): void {
    this.loadListener = undefined
    this.adapterMap = undefined
  }

  protected reportBestAdnShowTask() {
    let urls = this.tempBestAdn?.supplier?.imptk
    if (urls) {
      taskpool.execute(reportAdnShow, urls)
    }
  }

  protected reportBestAdnShowFailedTask(error: AdvanceError) {
    let urls = this.tempBestAdn?.supplier?.failedtk
    if (urls) {
      taskpool.execute(reportAdnFailed, urls, error)
    }
  }

  protected reportBestAdnClickTask() {
    let urls = this.tempBestAdn?.supplier?.clicktk
    if (urls) {
      taskpool.execute(reportAdnClick, urls)
    }
  }

}


@Concurrent
function reportAdnLoaded(urlList: string[]) {
  try {
    if (!urlList) {
      BYLog.debug('reportAdnLoaded null')
      return
    }

    BYLog.debug(`广告启动上报发起`)

    for (let index = 0; index < urlList.length; index++) {
      const element = urlList[index];
      if (BYStrUtil.isNotEmpty(element)) {
        BYLog.debug('start reportAdnLoaded')
        // todo 宏替换
        AdvanceNet.get().reportUrl(AdvanceUtil.getTimeReplacedTk(element))
      }
    }
  } catch (e) {
    BYLog.printE(e)
  }
}


@Concurrent
function reportAdnSuccess(urlList: string[]) {
  try {
    if (!urlList) {
      BYLog.debug('reportAdnSuccess null')
      return
    }
    BYLog.debug(`广告成功上报发起`)
    for (let index = 0; index < urlList.length; index++) {
      const element = urlList[index];
      if (BYStrUtil.isNotEmpty(element)) {
        BYLog.debug('start reportAdnSuccess')
        // todo 宏替换
        AdvanceNet.get().reportUrl(AdvanceUtil.getTimeReplacedTk(element))
      }
    }
  } catch (e) {
    BYLog.printE(e)
  }
}

@Concurrent
function reportAdnFailed(urlList: string[], err: AdvanceError) {
  try {
    if (!urlList) {
      BYLog.debug('reportAdnFailed null')
      return
    }
    BYLog.debug(`广告失败上报发起`)
    for (let index = 0; index < urlList.length; index++) {
      const element = urlList[index];
      if (BYStrUtil.isNotEmpty(element)) {
        BYLog.debug('start reportAdnFailed')
        // todo 宏替换

        let url = AdvanceUtil.appendFailedReason(element, err)
        AdvanceNet.get().reportUrl(AdvanceUtil.getTimeReplacedTk(url))
      }
    }
  } catch (e) {
    BYLog.printE(e)
  }
}

@Concurrent
function reportAdnBidWin(urlList: string[]) {
  try {
    if (!urlList) {
      BYLog.debug('reportAdnBidWin null')
      return
    }
    BYLog.debug(`广告竞胜上报发起`)
    for (let index = 0; index < urlList.length; index++) {
      const element = urlList[index];
      if (BYStrUtil.isNotEmpty(element)) {
        BYLog.debug('start reportAdnBidWin')
        // todo 宏替换
        AdvanceNet.get().reportUrl(AdvanceUtil.getTimeReplacedTk(element))
      }
    }
  } catch (e) {
    BYLog.printE(e)
  }
}

@Concurrent
function reportAdnShow(urlList: string[]) {
  try {
    if (!urlList) {
      BYLog.debug('reportAdnShow null')
      return
    }
    BYLog.debug(`广告曝光成功上报发起`)
    for (let index = 0; index < urlList.length; index++) {
      const element = urlList[index];
      if (BYStrUtil.isNotEmpty(element)) {
        BYLog.debug('start reportAdnShow')
        AdvanceNet.get().reportUrl(AdvanceUtil.getTimeReplacedTk(element))
      }
    }
  } catch (e) {
    BYLog.printE(e)
  }
}

@Concurrent
function reportAdnClick(urlList: string[]) {
  try {
    if (!urlList) {
      BYLog.debug('reportAdnClick null')
      return
    }
    BYLog.debug(`广告点击成功上报发起`)
    for (let index = 0; index < urlList.length; index++) {
      const element = urlList[index];
      if (BYStrUtil.isNotEmpty(element)) {
        BYLog.debug('start reportAdnClick')
        AdvanceNet.get().reportUrl(AdvanceUtil.getTimeReplacedTk(element))
      }
    }
  } catch (e) {
    BYLog.printE(e)
  }
}
