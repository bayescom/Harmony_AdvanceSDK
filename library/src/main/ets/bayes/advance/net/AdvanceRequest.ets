import http from '@ohos.net.http';
import { BYDevice } from '../../basic/BYDevice';
import { BYLog } from '../../basic/BYLog';
import { BYSingleton } from '../../basic/BYSingleton';
import {
  ADV_ERR_NET_UNSUPPORT_TYPE,
  ADV_ERR_NET_FAILED,
  ADV_ERR_NET_EXCEPTION,
  ADV_ERR_NET_TIME_OUT
} from '../model/AdvanceError';
import { AdvanceStrategyResponse } from '../model/AdvanceNetModel';


const TAG = "【AdvanceRequest】";
const baseUrl = "http://cruiser.bayescom.cn/"
const baseUrlHttps = "https://cruiser.bayescom.cn/"


async function requestSync(url: string, method: http.RequestMethod,
  expectDataType: http.HttpDataType = http.HttpDataType.STRING,
  extraData?: string | Object | ArrayBuffer): Promise<AdvanceStrategyResponse> {
  return new Promise<AdvanceStrategyResponse>((resolve) => {
    const res = new AdvanceStrategyResponse()
    let hasResult = false
    try {

     let tim = setTimeout(() => {
        try {
          if (hasResult == true) {
            BYLog.debug(TAG + `接口已返回，不再校验超时`)
            clearTimeout(tim)
            return
          }
          BYLog.warn(TAG + 'requestSync timeout')
          hasResult = true
          res.code = ADV_ERR_NET_TIME_OUT
          res.msg = `策略请求超时未响应`
          resolve(res)
          clearTimeout(tim)
        } catch (e) {
          BYLog.printE(e)
        }
      }, 5000)

      if (method === http.RequestMethod.POST) {
        if (!extraData) {
          // POST 必须有请求体，否则会报 Parameter error
          extraData = new Object();
        }
      }
      const httpRequest = http.createHttp();
      BYLog.devDebug(TAG + `start request, url: ${url}, method: ${method}, extraData: ` +
      JSON.stringify(extraData, undefined, undefined));

      let reqOption: http.HttpRequestOptions;

      reqOption = ({
        method: method,
        expectDataType: expectDataType,
        extraData: extraData
      })

      //get请求需要请求头添加ua
      if (method == http.RequestMethod.GET) {
        reqOption.header = { 'User-Agent': BYDevice.getUA() }
      }

      BYLog.debug(TAG + `reqOption.header = ${reqOption.header}`)

      httpRequest.request(
        url, reqOption, (err, data) => {
        try {
          if (err) {
            res.code = err.code
            let errMsg = err?.message ?? ""
            res.msg = `接口响应失败：` + errMsg
            BYLog.error(TAG + errMsg)
            resolve(res)
            return
          }
          // todo 请求http返回状态码为500 ，会导致app crash，如何避免？https://issuereporter.developer.huawei.com/detail/240914190446130/comment
          if (data && data.responseCode === 200) {
            BYLog.debug(TAG + `request success, url: ${url}, result: ${JSON.stringify(data, undefined, undefined)}`)

            if (data.resultType === http.HttpDataType.STRING) {
              let obj: AdvanceStrategyResponse = JSON.parse(JSON.stringify(data.result))

              res.suppliers = obj.suppliers
              res.code = obj.code
              res.msg = obj.msg
              res.abtag = obj.abtag
              res.reqid = obj.reqid
              res.setting = obj.setting

            } else if (data.resultType === http.HttpDataType.OBJECT) {
              const obj = data.result as AdvanceStrategyResponse;
              res.suppliers = obj.suppliers
              res.code = obj.code
              res.msg = obj.msg
              res.abtag = obj.abtag
              res.reqid = obj.reqid
              res.setting = obj.setting
            } else {
              res.code = ADV_ERR_NET_UNSUPPORT_TYPE
              res.msg = `UnSupport data type: ${data.resultType}`
            }
          } else {
            res.code = data?.responseCode ?? ADV_ERR_NET_FAILED
            res.msg = "http 请求responseCode 非200， responseCode = " +data?.responseCode
            BYLog.error(TAG + `request error, url: ${url}, error: ${JSON.stringify(err, undefined, undefined)}`)
          }
          // 当该请求使用完毕时，调用destroy方法主动销毁
          httpRequest.destroy();
        } catch (e) {
          BYLog.printE(e)
          try {
            res.code = ADV_ERR_NET_EXCEPTION
            let error = e as Error;
            let name = error.name;
            let msg = error.message;
            let inf = `请求中发生 exception ,err name:` + name + " , msg = " + msg
            res.msg = inf
          } catch (e) {
          }
        }
        hasResult = true
        resolve(res);
      }
      )
    } catch (e) {
      try {
        res.code = ADV_ERR_NET_EXCEPTION

        let error = e as Error;
        let name = error.name;
        let msg = error.message;
        let errInf = `请求发起阶段发生 exception  ,err name:` + name + " , msg = " + msg
        BYLog.error(TAG + errInf)
        BYLog.printE(e)
        if (!hasResult) {
          hasResult = true
          res.msg = errInf
          resolve(res);
        }
      } catch (e) {
      } finally {
        resolve(res);
      }
    }
    BYLog.debug(TAG + ' request end')
  })
}

function getBaseUrl(): string {
  let bUrl = baseUrl
  try {
    let useHttps = BYSingleton.get().useHttps
    if (useHttps) {
      bUrl = baseUrlHttps
    }
  } catch (e) {
    BYLog.printE(e)
  }
  return bUrl
}


export default class AdvanceNet {
  private static instance: AdvanceNet;

  private constructor() {
  }

  static get(): AdvanceNet {
    if (AdvanceNet.instance === undefined) {
      AdvanceNet.instance = new AdvanceNet();
    }
    return AdvanceNet.instance;
  }

  // 普通的上报请求，get方式
  async reportUrl(oriUrl: string): Promise<AdvanceStrategyResponse | object> {
    return requestSync(oriUrl, http.RequestMethod.GET)
  }

  //获取策略信息
  async getStrategy(body?: string | Object | ArrayBuffer): Promise<AdvanceStrategyResponse> {
    let reqUrl = `${getBaseUrl()}cruiser`
    return requestSync(reqUrl, http.RequestMethod.POST, http.HttpDataType.OBJECT, body)
  }
}