import { BYLog } from '../../basic/BYLog'
import { AdvanceOption } from '../config/AdvanceOption'
import { AdvanceADNUnitData, AdvanceSupplierExt } from '../model/AdvanceADNUnitData'
import { AdvanceError, ADV_ERR_ALL_FAILED, ADV_ERR_DATA_NULL, ADV_ERR_NO_ADAPTER } from '../model/AdvanceError'
import { AdvanceParaGroup } from '../model/AdvanceGroup'
import { AdvanceStrategyResponse } from '../model/AdvanceNetModel'
import { AdvanceRequestManger } from '../net/AdvanceRequestManger'
import { AdvanceADNCommonAdapter } from './AdvanceADNCommonAdapter'
import { AdvanceBaseOpenFuc } from './AdvanceOpenFuc'
import { AdvanceBaseListener } from './AdvanceOpenListener'
import { taskpool } from '@kit.ArkTS'
import { AdvanceAdnResult } from '../model/AdvanceSendModel'
import AdvanceNet from '../net/AdvanceRequest'
import { BYStrUtil } from '../../basic/util/BYStrUtil'
import { AdvanceADNManger } from './AdvanceADNManger'
import AdvanceConstant from '../model/AdvanceConstant'
import { AdvanceSupplier } from '../model/AdvanceSupplier'
import { AdvanceUtil } from './AdvanceUtil'


const TAG = `[AdvanceAdBase] `

export abstract class AdvanceAdBase implements AdvanceBaseOpenFuc {
  adOption: AdvanceOption
  baseListener ?: AdvanceBaseListener
  adSlotType: number = 0
  paraTimeOut: number = AdvanceConstant.ADV_PARA_GROUP_TIMEOUT //组超时时间，单位毫秒
  //并行策略组
  supplierGroups: AdvanceParaGroup[] = []
  //当前执行的SDK组
  runningGroup ?: AdvanceParaGroup
  // currentAD ?: AdvanceADNUnitData
  adapterMap: Map<number, AdvanceADNCommonAdapter> = new Map()

  constructor(option: AdvanceOption) {
    this.adOption = option
    // try {
    //
    // } catch (e) {
    //   BYLog.printE(e)
    // }
    this.init()
  }

  loadStrategy(): void {
    AdvanceRequestManger.requestStrategy(this.adOption, (err, data) => {
      if (err) {
        BYLog.error(TAG + err.msg)
        this.baseListener?.onError(err)
        return
      }
      if (!data) {
        let advErr = new AdvanceError()
        advErr.code = ADV_ERR_DATA_NULL
        advErr.msg = '获取到得策略信息为空'
        BYLog.error(TAG + advErr.msg)
        this.baseListener?.onError(advErr)
        return
      }
      //将返回策略，解析成必要数据信息
      this.covertData(data)

    })
  }


