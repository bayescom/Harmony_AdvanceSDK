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


const TAG = `[AdvanceAdBase] `

export abstract class AdvanceAdBase implements AdvanceBaseOpenFuc {
  adOption: AdvanceOption
  baseListener ?: AdvanceBaseListener
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
  }

  loadStrategy(): void {
    AdvanceRequestManger.requestStrategy(this.adOption, (err, data) => {
      if (err) {
        this.baseListener?.onError(err)
        return
      }
      if (!data) {
        let advErr = new AdvanceError()
        advErr.code = ADV_ERR_DATA_NULL
        advErr.msg = '获取到得策略信息为空'
        this.baseListener?.onError(advErr)
        return
      }
      //将返回策略，解析成必要数据信息
      this.covertData(data)

    })
  }

  loadAdn() {

    try {

      //取第一组运行
      this.runningGroup = this.supplierGroups[0]

      let adnList = this.runningGroup.adnDataGroup
      for (let index = 0; index < adnList.length; index++) {

        const pri = adnList[index].supplier?.priority;
        if (pri) {
          let adapter: AdvanceADNCommonAdapter = this.adapterMap[pri]
          if (adapter) {
            BYLog.debug(TAG + `开始执行 pri：${pri}`)
            taskpool.execute(loadAdnAdapter, this.adapterMap[pri])
          } else {
            BYLog.warn(TAG + `未找到可执行sup得adapter`)
          }
        } else {
          BYLog.warn(TAG + `未找到可执行sup`)
        }

      }

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
            adnMap[element.priority] = adnData
            this.adapterMap[element.priority] = this.getAdnAdapter(adnData)
          }
        }
        BYLog.debug(TAG + ` update this.adapterMap , size = ${this.adapterMap.size}`)

        //说明无适配adapter
        if (this.adapterMap.size <= 0) {
          let advErr = new AdvanceError()
          advErr.code = ADV_ERR_NO_ADAPTER
          advErr.msg = '未找到可用广告adapter，请检查策略配置SDK与Advance已支持SDK是否一致'
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


  // todo 优化AdvanceADNCommonAdapter为interface接口形式
  abstract getAdnAdapter(adnData: AdvanceADNUnitData): AdvanceADNCommonAdapter | undefined


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
        return this.adapterMap[key]
      }
    } catch (e) {
      BYLog.printE(e)
    }
    return
  }
}

@Concurrent
function loadAdnAdapter(adapter: AdvanceADNCommonAdapter): Promise<boolean> {
  return adapter.loadAd()
}