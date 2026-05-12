import { BYLog } from '../../basic/BYLog'
import { AdvanceAdLoadConfig } from '../config/AdvanceAdConfig'
import {
  AdvanceError,
  ADV_ERR_SDK_INIT_MISS,
  ADV_ERR_ALL_ADN_FAILED,
  ADV_ERR_DATA_NULL,
  ADV_ERR_ADN_TIMEOUT,
  ADV_ERR_ADN_INIT_FAILED
} from '../define/AdvanceError'
import { AdvanceStrategyModel, AdvanceSupplierModel } from '../model/AdvanceNetModel'
import { AdvanceRequestManager } from '../net/AdvanceRequestManager'
import { AdvanceCommonAdapter } from './adn/AdvanceCommonAdapter'
import { taskpool } from '@kit.ArkTS'
import AdvanceNetwork from '../net/AdvanceNetwork'
import { AdvanceUtil } from './AdvanceUtil'
import { BYConstant } from '../../basic/BYConstant'
import {
  AdvanceAdnLoadAdState, AdvanceAdnReportTKEventType,
} from '../define/AdvanceDefine'
import { AdvanceAdInfo } from '../model/AdvanceAdInfo'
import { AdvanceADNManager, AdvanceADNUnitData } from './adn/AdvanceADNManager'
import { systemDateTime } from '@kit.BasicServicesKit'
import { BYUtil } from '../../basic/BYUtil'
import { AdvanceAdCacheManager } from '../cache/AdvanceAdCacheManager'


const TAG = `[AdvanceAdBase] `

export abstract class AdvanceAdBase {
  protected adConfig: AdvanceAdLoadConfig
  protected adSlotType: number = 0
  protected winAdapter?: AdvanceCommonAdapter
  private adapterMap: Map<string, AdvanceCommonAdapter> | undefined = new Map()
  private strategyModel = new AdvanceStrategyModel()
  private errorInfo = new Map<string, object>()
  private loadTimestamp: number = 0 // 发起请求时间戳
  private timeoutId: number = 0
  // 已根据优先级排序的第一组parallel渠道
  private parallelSuppliers: AdvanceSupplierModel[] = []
  // head_bidding组渠道
  private biddingSuppliers: AdvanceSupplierModel[] = []
  // 混合策略组渠道
  private mixedSuppliers: AdvanceSupplierModel[] = []
  // bidding组中最高价渠道
  private bidTargetSupplier?: AdvanceSupplierModel

  // abstract functions
  // abstract loadStrategySuccess(model: AdvanceStrategyModel)
  protected abstract loadStrategyFailed(err: AdvanceError)

  // abstract startBidding(suppliers: AdvanceSupplierModel[])
  protected abstract loadAnyAdnAdapter(adapter: AdvanceCommonAdapter)

  protected abstract allAdnLoadAdFailed(err: AdvanceError)

  protected abstract adnBidWin(adInfo: AdvanceAdInfo)

  protected constructor(config: AdvanceAdLoadConfig) {
    this.adConfig = config
    this.adConfig.reqId = BYUtil.getReqID()
  }

  protected loadStrategy(): void {
    if (!BYConstant.context) {
      let advErr = new AdvanceError()
      advErr.code = ADV_ERR_SDK_INIT_MISS
      advErr.msg = '未找到上下文，请先确保完成AdvanceSDK初始化'
      BYLog.error(TAG + advErr.msg)
      this.loadStrategyFailed(advErr)
      return
    }

    this.loadTimestamp = systemDateTime.getTime()
    AdvanceRequestManager.requestAdStrategy(this.adConfig, (err, data) => {
      if (err) {
        BYLog.error(TAG + err.msg)
        this.loadStrategyFailed(err)
        return
      }
      if (!data) {
        let advErr = new AdvanceError()
        advErr.code = ADV_ERR_DATA_NULL
        advErr.msg = '获取到得策略信息为空'
        BYLog.error(TAG + advErr.msg)
        this.loadStrategyFailed(advErr)
        return
      }
      this.strategyModel = data
      // success callback
      // this.loadStrategySuccess(data)
      // 执行SDK策略
      this.loadSuppliersConcurrently()
    })
  }

