import http from '@ohos.net.http';
import { BYLog } from '../../basic/BYLog';
import { AdvCustomAdnListInfo } from '../cache/AdvCustomAdnCacheManager';
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
    const result = await sendRequest(reqUrl, http.RequestMethod.POST, body, http.HttpDataType.OBJECT, true)
    const model = result.data as AdvanceStrategyModel
    return model
  }

  // 普通的上报请求，get方式
  async reportUrl(oriUrl: string): Promise<boolean> {
    const result = await sendRequest(oriUrl, http.RequestMethod.GET)
    return result.code === 200
  }

  // 服务端激励验证
  async verifyServerSideRewardedURL(oriUrl: string, parameters: Record<string, string | number>): Promise<ESObject> {
    const result = await sendRequest(oriUrl, http.RequestMethod.POST, parameters, http.HttpDataType.OBJECT, true)
    return result.data as ESObject
  }

  // 获取自定义AdnList信息
  async getCustomAdnListInfo(version?: string): Promise<AdvCustomAdnListInfo> {
    const reqUrl = `${getBaseUrl()}custom_adn`
    const parameters: Record<string, string | number> = {"appid": AdvanceSetting.get().appId, "version": version ?? ""}
    const result = await sendRequest(reqUrl, http.RequestMethod.GET, parameters, http.HttpDataType.OBJECT)
    const info = result.data as AdvCustomAdnListInfo
    return info
  }

}

// 基础响应结构
export class BaseResponse {
  code: number = -1;
  msg: string = '';
  data: Object | undefined = undefined;
}

/**
 * 通用网络请求方法
 * @param url 请求地址
 * @param method 请求方法
 * @param expectDataType 返回数据类型
 * @param extraData 请求体
 * @param forceTimeout 超时
 * @returns 通用 BaseResponse 对象
 */
async function sendRequest(
  url: string,
  method: http.RequestMethod,
  extraData?: string | Object | ArrayBuffer,
  expectDataType: http.HttpDataType = http.HttpDataType.STRING,
  forceTimeout: boolean = false
): Promise<BaseResponse> {
  return new Promise<BaseResponse>((resolve) => {
    let res = new BaseResponse(); // 🌟 实例化通用响应对象
    let hasResult = false;
    let httpRequest: http.HttpRequest | null = null;

    try {
      if (forceTimeout) {
        let tim = setTimeout(() => {
          try {
            if (hasResult) {
              BYLog.debug(TAG + `接口已返回，不再校验超时`)
              clearTimeout(tim)
              return
            }
            BYLog.warn(TAG + 'sendRequest timeout')
            hasResult = true;
            res.code = ADV_ERR_NET_TIME_OUT;
            res.msg = `策略请求超时未响应`;
            resolve(res);
            clearTimeout(tim);
            if (httpRequest) {
              httpRequest.destroy(); // 超时了就销毁请求，防止后续重复触发
            }
          } catch (e) {
            BYLog.printE(e)
          }
        }, 5000)
      }

      if (method === http.RequestMethod.POST && !extraData) {
        extraData = new Object();
      }

      httpRequest = http.createHttp();
      BYLog.debug(TAG + `start request, url: ${url}, method: ${method}`);

      let reqOption: http.HttpRequestOptions = {
        method: method,
        expectDataType: expectDataType,
        extraData: extraData,
        readTimeout: 10000, // 增加原生超时防御，防止 500 时挂死
        connectTimeout: 10000
      };

      httpRequest.request(url, reqOption, (err, data) => {
        try {
          if (hasResult) return; // 如果已经走了解析阶段或超时阶段，直接拦截

          // 防崩核心 1：异常拦截，不需要单独 resolve，靠下面的 finally 收尾
          if (err) {
            res.code = err.code;
            let errMsg = err?.message ?? "";
            res.msg = `接口响应失败：` + errMsg;
            BYLog.error(TAG + errMsg);
            // resolve(res);
            return;
          }

          // 防崩核心 2：全面兜底 data 为空
          if (!data) {
            res.code = ADV_ERR_NET_FAILED;
            res.msg = "Http 请求返回的 data 对象为空";
            // resolve(res);
            return;
          }

          // 防崩核心 3：非 200 拦截
          if (data.responseCode !== 200) {
            res.msg = "http 请求responseCode 非200， responseCode = " + data.responseCode;
            BYLog.error(TAG + `request error, url: ${url}`);
            // resolve(res);
            return;
          }

          // ===== 以下为 200 成功数据解析 =====
          BYLog.debug(TAG + `request success`);
          if (method == http.RequestMethod.POST) {
            BYLog.debug(TAG + `request success, url: ${url}, result: ${JSON.stringify(data.result)}`);
          }

          res.code = data.responseCode;
          if (data.resultType === http.HttpDataType.STRING) {
            res.msg = data.result as string;
          } else if (data.resultType === http.HttpDataType.OBJECT) {
            // 🌟 如果已经是 OBJECT 类型，直接赋值给普通的数据载体 data
            res.data = data.result as Object;
            res.msg = "获取 Object 成功";
          } else {
            res.code = ADV_ERR_NET_UNSUPPORT_TYPE;
            res.msg = `UnSupport data type: ${data.resultType}`;
          }

        } catch (e) {
          BYLog.printE(e);
          res.code = ADV_ERR_NET_EXCEPTION;
          res.msg = `请求解析阶段发生 exception: ${e?.message ?? ''}`;
        } finally {
          //debugger // ？？？断点调试时开启，否则断点进不来
          BYLog.debug(TAG + 'request enter finally')
          hasResult = true;
          if (httpRequest) {
            httpRequest.destroy();
          }
          resolve(res);
        }
      });
    } catch (e) {
      res.code = ADV_ERR_NET_EXCEPTION;
      res.msg = `请求发起阶段发生 exception: ${e?.message ?? ''}`;
      hasResult = true;
      if (httpRequest) {
        httpRequest.destroy();
      }
      resolve(res);
    }
  });
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