  //首先映射对应adnAdapter到map。再对策略进行分组，获得并发组data
  covertData(data: AdvanceStrategyResponse) {
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
            adnData.adType = this.adSlotType
            adnMap[element.priority] = adnData
            // todo 是否有必要保留？？？？
            let adapter = AdvanceADNManger.getAdnAdapter(adnData)
            //添加元素
            if (adapter) {
              this.adapterMap.set(element.priority, adapter)
            }
          }
        } else {
          BYLog.warn(TAG + " suppliers empty")
        }
        BYLog.debug(TAG + ` update this.adapterMap , size = ${this.adapterMap.size}`)

        //说明无适配adapter
        if (this.adapterMap.size <= 0) {
          let advErr = new AdvanceError()
          advErr.code = ADV_ERR_NO_ADAPTER
          advErr.msg = '未找到可用广告adapter，请检查策略配置SDK与Advance已支持SDK是否一致'
          BYLog.error(TAG + advErr.msg)
          this.baseListener?.onError(advErr)
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
          this.baseListener?.onError(advErr)
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
        this.baseListener?.onError(advErr)
      }
    } catch (e) {
      BYLog.printE(e)
    }
  }

  async loadAdn() {

    try {
      //取第一组运行
      this.runningGroup = this.supplierGroups[0]

      let adnList = this.runningGroup.adnDataGroup
      for (let index = 0; index < adnList.length; index++) {
        const adnData = adnList[index];
        let supplier = adnData.supplier

        if (adnData && supplier) {
          let adInf = `adspotid：${supplier.adspotid} (${supplier.priority})`
          BYLog.debug(TAG + `开始执行  ` + adInf)
          let task: taskpool.Task = new taskpool.Task(loadAdnAdapter, adnList[index]);
          taskpool.execute(task).then((it) => {
            BYLog.debug(TAG + `${adInf} taskpool执行结果：${JSON.stringify(it)}`)


            this.updateResultCheckNext(adnData, it as AdvanceAdnResult)
          })

          //上报SDK启动事件
          taskpool.execute(reportLoaded, supplier.loadedtk)
        } else {
          BYLog.warn(TAG + `未找到可执行sup`)
        }


      }


      let tim = setTimeout(() => {
        try {
          if (!this.runningGroup) {
            BYLog.debug(TAG + `runningGroup null , skip loadAdn timeout `)
            return
          }
          if (this.runningGroup.isGroupAllResult || this.runningGroup.isTimeOut) {
            BYLog.debug(TAG + `组内已全部返回记过，不再校验超时`)
            clearTimeout(tim)
            return
          }
          BYLog.warn(TAG + 'loadAdn timeout')
          this.runningGroup.isTimeOut = true
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

  // 更新结果并检查是否可以进行下一步（回调广告成功）  todo biddng返回需要重排序
  updateResultCheckNext(adnData: AdvanceADNUnitData, adnResult?: AdvanceAdnResult) {
    try {
      if (!adnResult) {
        BYLog.debug(TAG + `--updateResultCheckNext-- 请求返回为空`)
        return
      }

      if (!this.runningGroup) {
        BYLog.debug(TAG + `--updateResultCheckNext-- 非当前执行组不存在`)
        return
      }
      let currentGroupId = this.runningGroup.groupID
      if (currentGroupId && currentGroupId > 0 && currentGroupId != adnData.groupID) {
        BYLog.debug(TAG + `--updateResultCheckNext-- 非当前执行组`)
        return
      }

      let currentSup = adnData.supplier
      if (currentSup) {
        // BYLog.debug(TAG + `--updateResultCheckNext-- 渠道信息为空`)
        //更新bid价格 todo 竞价系数
        if (adnResult.bidPrice > 0 && currentSup) {
          BYLog.devDebug(TAG + `更新价格`)
          currentSup.sdk_price = adnResult.bidPrice
        }
        // return
      }

      //更新状态信息
      adnData.resultStatus = adnResult.resultStatus
      //todo 上报广告失败、成功事件


      //****************** 以下为最优选择逻辑

      let groupAdn = this.runningGroup.adnDataGroup
      if (groupAdn.length > 0) {
        let groupSize = groupAdn.length
        let allHasResult = true
        //假定当前为最优为队首
        let tempBestAdn: AdvanceADNUnitData | undefined

        for (let index = 0; index < groupSize; index++) {
          const element = groupAdn[index];
          const eleSup = element.supplier
          if (element.resultStatus == AdvanceConstant.ADV_ADN_RESULT_FAILED) {
            groupSize--
            BYLog.debug(TAG + `--最优检查-- adn广告已失败，跳过， eleSup = ${eleSup}`)
            continue
          }
          //存在且成功返回
          if (eleSup && element.resultStatus != AdvanceConstant.ADV_ADN_RESULT_FAILED) {
            if (!tempBestAdn) {
              tempBestAdn = element
              BYLog.debug(TAG + `--最优检查-- 临时最优Adn赋值， eleSup = ${eleSup}`)
              continue
            } else {
              let tempBestSup = tempBestAdn.supplier
              if (tempBestSup) {
                //寻找优先级 && 价格 高于tempBestAdn得
                // if (eleSup.priority == tempBestSup.priority) {
                //   BYLog.debug(TAG + `--最优检查-- 当前adn，跳过`)
                //   break
                // }
                //优先价格
                if (eleSup.sdk_price > 0 && eleSup.sdk_price > tempBestSup.sdk_price) {
                  tempBestAdn = element
                  BYLog.debug(TAG + `--最优检查-- 替换价格更优Adn ， eleSup = ${eleSup}`)
                } else if (eleSup.sdk_price == tempBestSup.sdk_price) {
                  //价格相同（0=0也算），看优先级
                  if (eleSup.priority > 0 && eleSup.priority < tempBestSup.priority) {
                    BYLog.debug(TAG + `--最优检查-- 替换排序更优Adn ， eleSup = ${eleSup}`)
                    tempBestAdn = element
                  }
                }
              } else {
                BYLog.debug(TAG + `--最优检查-- tempBestSup null`)
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

        // todo 测试处理此处逻辑
        if (groupSize <= 0) {
          BYLog.debug(TAG + `本组广告失败， 尝试加载下一组`)
          this.loadNextGroup()
        }

        // todo biding需要全部返回且重排序后队首
        if (tempBestAdn && tempBestAdn.supplier && tempBestAdn.resultStatus == AdvanceConstant.ADV_ADN_RESULT_SUCCESS) {
          tempBestAdn.chooseBest = true
          this.runningGroup.bestADN = tempBestAdn
          let advanceBestSupplier = new AdvanceSupplier()
          advanceBestSupplier.adnID = tempBestAdn.supplier.id
          advanceBestSupplier.adnName = tempBestAdn.supplier.name
          advanceBestSupplier.adSlotID = tempBestAdn.supplier.adspotid
          advanceBestSupplier.price = tempBestAdn.supplier.sdk_price
          BYLog.devDebug(TAG + `bestADN:${JSON.stringify(tempBestAdn)}`)
          BYLog.debug(TAG + `【当前最优】命中 ：${JSON.stringify(advanceBestSupplier)}`)
          this.baseListener?.onLoaded(advanceBestSupplier)
          //上报胜出
          taskpool.execute(reportWin, tempBestAdn.supplier.wintk)
        } else {
          BYLog.debug(TAG + `【当前最优】仍在请求中……`)
        }
      }
    } catch (e) {
      BYLog.printE(e)
    }

  }

  loadNextGroup() {
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
        this.baseListener?.onError(err)
        return
      }
      //继续执行
      this.loadAdn()
    } catch (e) {
      BYLog.printE(e)
    }
  }

  // todo 优化AdvanceADNCommonAdapter为interface接口形式
  // abstract getAdnAdapter(adnData: AdvanceADNUnitData): AdvanceADNCommonAdapter | undefined
  abstract init()


  // getBestAdn():AdvanceADNUnitData  | undefined {
  //   if (this.runningGroup ) {
  //     let hasResult :boolean
  //     if (this.runningGroup.isBiddingGroup ){
  //       hasResult = this.runningGroup.isBiddingAllResult
  //     } else {
  //       hasResult = this.runningGroup.isGroupAllResult
  //     }
  //   }
  // return
  // }

  //根据currentAD 找到对应adapter
  getCurrentAdapter(): AdvanceADNCommonAdapter | undefined {
    try {
      //从当前执行组的最佳广告
      let key = this.runningGroup?.bestADN?.supplier?.priority
      if (key) {
        return this.adapterMap.get(key)
      }
    } catch (e) {
      BYLog.printE(e)
    }
    return
  }
}


@Concurrent
function reportLoaded(urlList: string[]) {
  for (let index = 0; index < urlList.length; index++) {
    const element = urlList[index];
    if (BYStrUtil.isNotEmpty(element)) {
      BYLog.debug('start reportUrl')
      // todo 宏替换
      AdvanceNet.get().reportUrl(AdvanceUtil.getTimeReplacedTk(element))
    }
  }
}

@Concurrent
function reportWin(urlList: string[]) {
  for (let index = 0; index < urlList.length; index++) {
    const element = urlList[index];
    if (BYStrUtil.isNotEmpty(element)) {
      BYLog.debug('start reportUrl')
      // todo 宏替换
      AdvanceNet.get().reportUrl(AdvanceUtil.getTimeReplacedTk(element))
    }
  }
}

@Concurrent
function reportAdnSucc(urlList: string[]) {
  for (let index = 0; index < urlList.length; index++) {
    const element = urlList[index];
    if (BYStrUtil.isNotEmpty(element)) {
      BYLog.debug('start reportUrl')
      // todo 宏替换
      AdvanceNet.get().reportUrl(AdvanceUtil.getTimeReplacedTk(element))
    }
  }
}

@Concurrent
function reportAdnFailed(urlList: string[], err: AdvanceError) {
  for (let index = 0; index < urlList.length; index++) {
    const element = urlList[index];
    if (BYStrUtil.isNotEmpty(element)) {
      BYLog.debug('start reportUrl')
      // todo 宏替换
      AdvanceNet.get().reportUrl(AdvanceUtil.getTimeReplacedTk(element))
    }
  }
}


@Concurrent
async function loadAdnAdapter(adnData: AdvanceADNUnitData): Promise<AdvanceAdnResult> {
  let tag = '--loadAdnAdapter--'
  BYLog.debug(tag + "  start ")
  let result = new AdvanceAdnResult()
  try {
    // let start: number = new Date().getTime();
    // while (new Date().getTime() - start < 2000) {
    //   continue;
    // }
    let adid = adnData.supplier?.adspotid
    BYLog.debug(tag + ' adid = ' + adid)
    if (adid) {
      result.adid = adid


      let adnSdkAdapter = AdvanceADNManger.getAdnAdapter(adnData)

      if (adnSdkAdapter) {
        let adResult = await adnSdkAdapter.loadAd()
        if (adResult) {
          result.resultStatus = 1
        } else {
          result.resultStatus = 0
        }
        BYLog.debug(tag + '  adResult = ' + adResult)
      } else {
        BYLog.warn(tag + 'adnSdkAdapter 不存在')
      }
    }
  } catch (e) {
    BYLog.printE(e)
  }

  return result
}