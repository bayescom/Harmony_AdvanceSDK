import AdvanceNet from './AdvanceRequest';
import bundleManager from '@ohos.bundle.bundleManager';

import { systemDateTime } from '@kit.BasicServicesKit';
import { BYLog } from '../../basic/BYLog';
import { BYDevice } from '../../basic/BYDevice';
import { BYUtil } from '../../basic/BYUtil';

import { BYStrUtil } from '../../basic/util/BYStrUtil';
import { BYSecurity } from '../../basic/BYSecurity';
import { BYSetting } from '../../basic/BYSetting';
import { AdvanceRequestOption } from '../config/AdvanceOption';
import { AdvanceDeviceModel, AdvanceReqModel, AdvanceStrategyResponse } from '../model/AdvanceNetModel';
import { AdvanceError, ADV_ERR_DATA_NULL, ADV_ERR_EXCEPTION_LOAD } from '../define/AdvanceError';
import { AdvanceConstant } from '../define/AdvanceConstant';
import { BYConstant } from '../../basic/BYConstant';
import { AdvanceSetting } from '../config/AdvanceSetting';

export class AdvanceRequestManger {
  static async prepareReqAdData(adConfig: AdvanceRequestOption): Promise<AdvanceReqModel> {
    let req: AdvanceReqModel = new AdvanceReqModel
    try {
      req.version = AdvanceConstant.ADV_API_VERSION_NAME
      req.sdk_version = AdvanceConstant.ADV_SDK_VERSION_NAME
      req.reqid = BYUtil.getReqID()
      req.time = systemDateTime.getTime(false) + ""
      let appid = AdvanceSetting.get().appId
      req.appid = appid
      req.adspotid = adConfig.codeId
      let bundleInfo =
        await bundleManager.getBundleInfoForSelf(bundleManager.BundleFlag.GET_BUNDLE_INFO_WITH_APPLICATION)
      req.appver = bundleInfo.versionName;
      req.device_encinfo = await AdvanceRequestManger.getEncryptedDeviceInf()

    } catch (e) {
      BYLog.printE(e)
    }
    // BYLog.debug()
    return req
  }

  //获取加密后的设备参数
  static async getEncryptedDeviceInf(): Promise<string> {
    let result = ""
    try {
      let savedDev = BYSetting.get().savedDeviceEncrypt
      //优先使用缓存值
      if (!BYStrUtil.isEmpty(savedDev) && !BYSetting.get().isDev) {
        BYLog.debug("使用缓存得设备信息：" + savedDev)
        return savedDev
      }
      let deviceInf = new AdvanceDeviceModel()
      deviceInf.osv = BYDevice.getOSV()

      deviceInf.network = BYDevice.getNetworkType()
      deviceInf.devicetype = BYDevice.getDeviceType()
      deviceInf.make = BYDevice.getDeviceMake()
      deviceInf.model = BYDevice.getDeviceModel()
      deviceInf.brand = BYDevice.getDeviceBrand()
      deviceInf.odid = BYDevice.getDeviceODID()

      deviceInf.operator = BYDevice.getOperator()

      // deviceInf.sw = BYDisplay.getScreenWPX()
      // deviceInf.sh = BYDisplay.getScreenHPX()
      // deviceInf.dpi = BYDisplay.getScreenDPI()
      // deviceInf.density = BYDisplay.getScreenDensity()
      // deviceInf.ppi = BYDisplay.getScreenPPI()

      //无接口获取imei
      deviceInf.imei = ''
      deviceInf.mac = await BYDevice.getMacAddress()
      deviceInf.aaid = await BYDevice.getAAid()

      //oaid获取
      await AdvanceRequestManger.prepareOAID(deviceInf)

      let deviceOri = JSON.stringify(deviceInf)
      BYLog.debug(`deviceOri = ${deviceOri}`)
      //加密
      result = await BYSecurity.encrypt(deviceOri)
      //存储
      if (!BYStrUtil.isEmpty(result)) {
        BYSetting.get().savedDeviceEncrypt = result
      }
    } catch (e) {
      BYLog.printE(e)
    }
    return result;
  }

  private static async prepareOAID(deviceInf: AdvanceDeviceModel) {
    try {
      let cusPrivacy = BYConstant.privacyController
      let customOAID: string | undefined = ''
      if (cusPrivacy) {
        customOAID = cusPrivacy.getCusOaid()
        //oaid不为空立即进行赋值
        if (customOAID && BYStrUtil.isNotEmpty(customOAID)) {
          BYLog.debug("使用app传递的oaid信息")

          deviceInf.oaid_support = 2
          deviceInf.oaid = customOAID;
        }
        if (!cusPrivacy.isCanUseAppTrackingConsent()) {
          //不允许SDK内执行获取，此时返回
          BYLog.debug("不允许SDK内执行oaid获取")
          return
        }
      }

      //当值为空时。才执行SDK获取oaid方法及逻辑
      if (BYStrUtil.isEmpty(deviceInf.oaid)) {
        let sdkOAID = await BYDevice.getOAID()
        //当SDK获取
        if (BYStrUtil.isNotEmpty(sdkOAID)) {
          deviceInf.oaid_support = 1
          deviceInf.oaid = sdkOAID
        }

      }
    } catch (e) {
      BYLog.printE(e)
    }
  }


  //获取聚合策略信息，无策略或者网络错误将回调失败
  static async requestStrategy(adConfig: AdvanceRequestOption,
    callBack?: (err?: AdvanceError, data?: AdvanceStrategyResponse) => void) {

    let hasResult = false
    try { //首先生成请求参数信息
      let reqObj = await AdvanceRequestManger.prepareReqAdData(adConfig)
      //获取广告返回信息
      let netResult: AdvanceStrategyResponse = await AdvanceNet.get().getStrategy(reqObj)
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
          err.msg = `接口请求状态码非200，server code：${netResult.code}  ，detail：${netResult.msg}`
          callBack(err, undefined);
        }
        return
      }
      //进一步判断imp内容是否为空
      if (netResult.suppliers == undefined || (netResult.suppliers.length > 0 && netResult.suppliers[0] == undefined)) {
        if (callBack != undefined) {
          let err = new AdvanceError()
          err.code = ADV_ERR_DATA_NULL
          err.msg = `策略信息为空`
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
          err.code = ADV_ERR_EXCEPTION_LOAD
          err.msg = '获取广告遇到异常'
          callBack(err, undefined);
        }
      }
    }
  }
}
