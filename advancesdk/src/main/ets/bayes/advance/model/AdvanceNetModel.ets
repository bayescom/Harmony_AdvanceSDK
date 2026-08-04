import { AdvanceAdnLoadAdState } from '../define/AdvanceDefine'

// 	"version": "3.1.0",
// 	"sdk_version": "5.1.1",
// 	"time": "1725964754449",
// 	"appid": "",
// 	"adspotid": "10007795",
// 	"appver": "1.0",
// 	"reqid": "54cf2dda2a074d07ac39bef1ead5d4b1",
// 	"device_encinfo": "qSabBWBZ9rtMxhGRYquDUC30uXs5gN2ELgs_5XvfA7gvxaUaPyEKI73Qh80DHBIC73eh8FxcT6kbmxpXkK8gDcwCPQb9GXWVKXcUfbTR4WDOyyMIiQSe2BahN8GsMtp1J-BGqvzLpw8QhEk-YHxbYmwirzRll6tr9q7bKtH2R77MqfZEXuA2T6pNTPFODcK2DCw6DOL2p05iJuwL_UhbNPGl8CjOQRtFuJ5z_Jcvvz4eNqOdAtwRszjXMf195MGTCvY8EkJhnrbKa6Op4GhzOwj3TqF4L0q8SJ-E_ArS_fM="
// }

// 策略请求
export class AdvanceReqModel {
  version: string = ''
  sdk_version: string = ''
  time: string = ''
  appid: string = ''
  adspotid: string = ''
  appver: string = ''
  reqid: string = ''
  ext: Record<string, string> = {}
  device_encinfo: string = ''
}

//设备信息，请求时加密传输使用
export class AdvanceDeviceModel {
  network: number = 0
  os: number = 4 // 4 代表鸿蒙os
  osv: string = ""
  devicetype: number = 0
  carrier: string = ""
  make: string = ""
  model: string = ""
  /**
   * 区分以下三类id
   * https://developer.huawei.com/consumer/cn/doc/harmonyos-faqs/faq-basics-service-kit-14
   */
  oaid: string = ""
  aaid: string = ""
  odid: string = ""
}

// {
// 	"code": 200,
// 	"msg": "SUCCESS",
// 	"abtag": "A[11766]_默认分组[11791]",
// 	"suppliers": [{
// *******
// 	}],
// 	"setting": {
// 	 *******
// 	},
// 	"reqid": "54cf2dda2a074d07ac39bef1ead5d4b1"
// }
//策略整体返回信息
export class AdvanceStrategyModel {
  suppliers: AdvanceSupplierModel[] = [];
  code: number = 0
  msg: string = ""
  reqid: string = ""
  abtag: string = ""
  setting: AdvanceSettingModel = new AdvanceSettingModel()
  server_reward?: AdvanceServerReward

  static fromJson(json?: AdvanceStrategyModel): AdvanceStrategyModel {
    const model = new AdvanceStrategyModel()
    if (!json) {
      return model
    }

    model.suppliers = (json.suppliers ?? model.suppliers).map((supplier: AdvanceSupplierModel) => {
      return AdvanceSupplierModel.fromJson(supplier)
    })
    model.code = json.code ?? model.code
    model.msg = json.msg ?? model.msg
    model.reqid = json.reqid ?? model.reqid
    model.abtag = json.abtag ?? model.abtag
    model.setting = AdvanceSettingModel.fromJson(json.setting)
    if (json.server_reward) {
      model.server_reward = AdvanceServerReward.fromJson(json.server_reward)
    }
    return model
  }
}


