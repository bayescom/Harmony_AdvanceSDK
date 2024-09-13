import http from '@ohos.net.http';
import hilog from '@ohos.hilog';
import { BYDevice } from '../../basic/BYDevice';
import { BYLog } from '../../basic/BYLog';
import { BYSingleton } from '../../basic/BYSingleton';
import { ADV_ERR_NET_UNSUPPORT_TYPE, ADV_ERR_NET_FAILED, ADV_ERR_NET_EXCEPTION } from '../model/AdvanceError';
import { AdvanceStrategyResponse } from '../model/AdvanceNetModel';


const TAG = "AdvanceRequest";
const baseUrl = "http://cruiser.bayescom.cn/"
// const baseUrl = "http://raddus.bayescom.com/"
const baseUrlHttps = "https://cruiser.bayescom.cn/"


async function requestSync(url: string,
  method: http.RequestMethod,
  expectDataType: http.HttpDataType = http.HttpDataType.STRING,
  extraData?: string | Object | ArrayBuffer): Promise<AdvanceStrategyResponse> {
  return new Promise<AdvanceStrategyResponse>((resolve) => {
    const res = new AdvanceStrategyResponse()
    try {

      if (method === http.RequestMethod.POST) {
        if (!extraData) {
          // POST 必须有请求体，否则会报 Parameter error
          extraData = new Object();
        }
      }
      const httpRequest = http.createHttp();
      hilog.info(0, TAG,
        `start request, url: ${url}, method: ${method}, extraData: ` + JSON.stringify(extraData, undefined, undefined));

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

      BYLog.debug(`reqOption.header = ${reqOption.header}`)

      httpRequest.request(
        url, reqOption, (err, data) => {
        try {
          if (!err && data.responseCode === 200) {
            hilog.info(0, TAG, `request success, url: ${url}, result: ${JSON.stringify(data, undefined, undefined)}`)

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
            res.msg = err?.message ?? ""
            hilog.error(0, TAG, `request error, url: ${url}, error: ${JSON.stringify(err, undefined, undefined)}`)
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
            let inf = `request exception ,err name:` + name + " , msg = " + msg
            res.msg = inf
          } catch (e) {
          }
        }
        resolve(res);
      }
      )
    } catch (e) {
      BYLog.printE(e)
      resolve(res);
    }
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