  // 并发加载各个渠道SDK
  private loadSuppliersConcurrently() {
    if (this.strategyModel.setting.head_bidding_group.length == 0 && !this.bidTargetSupplier) { // 瀑布流模式，无head_bidding渠道
      // 策略组无数据说明所有的组加载广告全部没有成功（因为第一层执行完总会被remove掉）
      if (this.strategyModel.setting.parallel_group.length == 0) {
        this.allAdnLoadAdFailed(new AdvanceError(ADV_ERR_ALL_ADN_FAILED,
          `所有平台都未返回广告（失败或超时）\n详情：${JSON.stringify(Array.from(this.errorInfo))}`))
        return
      }
    }
    // 取BiddingGroup组
    if (this.strategyModel.setting.head_bidding_group.length) {
      this.biddingSuppliers = this.strategyModel.setting.head_bidding_group.map((priority: number) => {
        return this.strategyModel.suppliers.filter((supplier: AdvanceSupplierModel) => {
          return supplier.priority === priority
        })[0]
      })
    }
    // 取parallelGroup当前第一层策略组
    if (this.strategyModel.setting.parallel_group.length) {
      this.parallelSuppliers = this.strategyModel.setting.parallel_group[0].map((priority: number) => {
        return this.strategyModel.suppliers.filter((supplier: AdvanceSupplierModel) => {
          return supplier.priority === priority
        })[0]
      })
    }
    // 对parallelSuppliers进行排序
    if (this.parallelSuppliers.length > 1) {
      this.sortedForPriceWithSuppliers(this.parallelSuppliers)
    }

    // 合并2个组，开始执行竞价策略的回调
    let templeSuppliers = new Array<AdvanceSupplierModel>()
    if (this.biddingSuppliers.length) {
      templeSuppliers.push(...this.biddingSuppliers)
    }
    if (this.parallelSuppliers.length) {
      templeSuppliers.push(...this.parallelSuppliers)
    }
    // this.startBidding(templeSuppliers)
    // 并发执行混合策略下队列中的广告请求
    templeSuppliers.forEach(async (supplier: AdvanceSupplierModel) => {
      this.reportAdnTask(AdvanceAdnReportTKEventType.loaded, supplier)

      let adnData = new AdvanceADNUnitData()
      adnData.supplier = supplier
      adnData.adType = this.adSlotType
      //宽高属性值设置
      adnData.vpWidth = this.adConfig.adWidth ?? 0
      adnData.vpHeight = this.adConfig.adHeight ?? 0
      // 初始化SDK
      let initResult = await AdvanceADNManager.loadADN(supplier)
      if (!initResult.success) {
        BYLog.debug(`${supplier.name}渠道SDK执行初始化失败`)
        this.checkTarget(supplier, AdvanceAdnLoadAdState.failed, new AdvanceError(ADV_ERR_ADN_INIT_FAILED,
          `${supplier.name}初始化失败：code: ${initResult.code}, msg: ${initResult.msg}`))
        return // 在 forEach 中相当于 continue
      }
      BYLog.debug(`${supplier.name}渠道SDK执行初始化成功`)
      this.reportAdnTask(AdvanceAdnReportTKEventType.loadend, supplier)

      let adapter: AdvanceCommonAdapter | undefined = undefined
      // 尝试获取Adapter缓存
      let cacheModel = AdvanceAdCacheManager.getAdCacheModelFromCachedKey(supplier.sdk_id)
      if (supplier.enable_cache && cacheModel) {
        // 此次加载允许缓存 且 内存中存在Adapter缓存时
        supplier.cachedReqId = cacheModel.sourceReqId; //用于tk上报
        adapter = cacheModel.adObject as AdvanceCommonAdapter
        adapter.unitData = adnData
        adapter.isFromCache = true
        adapter.price = cacheModel.price
      } else {
        // 生成用来加载广告adn的适配器，进行后续广告请求及展示操作
        adapter = await AdvanceADNManager.generateAdnAdapter(adnData)
      }
      // 添加元素
      if (adapter) {
        this.adapterMap?.set(supplier.sdk_id, adapter)
        this.loadAnyAdnAdapter(adapter)
      }
    })

    // 执行完后移除parallel组渠道，确保再次调用此函数时能获取到下一组渠道
    if (this.strategyModel.setting.parallel_group.length) {
      this.strategyModel.setting.parallel_group.shift();
    }
    // 执行完后移除bidding组渠道，确保再次调用此函数时该组不再参与竞价
    if (this.strategyModel.setting.head_bidding_group.length) {
      [this.strategyModel.setting.head_bidding_group.splice(0)]
    }
    this.timeoutId = setTimeout(() => {
      this.observeLoadAdTimeout()
    }, this.strategyModel.setting.parallel_timeout)

  }

