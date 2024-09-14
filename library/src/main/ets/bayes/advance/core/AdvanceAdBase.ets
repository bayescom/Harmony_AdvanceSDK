import { BYLog } from '../../basic/BYLog'
import { AdvanceOption } from '../config/AdvanceOption'
import { AdvanceADNUnitData, AdvanceSupplierExt } from '../model/AdvanceADNUnitData'
import { AdvanceError, ADV_ERR_DATA_NULL, ADV_ERR_NO_ADAPTER } from '../model/AdvanceError'
import { AdvanceParaGroup } from '../model/AdvanceGroup'
import { AdvanceStrategyResponse } from '../model/AdvanceNetModel'
import { AdvanceRequestManger } from '../net/AdvanceRequestManger'
import { AdvanceADNCommonAdapter } from './AdvanceADNCommonAdapter'
import { AdvanceBaseOpenFuc } from './AdvanceOpenFuc'
import { AdvanceBaseListener } from './AdvanceOpenListener'
import { taskpool } from '@kit.ArkTS'
import { BusinessError } from '@kit.BasicServicesKit'
import { AdvanceAdnResult } from '../model/AdvanceSendModel'
import { AdvCSJSplashAdapter } from '../adapter/csj/AdvCSJSplashAdapter'
import AdvanceNet from '../net/AdvanceRequest'
import { BYStrUtil } from '../../basic/util/BYStrUtil'
import { AdvanceSDK } from '../AdvanceSDK'
import { AdvanceADNManger } from './AdvanceADNManger'


const TAG = `[AdvanceAdBase] `

export abstract class AdvanceAdBase implements AdvanceBaseOpenFuc {
  adOption: AdvanceOption
  baseListener ?: AdvanceBaseListener
  adSlotType: number = 0
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

      // let taskGroup: taskpool.TaskGroup = new taskpool.TaskGroup();

      for (let index = 0; index < adnList.length; index++) {

        const supplier = adnList[index].supplier;
        if (supplier) {
          let pri = supplier.priority
          let adapter = this.adapterMap.get(pri)
          if (adapter) {
            BYLog.debug(TAG + `开始执行 pri：${pri}`)
            // let load = adapter.loadAd().then((it) => {
            //    BYLog.debug(TAG + `${pri} 执行结果：${it}`)
            //  })
            let task: taskpool.Task = new taskpool.Task(loadAdnAdapter, adnList[index]);
            // let task: taskpool.Task = new taskpool.Task(strSortDelay, ['a','s','b']);
            taskpool.execute(task).then((it) => {
              BYLog.debug(TAG + `${pri} taskpool执行结果：${JSON.stringify(it)}`)
            })

            //上报SDK启动事件
            taskpool.execute(reportLoaded, supplier.loadedtk)
            // taskGroup.addTask(task);
            // BYLog.debug(TAG + `添加任务 pri：${pri}`)

          } else {
            BYLog.warn(TAG + `未找到可执行sup得adapter`)
          }
        } else {
          BYLog.warn(TAG + `未找到可执行sup`)
        }


      }

      // let result = await taskpool.execute(taskGroup)
      // BYLog.debug(TAG + `taskpool 执行 taskGroup 结果： ${result}`)

    } catch (e) {
    }

  }

  loadNextGroup() {
    //移除第一组
    this.supplierGroups.splice(0)

    //无更多组 todo bidding组可能仍存在，如不存在此处需回调错误结果
    if (this.supplierGroups.length <= 0) {
      BYLog.error(`并发组请求结束`)
      return
    }
    //继续执行
    this.loadAdn()
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
      AdvanceNet.get().reportUrl(element)
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