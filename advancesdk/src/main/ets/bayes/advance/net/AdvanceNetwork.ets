import http from '@ohos.net.http';
import { BYLog } from '../../basic/BYLog';
import { AdvanceSetting } from '../config/AdvanceSetting';
import {
  ADV_ERR_NET_UNSUPPORT_TYPE,
  ADV_ERR_NET_FAILED,
  ADV_ERR_NET_EXCEPTION,
  ADV_ERR_NET_TIME_OUT
} from '../define/AdvanceError';
import { AdvanceStrategyModel } from '../model/AdvanceNetModel';


const TAG = "【AdvanceNetwork】";
const baseUrl = "http://cruiser.bayescom.cn/"
const baseUrlHttps = "https://cruiser.bayescom.cn/"

export default class AdvanceNetwork {
  private static instance: AdvanceNetwork;

  static shared(): AdvanceNetwork {
    if (AdvanceNetwork.instance === undefined) {
      AdvanceNetwork.instance = new AdvanceNetwork();
    }
    return AdvanceNetwork.instance;
  }

  // 获取策略信息
  async getStrategy(body?: string | Object | ArrayBuffer): Promise<AdvanceStrategyModel> {
    let reqUrl = `${getBaseUrl()}cruiser`
    return requestSync(reqUrl, http.RequestMethod.POST, body, http.HttpDataType.OBJECT, true)
  }

  // 普通的上报请求，get方式
  async reportUrl(oriUrl: string): Promise<AdvanceStrategyModel> {
    return requestSync(oriUrl, http.RequestMethod.GET)
  }

  // 服务端激励验证
  async verifyServerSideRewardedURL(oriUrl: string,
    parameters: Record<string, string | number>): Promise<AdvanceStrategyModel> {
    return requestSync(oriUrl, http.RequestMethod.POST, parameters, http.HttpDataType.OBJECT, true)
  }
}

/**
 * 网络请求方法
 * @param url 请求地址
 * @param method 请求方法
 * @param expectDataType 返回数据类型
 * @param extraData 请求体
 * @param forceTimeout 超时
 * @returns 策略对象
 */
async function requestSync(
  url: string,
  method: http.RequestMethod,
  extraData?: string | Object | ArrayBuffer,
  expectDataType: http.HttpDataType = http.HttpDataType.STRING,
  forceTimeout: boolean = false
): Promise<AdvanceStrategyModel> {
  return new Promise<AdvanceStrategyModel>((resolve) => {
    let res = new AdvanceStrategyModel()
    let hasResult = false
    try {

      if (forceTimeout) {
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
      }


      if (method === http.RequestMethod.POST) {
        if (!extraData) {
          // POST 必须有请求体，否则会报 Parameter error
          extraData = new Object();
        }
      }
      const httpRequest = http.createHttp();
      BYLog.debug(TAG + `start request, url: ${url}, method: ${method}, extraData: ` +
      JSON.stringify(extraData, undefined, undefined));

      let reqOption: http.HttpRequestOptions;

      reqOption = ({
        method: method,
        expectDataType: expectDataType,
        extraData: extraData
      })

      //get请求需要请求头添加ua
      // let ua = AdvanceDeviceManager.getUA()
      // if (method == http.RequestMethod.GET && BYStrUtil.isNotEmpty(ua)) {
      //   reqOption.header = { 'User-Agent': ua }
      // }

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
            BYLog.debug(TAG + `request success`)

            //post请求才打印返回信息
            if (method == http.RequestMethod.POST) {
              BYLog.debug(TAG +
                `request success, url: ${url}, result: ${JSON.stringify(data, undefined, undefined)}`)
            }

            if (data.resultType === http.HttpDataType.STRING) {
              res.code = data.responseCode
              res.msg = data.result as string

            } else if (data.resultType === http.HttpDataType.OBJECT) {
              const obj = data.result as AdvanceStrategyModel;
              res = obj
              // res.suppliers = obj.suppliers
              // res.code = obj.code
              // res.msg = obj.msg
              // res.abtag = obj.abtag
              // res.reqid = obj.reqid
              // res.setting = obj.setting
              // res.server_reward = obj.server_reward
            } else {
              res.code = ADV_ERR_NET_UNSUPPORT_TYPE
              res.msg = `UnSupport data type: ${data.resultType}`
            }
          } else {
            res.code = data?.responseCode ?? ADV_ERR_NET_FAILED
            res.msg = "http 请求responseCode 非200， responseCode = " + data?.responseCode
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
            let inf = `请求发起阶段发生 exception ,err name:` + name + " , msg = " + msg
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
    let useHttps = AdvanceSetting.get().useHttps
    if (useHttps) {
      bUrl = baseUrlHttps
    }
  } catch (e) {
    BYLog.printE(e)
  }
  return bUrl
}