  // 超时监测
  private observeLoadAdTimeout() {
    let timeoutParallelSuppliers = this.parallelSuppliers.filter((supplier: AdvanceSupplierModel) => {
      return supplier.loadAdState === AdvanceAdnLoadAdState.ready || supplier.loadAdState === undefined
    })
    // check方法中对parallelSuppliers进行了移除操作，所以创建超时数组避免边遍历边移除带来问题
    timeoutParallelSuppliers.forEach((supplier: AdvanceSupplierModel, index: number) => {
      this.checkTarget(supplier, AdvanceAdnLoadAdState.timeout,
        new AdvanceError(ADV_ERR_ADN_TIMEOUT, '渠道广告加载超时'))
    })
    let timeoutBiddingSuppliers = this.biddingSuppliers.filter((supplier: AdvanceSupplierModel) => {
      return supplier.loadAdState === AdvanceAdnLoadAdState.ready || supplier.loadAdState === undefined
    })
    timeoutBiddingSuppliers.forEach((supplier: AdvanceSupplierModel, index: number) => {
      this.checkTarget(supplier, AdvanceAdnLoadAdState.timeout,
        new AdvanceError(ADV_ERR_ADN_TIMEOUT, '渠道广告加载超时'))
    })
  }

  /**
   * 检测是否命中用于展示的渠道
   * 由每个渠道SDK Callback返回结果时调用 或 超时后调用 或 SDK初始化失败时调用
   * @param supplier: loadAd后返回结果的某个渠道
   * @param state: loadAd后返回结果状态
   * @param error: 错误信息
   */
  protected checkTarget(supplier: AdvanceSupplierModel, state: AdvanceAdnLoadAdState, error?: AdvanceError) {
    // 监测超时的回调中已经执行了本方法，所以超时后渠道再返回的数据直接丢弃
    if (supplier.loadAdState == AdvanceAdnLoadAdState.timeout) {
      return;
    }
    supplier.loadAdState = state
    switch (state) {
      case AdvanceAdnLoadAdState.success:
        // 上报渠道广告获取成功
        this.reportAdnTask(AdvanceAdnReportTKEventType.succeed, supplier)
        break
      case AdvanceAdnLoadAdState.failed:
      case AdvanceAdnLoadAdState.timeout:
        // 移除失败和超时的渠道
        if (!supplier.is_head_bidding) {
          this.parallelSuppliers.splice(this.parallelSuppliers.indexOf(supplier), 1)
        } else {
          this.biddingSuppliers.splice(this.biddingSuppliers.indexOf(supplier), 1)
        }
        // 上报渠道广告获取失败/超时/初始化失败
        this.reportAdnTask(AdvanceAdnReportTKEventType.failed, supplier, error)
        break
      default:
        break
    }

    // biddingSuppliers元素为空 有2种可能
    // 1：本身无headbidding渠道，即瀑布流策略
    // 2：本身有headbidding渠道，但是组内渠道都执行失败了，此时也走瀑布流策略
    if (this.biddingSuppliers.length === 0 && !this.bidTargetSupplier) {
      // 进入瀑布流竞价执行、选中流程
      this.enterWaterfallFlow();

    } else { // 混合竞价模式（瀑布流 + 头部竞价）

      // 检测bidding组是否全部返回了结果，失败或超时渠道此前已被删除
      if (this.biddingSuppliers.filter((supplier: AdvanceSupplierModel) => {
        return supplier.loadAdState === AdvanceAdnLoadAdState.ready || supplier.loadAdState === undefined
      }).length) {
        return;
      }

      // 此时bidding组全部返回了结果，且组内都是竞价成功的渠道
      if (!this.bidTargetSupplier && this.biddingSuppliers.length) {
        // 对biddingSuppliers进行排序
        this.sortedForPriceWithSuppliers(this.biddingSuppliers)
        // 取出最高价渠道
        this.bidTargetSupplier = this.biddingSuppliers[0]
      }

      // 进入混合竞价（瀑布流 + 头部竞价）执行、选中流程
      this.enterWaterfallMixedHeadbiddingFlow()
    }
  }

