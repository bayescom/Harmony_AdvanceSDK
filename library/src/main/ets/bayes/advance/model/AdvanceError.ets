
export const ADV_ERR_UNKNOW_ERROR = `6000`

//  网络请求超时
export const ADV_ERR_NET_TIME_OUT = 1000;

//    网络失败，一般是返回状态码非200
export const ADV_ERR_NET_FAILED = 1001;

//    代码执行报错，但已被 catch
export const ADV_ERR_NET_EXCEPTION = 1002;

// 不支持的返回类型
export const ADV_ERR_NET_UNSUPPORT_TYPE = 1003;

//广告位id信息为空

export const ADV_ERR_DATA_NULL = "9901";
export const ADV_ERR_EXCEPTION_LOAD = "9902";
export const ADV_ERR_EXCEPTION_SHOW = "9903";
export const ADV_ERR_EXCEPTION_RENDER = "9904";
export const ADV_ERR_NO_ADAPTER = "9905";

export class AdvanceError {
  code: string = ADV_ERR_UNKNOW_ERROR
  msg: string = ''

  toString(): string {
    return `[AdvanceError] code: ${this.code} , msg = ${this.msg}`
  }
}