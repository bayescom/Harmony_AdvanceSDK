import AdvanceNetwork from './AdvanceNetwork';
import bundleManager from '@ohos.bundle.bundleManager';
import { systemDateTime } from '@kit.BasicServicesKit';
import { BYLog } from '../../basic/BYLog';
import { AdvanceDeviceManager } from '../core/AdvanceDeviceManager';
import { BYUtil } from '../../basic/BYUtil';
import { AdvanceAdLoadConfig } from '../config/AdvanceAdConfig';
import { AdvanceReqModel, AdvanceStrategyModel } from '../model/AdvanceNetModel';
import { AdvanceError,
  ADV_ERR_DATA_NO_SUPPLIER,
  ADV_ERR_DATA_NULL, ADV_ERR_NET_EXCEPTION } from '../define/AdvanceError';
import { AdvanceConstant } from '../define/AdvanceConstant';
import { AdvanceSetting } from '../config/AdvanceSetting';
import { AdvanceADNManager } from '../core/adn/AdvanceADNManager';

export class AdvanceRequestManager {
  static async prepareRequestAdData(adConfig: AdvanceAdLoadConfig): Promise<AdvanceReqModel> {
    let req: AdvanceReqModel = new AdvanceReqModel
    try {
      req.version = AdvanceConstant.ADV_API_VERSION_NAME
      req.sdk_version = AdvanceConstant.ADV_SDK_VERSION_NAME
      req.reqid = adConfig.reqId ?? BYUtil.getReqID()
      req.time = `${systemDateTime.getTime()}`
      req.appid = AdvanceSetting.get().appId
      req.adspotid = adConfig.placementId
      const bundleInfo =
        await bundleManager.getBundleInfoForSelf(bundleManager.BundleFlag.GET_BUNDLE_INFO_WITH_APPLICATION)
      req.appver = bundleInfo.versionName;
      req.ext = await AdvanceRequestManager.addSDKVersion()
      req.device_encinfo = await AdvanceDeviceManager.getEncryptedDeviceInfo()

    } catch (e) {
      BYLog.printE(e)
    }
    return req
  }

  //添加各ADN版本号
  static async addSDKVersion(): Promise<Record<string, string>> {
    let extra: Record<string, string> = {}
    //添加CSJ版本号
    const csj_v = await AdvanceADNManager.getSDKVersion(AdvanceConstant.ADV_SDK_ID_CSJ)
    if (csj_v) {
      extra['csj_v'] = csj_v
    }
    //添加GDT版本号
    const gdt_v = await AdvanceADNManager.getSDKVersion(AdvanceConstant.ADV_SDK_ID_GDT)
    if (gdt_v) {
      extra['gdt_v'] = gdt_v
    }
    //添加Mercury版本号
    const mry_v = await AdvanceADNManager.getSDKVersion(AdvanceConstant.ADV_SDK_ID_MERCURY)
    if (mry_v) {
      extra['mry_v'] = mry_v
    }
    //添加KS版本号
    const ks_v = await AdvanceADNManager.getSDKVersion(AdvanceConstant.ADV_SDK_ID_KS)
    if (ks_v) {
      extra['ks_v'] = ks_v
    }
    return extra
  }

  //获取聚合策略信息，无策略或者网络错误将回调失败
  static async requestAdStrategy(adConfig: AdvanceAdLoadConfig,
    callBack?: (err?: AdvanceError, data?: AdvanceStrategyModel) => void) {

    let hasResult = false
    try { //首先生成请求参数信息
      let reqObj = await AdvanceRequestManager.prepareRequestAdData(adConfig)
      //获取广告返回信息
      let netResult: AdvanceStrategyModel = await AdvanceNetwork.shared().getStrategy(reqObj)
      if (!netResult) {
        if (callBack != undefined) {
          let advErr = new AdvanceError()
          advErr.code = ADV_ERR_DATA_NULL
          advErr.msg = '策略信息为空'
          callBack(advErr, undefined);
        }
        return
      }
      //首先确保返回状态码为200，非200有两种可能，1是http请求状态为非200，2是广告服务器返回状态码为非200；任一一个非200均代表了广告失败
      if (netResult.code != 200) {
        //非200返回进行错误回调
        if (callBack != undefined) {
          let err = new AdvanceError()
          err.code = ADV_ERR_DATA_NULL
          err.msg = `接口请求状态码非200，【server code：${netResult.code}，msg：${netResult.msg}】`
          callBack(err, undefined);
        }
        return
      }
      //进一步判断imp内容是否为空
      if (netResult.suppliers == undefined || (netResult.suppliers.length > 0 && netResult.suppliers[0] == undefined)) {
        if (callBack != undefined) {
          let err = new AdvanceError()
          err.code = ADV_ERR_DATA_NO_SUPPLIER
          err.msg = `策略中未配置渠道，请联系相关运营人员配置`
          callBack(err, undefined);
        }
        return
      }
      //回调策略完整model信息给外部
      hasResult = true
      if (callBack != undefined) {
        callBack(undefined, netResult);
      }
    } catch (e) {
      BYLog.printE(e)
      if (!hasResult) {
        if (callBack != undefined) {
          let err = new AdvanceError()
          err.code = ADV_ERR_NET_EXCEPTION
          err.msg = '获取广告遇到异常'
          callBack(err, undefined);
        }
      }
    }
  }
}