  // 进入瀑布流竞价执行、选中流程
  private enterWaterfallFlow() {
    // 该parallel组渠道广告均返回失败，执行下一组渠道并发
    if (this.parallelSuppliers.length == 0) {
      clearTimeout(this.timeoutId)
      this.loadSuppliersConcurrently()
      return;
    }
    /// 命中用于展示的渠道并回调
    this.hitTheTargetWithSuppliers(this.parallelSuppliers)
  }

  // 进入混合竞价（瀑布流 + 头部竞价）执行、选中流程
  private enterWaterfallMixedHeadbiddingFlow() {
    // 如果当前的parallelSuppliers都返回失败，并且bidTarget 比下一组的最高价低 则需要开启下一组parallelGroup
    if (this.parallelSuppliers.length === 0 && this.strategyModel.setting.parallel_group.length) {
      let nextGroupPriorities = this.strategyModel.setting.parallel_group[0]
      let nextGroupSuppliers = nextGroupPriorities.map((priority: number) => {
        return this.strategyModel.suppliers.filter((supplier: AdvanceSupplierModel) => {
          return supplier.priority === priority
        })[0]
      })
      this.sortedForPriceWithSuppliers(nextGroupSuppliers)
      if (nextGroupSuppliers.length && this.bidTargetSupplier &&
        this.bidTargetSupplier.sdk_price < nextGroupSuppliers[0].sdk_price) {
        clearTimeout(this.timeoutId)
        this.loadSuppliersConcurrently()
        return;
      }
    }

    // 无需开启下一组parallelGroup时，直接产生最新的执行队列
    this.mixedSuppliers = new Array<AdvanceSupplierModel>()
    if (this.bidTargetSupplier) {
      this.mixedSuppliers.push(this.bidTargetSupplier)
    }
    if (this.parallelSuppliers.length) {
      this.mixedSuppliers.push(...this.parallelSuppliers)
    }
    // 对最新产生的执行队列按价格进行排序
    this.sortedForPriceWithSuppliers(this.mixedSuppliers)
    // 命中用于展示的渠道并回调
    this.hitTheTargetWithSuppliers(this.mixedSuppliers)

  }

  // 命中用于展示的渠道并回调
  private hitTheTargetWithSuppliers(suppliers: AdvanceSupplierModel[]) {
    let target = suppliers[0]
    if (target.loadAdState === AdvanceAdnLoadAdState.success && !target.isHit) {
      clearTimeout(this.timeoutId)
      target.isHit = true
      this.winAdapter = this.adapterMap?.get(target.sdk_id)
      this.adnBidWin(AdvanceUtil.getAdvanceAdInfo(target, this.winAdapter?.isFromCache ?? false))
      // 竞胜上报
      this.reportAdnTask(AdvanceAdnReportTKEventType.bidWin, target)
    }
  }

  // 混合策略排序规则：1. 按价格排序 2. 价格一样按优先级排序
  private sortedForPriceWithSuppliers(suppliers: AdvanceSupplierModel[]) {
    suppliers.sort((a: AdvanceSupplierModel, b: AdvanceSupplierModel) => {
      if (a.sdk_price == b.sdk_price) {
        return a.priority - b.priority
      }
      return b.sdk_price - a.sdk_price
    })
  }

