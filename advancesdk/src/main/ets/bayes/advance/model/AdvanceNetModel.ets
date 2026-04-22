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
  // ua: string = ""
  network: number = 0
  os: number = 4 // 4 代表鸿蒙os
  osv: string = ""
  devicetype: number = 1
  // sw: number = 0
  // sh: number = 0
  // ppi: number = 0
  // dpi: number = 0
  // density: number = 0
  imei: string = ""
  mac: string = ""
  aaid: string = ""
  oaid: string = ""
  odid: string = "" //鸿蒙odid，类似Androidid，示例返回： 64a2face-c129-e3fc-abfe-171f1da096d2
  operator: number = 0 //鸿蒙运营商名称、运营商信息, 枚举值 0:未知, 1:中国移动, 2:中国联通, 3:中国电信, 99:其他运营商
  make: string = ""
  model: string = ""
  brand: string = ""
  oaid_support: number = 0 //-1、-2代表代码报错，0代表不支持，1代表支持,2代表使用用户传递的非空OAID值，未进行获取操作
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
  setting : AdvanceSettingModel = new AdvanceSettingModel()
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
  index: number = 0
  bid_ratio: number = 0
  // [User Defined] 接口返回的是object类型，并非class实例。因为实例并未初始化，故自定义字段默认值为undefined。要转实例得使用class-transformer.
  isHit: boolean | undefined = undefined // 被命中
  loadAdState: AdvanceAdnLoadAdState | undefined = undefined
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
}