// {
// 		"id": "3",
// 		"is_head_bidding": 0,
// 		"timeout": 5000,
// 		"adspotid": "952662081",
// 		"priority": 1,
// 		"failedtk": ["http:\/\/cruiser.bayescom.cn\/archon?abtag=A%5B11766%5D_%E9%BB%98%E8%AE%A4%E5%88%86%E7%BB%84%5B11791%5D&action=failed&adspotid=10007795&appid=102767&auction_id=54cf2dda2a074d07ac39bef1ead5d4b1&bid_time=1725964755448&dinfo=eyJvcyI6MiwiaW1laSI6Ijg2MTA2OTAzNDE0NjMyNyIsInVuaXF1ZV9kZXZpY2VpZCI6Ijg2MTA2OTAzNDE0NjMyNyJ9&priority=1&reqid=54cf2dda2a074d07ac39bef1ead5d4b1&request_time=1725964754449&sdk_adspotid=952662081&sdk_id=4208&sdk_version=5.1.1&supplierid=3&track_time=__TIME__&version=3.1.0"],
// 		"sdk_price": 0,
// 		"name": "穿山甲",
// 		"mediaid": "5404211",
// 		"mediakey": "",
// 		"bid_ratio": 1,
// 		"mediasecret": "",
// 		"index": 1,
// 		"adspotid": "952662081",
// 		"sdktag": "csj",
// 		"imptk": ["http:\/\/cruiser.bayescom.cn\/archon?abtag=A%5B11766%5D_%E9%BB%98%E8%AE%A4%E5%88%86%E7%BB%84%5B11791%5D&action=win&adspotid=10007795&appid=102767&auction_id=54cf2dda2a074d07ac39bef1ead5d4b1&bid_time=1725964755448&dinfo=eyJvcyI6MiwiaW1laSI6Ijg2MTA2OTAzNDE0NjMyNyIsInVuaXF1ZV9kZXZpY2VpZCI6Ijg2MTA2OTAzNDE0NjMyNyJ9&priority=1&reqid=54cf2dda2a074d07ac39bef1ead5d4b1&request_time=1725964754449&sdk_adspotid=952662081&sdk_id=4208&sdk_price=0&sdk_version=5.1.1&supplierid=3&track_time=__TIME__&version=3.1.0"],
// 		"clicktk": ["http:\/\/cruiser.bayescom.cn\/archon?abtag=A%5B11766%5D_%E9%BB%98%E8%AE%A4%E5%88%86%E7%BB%84%5B11791%5D&action=click&adspotid=10007795&appid=102767&auction_id=54cf2dda2a074d07ac39bef1ead5d4b1&bid_time=1725964755448&dinfo=eyJvcyI6MiwiaW1laSI6Ijg2MTA2OTAzNDE0NjMyNyIsInVuaXF1ZV9kZXZpY2VpZCI6Ijg2MTA2OTAzNDE0NjMyNyJ9&priority=1&reqid=54cf2dda2a074d07ac39bef1ead5d4b1&request_time=1725964754449&sdk_adspotid=952662081&sdk_id=4208&sdk_version=5.1.1&supplierid=3&track_time=__TIME__&version=3.1.0"],
// 		"loadedtk": ["http:\/\/cruiser.bayescom.cn\/archon?abtag=A%5B11766%5D_%E9%BB%98%E8%AE%A4%E5%88%86%E7%BB%84%5B11791%5D&action=loaded&adspotid=10007795&appid=102767&auction_id=54cf2dda2a074d07ac39bef1ead5d4b1&bid_time=1725964755448&dinfo=eyJvcyI6MiwiaW1laSI6Ijg2MTA2OTAzNDE0NjMyNyIsInVuaXF1ZV9kZXZpY2VpZCI6Ijg2MTA2OTAzNDE0NjMyNyJ9&priority=1&reqid=54cf2dda2a074d07ac39bef1ead5d4b1&request_time=1725964754449&sdk_adspotid=952662081&sdk_id=4208&sdk_version=5.1.1&supplierid=3&track_time=__TIME__&version=3.1.0"],
// 		"succeedtk": ["http:\/\/cruiser.bayescom.cn\/archon?abtag=A%5B11766%5D_%E9%BB%98%E8%AE%A4%E5%88%86%E7%BB%84%5B11791%5D&action=succeed&adspotid=10007795&appid=102767&auction_id=54cf2dda2a074d07ac39bef1ead5d4b1&bid_time=1725964755448&dinfo=eyJvcyI6MiwiaW1laSI6Ijg2MTA2OTAzNDE0NjMyNyIsInVuaXF1ZV9kZXZpY2VpZCI6Ijg2MTA2OTAzNDE0NjMyNyJ9&priority=1&reqid=54cf2dda2a074d07ac39bef1ead5d4b1&request_time=1725964754449&sdk_adspotid=952662081&sdk_id=4208&sdk_version=5.1.1&supplierid=3&track_time=__TIME__&version=3.1.0"]
// 	}

// 渠道信息返回体
export class AdvanceSupplierModel {
  id: string = ""
  name: string = ""
  adspotid: string = ""
  mediaid: string = ""
  mediakey: string = ""
  mediasecret: string = ""
  sdktag: string = ""
  sdk_id: string = '' // 渠道SDK广告源唯一id
  loadedtk: string[] = []
  loadendtk: string[] = []
  succeedtk: string[] = []
  failedtk: string[] = []
  wintk: string[] = []
  imptk: string[] = []
  clicktk: string[] = []
  is_head_bidding: number = 0
  timeout: number = 5000
  priority: number = 0 // 上游sdk优先级，数值越小优先级越高 最高为1
  sdk_price: number = 0
  bid_ratio: number = 0
  index: number = 0
  enable_cache: number = 0 // 1：表示需要缓存 0：表示不需要缓存
  cache_timeout: number | null = null // 缓存时间（秒），enable_cache 为 1 时有值
  // Custom ADN 相关
  is_custom_adn: number = 0; // 是否自定义渠道
  custom_params: string = ''; // 自定义JSON参数