  // 设置渠道返回的竞价
  protected setECPMIfNeeded(supplier: AdvanceSupplierModel, ecpm: number) {
    if (supplier.is_head_bidding && ecpm > 0) {
      supplier.sdk_price = ecpm
    }
  }

  // 销毁各渠道Adapter对象
  public destroyAdapters(): void {
    this.adapterMap = undefined
  }

  /**
   * TK监测数据上报
   * @param eventType 事件类型
   * @param supplier 渠道对象
   * @param error 错误信息
   */
  protected reportAdnTask(eventType: AdvanceAdnReportTKEventType, supplier: AdvanceSupplierModel,
    error?: AdvanceError) {
    if (error) {
      this.collectAdnError(supplier, error)
    }
    let reportUrls = new Array<string>()
    switch (eventType) {
      case AdvanceAdnReportTKEventType.loaded:
        reportUrls = supplier.loadedtk
        break
      case AdvanceAdnReportTKEventType.loadend:
        reportUrls = supplier.loadendtk
        break
      case AdvanceAdnReportTKEventType.succeed:
        reportUrls = supplier.succeedtk
        break
      case AdvanceAdnReportTKEventType.failed:
        reportUrls = supplier.failedtk
        break
      case AdvanceAdnReportTKEventType.exposed:
        reportUrls = supplier.imptk
        break
      case AdvanceAdnReportTKEventType.clicked:
        reportUrls = supplier.clicktk
        break
      case AdvanceAdnReportTKEventType.bidWin: // 后台不下发时，reportUrls 为 undefined
        reportUrls = supplier.wintk
        break
      default:
        break
    }
    if (reportUrls && reportUrls.length) {
      // taskpool.execute(global_requestAdnEventTasks, reportUrls, eventType, supplier.sdk_price, this.loadTimestamp, supplier.cachedReqId,
      //   error)
      this.requestAdnEventTasks(reportUrls, eventType, supplier.sdk_price, this.loadTimestamp, supplier.cachedReqId,
        error)
    }
  }

  // 收集渠道广告加载错误的信息
  private collectAdnError(supplier: AdvanceSupplierModel, error?: AdvanceError) {
    // key: 渠道名-渠道id-sdk_id
    if (error) {
      const key = `${supplier.name}-${supplier.id}-${supplier.sdk_id}`
      this.errorInfo.set(key, error)
    }
  }

  // 应用每次发送http请求时，底层系统会从线程池中获取一个线程来执行。线程的执行过程由底层系统管理
  private requestAdnEventTasks(urls: string[], eventType: AdvanceAdnReportTKEventType, price: number,
    loadTimeStamp: number, cacheReqId?: string, error?: AdvanceError) {
    urls.forEach(async (url: string) => {
      let reportUrl = AdvanceUtil.joinUrlParameters(url, eventType, price, loadTimeStamp, cacheReqId, error)
      let model = await AdvanceNetwork.shared().reportUrl(reportUrl) as AdvanceStrategyModel
      if (model.code === 200) {
        BYLog.debug(`AdvanceTK上报成功：${reportUrl}`)
      } else {
        BYLog.debug(`AdvanceTK上报失败：${reportUrl}`)
      }
    })
  }
}

// 子线程中获取不到打印日志？？？
// @Concurrent
// function global_requestAdnEventTasks(urls: string[], eventType: AdvanceAdnReportTKEventType, price: number,
//   loadTimeStamp: number, cacheReqId?: string, error?: AdvanceError) {
//   urls.forEach(async (url: string) => {
//     let reportUrl = AdvanceUtil.joinUrlParameters(url, eventType, price, loadTimeStamp, cacheReqId, error)
//     let model = await AdvanceNetwork.shared().reportUrl(reportUrl) as AdvanceStrategyModel
//     if (model.code === 200) {
//       BYLog.debug(`AdvanceTK上报成功：${reportUrl}`)
//     } else {
//       BYLog.debug(`AdvanceTK上报失败：${reportUrl}`)
//     }
//   })
// }
