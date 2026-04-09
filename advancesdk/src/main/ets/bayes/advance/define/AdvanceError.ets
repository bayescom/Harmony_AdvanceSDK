
// 网络请求超时
export const ADV_ERR_NET_TIME_OUT = 1000;
// 网络失败，一般是返回状态码非200
export const ADV_ERR_NET_FAILED = 1001;
// 网络层代码执行报错
export const ADV_ERR_NET_EXCEPTION = 1002;
// 策略返回数据类型错误
export const ADV_ERR_NET_UNSUPPORT_TYPE = 1003;

// 策略中未配置渠道，请联系相关运营人员配置
export const ADV_ERR_DATA_NO_SUPPLIER = 9901;
// 策略信息为空 或 无广告返回，适用于信息流广告
export const ADV_ERR_DATA_NULL = 9902;
// 渠道广告加载超时
export const ADV_ERR_ADN_TIMEOUT = 9903;
// advance未初始化
export const ADV_ERR_SDK_INIT_MISS = 9904;
// adn渠道初始化失败
export const ADV_ERR_ADN_INIT_FAILED = 9905;
// 广告展示前广告已失效过期
export const ADV_ERR_AD_Invalid_Expired = 9906;
// 全部渠道加载失败
export const ADV_ERR_ALL_ADN_FAILED = 9907;


export class AdvanceError {
  code: string | number = 0
  msg: string = ''


  constructor(code?: number|string, msg?: string) {
    if (code) {
      this.code = `${code}`
    }
    if (msg) {
      this.msg = msg
    }
  }

  toString(): string {
    return `[AdvanceError] code = ${this.code}, msg = ${this.msg}`
  }
}