  /**
   * [User Defined] 接口返回的是object类型。因为实例并未初始化，故自定义字段默认值为undefined。要转实例得使用class-transformer.
   * 或用以下替代方案`fromJson()`
   */
  isHit: boolean = false // 被命中
  loadAdState: AdvanceAdnLoadAdState = AdvanceAdnLoadAdState.ready
  cachedReqId: string | undefined = undefined // 缓存广告的reqId，用于tk上报

  static fromJson(json?: AdvanceSupplierModel): AdvanceSupplierModel {
    const model = new AdvanceSupplierModel()
    if (!json) {
      return model
    }

    model.id = json.id ?? model.id
    model.name = json.name ?? model.name
    model.adspotid = json.adspotid ?? model.adspotid
    model.mediaid = json.mediaid ?? model.mediaid
    model.mediakey = json.mediakey ?? model.mediakey
    model.mediasecret = json.mediasecret ?? model.mediasecret
    model.sdktag = json.sdktag ?? model.sdktag
    model.sdk_id = json.sdk_id ?? model.sdk_id
    model.loadedtk = json.loadedtk ?? model.loadedtk
    model.loadendtk = json.loadendtk ?? model.loadendtk
    model.succeedtk = json.succeedtk ?? model.succeedtk
    model.failedtk = json.failedtk ?? model.failedtk
    model.wintk = json.wintk ?? model.wintk
    model.imptk = json.imptk ?? model.imptk
    model.clicktk = json.clicktk ?? model.clicktk
    model.is_head_bidding = json.is_head_bidding ?? model.is_head_bidding
    model.timeout = json.timeout ?? model.timeout
    model.priority = json.priority ?? model.priority
    model.sdk_price = json.sdk_price ?? model.sdk_price
    model.bid_ratio = json.bid_ratio ?? model.bid_ratio
    model.index = json.index ?? model.index
    model.enable_cache = json.enable_cache ?? model.enable_cache
    model.cache_timeout = json.cache_timeout ?? model.cache_timeout
    model.is_custom_adn = json.is_custom_adn ?? model.is_custom_adn
    model.custom_params = json.custom_params ?? model.custom_params
    return model
  }
}

// "setting": {
// 		"bidding_type": 0,
// 		"parallel_timeout": 5000,
// 		"parallel_group": [
// 			[1]
// 		],
// 		"head_bidding_group": []
// 	},
// 策略统一设置内容、bidding设置内容
export class AdvanceSettingModel {
  bidding_type: number = 0 // 聚合竞价模式：0表示普通竞价，1 为 GroMore 竞价
  parallel_timeout: number = 5000 // SDK并行请求总体超时时长(ms)  默认值 5000
  // 并行策略组，该字段返回值为int型二维数组，每一组代表组内对应优先级的渠道需要并行，各个组之间需要串行
  parallel_group: number[][] = []
  // 需要进行headbidding的渠道SDK （存放is_head_bidding = 1 的 suppliers）
  head_bidding_group: number[] = []

  static fromJson(json?: AdvanceSettingModel): AdvanceSettingModel {
    const model = new AdvanceSettingModel()
    if (!json) {
      return model
    }

    model.bidding_type = json.bidding_type ?? model.bidding_type
    model.parallel_timeout = json.parallel_timeout ?? model.parallel_timeout
    model.parallel_group = json.parallel_group ?? model.parallel_group
    model.head_bidding_group = json.head_bidding_group ?? model.head_bidding_group
    return model
  }
}

// 服务端激励验证对象
export class AdvanceServerReward {
  // 当达成激励时，聚合SDK调用此链接询问服务端验证结果
  url: string = ''
  // 奖励发放的内容名称，用来透传
  name: string = ''
  // 奖励发放的数量，用来透传
  count: number = 0

  static fromJson(json?: AdvanceServerReward): AdvanceServerReward {
    const model = new AdvanceServerReward()
    if (!json) {
      return model
    }

    model.url = json.url ?? model.url
    model.name = json.name ?? model.name
    model.count = json.count ?? model.count
    return model
  }
}
