import { BYLog } from './BYLog';
import identifier from '@ohos.identifier.oaid'
import { resourceManager } from '@kit.LocalizationKit';
import { deviceInfo, systemDateTime } from '@kit.BasicServicesKit';
import { connection } from '@kit.NetworkKit';
import { radio } from '@kit.TelephonyKit';
import { BYStrUtil } from './util/BYStrUtil';
import { BYSingleton } from './BYSingleton';

import { fileIo as fs, ReadOptions } from '@kit.CoreFileKit';
import { buffer } from '@kit.ArkTS';
import AAID from '@hms.core.AAID';
import { BYPermissionUtil } from './util/BYPermissionUtil';
import wifiManager from '@ohos.wifiManager';
import { BYSetting } from './BYSetting';
import BYConstant, { BY_CACHE_KEY_AAID, BY_CACHE_KEY_OAID, BY_CACHE_KEY_ODID, BY_CACHE_KEY_UA } from './BYConstant';
import { BYCacheResult, BYCacheUtil, CACHE_TIME_MONTH } from './util/BYCacheUtil';

const TAG: string = "BYDevice---"

export class BYDevice {
  //   二级缓存实现
  static getUA(): string {
    let result = ''
    try {
      //优先取单例中ua
      let insUA = BYSetting.get().savedUA
      if (BYStrUtil.isNotEmpty(insUA)) {
        BYLog.devDebug(TAG + ' getUA - 使用单例存储值')
        return insUA
      }
      //取本地缓存值
      let saved = BYCacheUtil.get<string>(BY_CACHE_KEY_UA)
      result = saved?.cacheValue ?? ''
    } catch (e) {
      BYLog.printE(e)
    }
    return result
  }

  /**
   * 当过期或者无ua信息时，需要更新
   * @returns
   */
  static needUAUpdate(): boolean {
    let result = false
    try {
      let saved = BYCacheUtil.get<string>(BY_CACHE_KEY_UA, CACHE_TIME_MONTH)
      //未获取到缓存值，或者缓存值为空，或者需要刷新
      if (saved == undefined || saved.needRefresh || BYStrUtil.isEmpty(saved.cacheValue)) {
        result = true
      }
    } catch (e) {
      BYLog.printE(e)
    }
    return result
  }


  //   二级缓存实现
  static async getOAID(): Promise<string> {
    try {
      let savedOAID: string = BYSetting.get().savedOAID
      if (BYStrUtil.isNotEmpty(savedOAID)) {
        BYLog.devDebug(TAG + ' getOAID - 使用单例存储值')
        return savedOAID
      }

      //oaid 失效期内可用直接返回
      let cacheV: BYCacheResult<string> = BYCacheUtil.get(BY_CACHE_KEY_OAID, CACHE_TIME_MONTH)
      if (!cacheV.needRefresh && cacheV.cacheValue && BYStrUtil.isNotEmpty(cacheV.cacheValue)) {
        BYLog.devDebug(TAG + ' getOAID - 使用本地存储值')
        return cacheV.cacheValue
      }

      //首先检查权限
      let hasPerm = await BYPermissionUtil.checkPermissions('ohos.permission.APP_TRACKING_CONSENT');
      if (!hasPerm) {
        BYLog.warn(TAG + `getOAID failed ; no permission: ohos.permission.APP_TRACKING_CONSENT`);
        return '';
      }
      // let c6 = await systemDateTime.getCurrentTime();
      let start = systemDateTime.getTime(false);
      let oaid = await identifier.getOAID()
      let cost = systemDateTime.getTime(false) - start
      BYLog.debug(TAG + `getOAID result : ${oaid} , cost : ${cost}`)
      if (BYStrUtil.isNotEmpty(oaid)) {
        BYSetting.get().savedOAID = oaid
        BYCacheUtil.save(BY_CACHE_KEY_OAID, oaid)
      }
      return oaid
    } catch (e) {
      BYLog.printE(e)
    }
    return ''
  }

  //   本地缓存
  static async getAAid(): Promise<string> {
    let result = '';
    try {
      result = BYSetting.get().savedAAID
      if (!BYStrUtil.isEmpty(result)) {
        return result
      }

      let cacheV: BYCacheResult<string> = BYCacheUtil.get(BY_CACHE_KEY_AAID, CACHE_TIME_MONTH)
      if (!cacheV.needRefresh && cacheV.cacheValue && BYStrUtil.isNotEmpty(cacheV.cacheValue)) {
        return cacheV.cacheValue
      }

      let v5 = systemDateTime.getTime();
      result = await AAID.getAAID();
      let w5 = systemDateTime.getTime();
      let x5 = w5 - v5;
      BYSetting.get().savedAAID = result
      BYCacheUtil.save(BY_CACHE_KEY_AAID, result)

      BYLog.debug(TAG + ` get aaid: ${result}, cost time: ${x5}`);
    } catch (e) {
      BYLog.printE(e)
    }
    return result;
  }

  static getOperator(): number {
    let result = 0
    try {
      let operName: string = BYDevice.getOperatorName()
      if (BYStrUtil.isEmpty(operName)) {
        result = 99
      }
      switch (operName) {
        case '中国移动':
          result = 1
        case '中国联通':
          result = 2
        case '中国电信':
          result = 3
      }
    } catch (e) {
      BYLog.printE(e)
    }

    return result
  }

  private static getOperatorName(): string {
    let result = ''

    try {
      //获取运营商名称、例如：中国移动。
      result = radio.getOperatorNameSync(0)

      //卡1为空 尝试卡2
      if (BYStrUtil.isEmpty(result)) {
        result = radio.getOperatorNameSync(1)
      }
    } catch (e) {
      BYLog.printE(e)
    }
    return result

  }

  // 网络连接类型, 0:未识别, 1:WIFI, 2:2G, 3:3G, 4:4G, 5:5G, 6:以太网, 7:蜂窝-未识别.
  static getNetworkType(): number {
    let result = 0;

    try {
      let netHandle = connection.getDefaultNetSync();
      let netCapabilities = connection.getNetCapabilitiesSync(netHandle);
      //根据数组中的情况判断网络类型
      if (netCapabilities.bearerTypes.includes(connection.NetBearType.BEARER_CELLULAR)) {
        // return '蜂窝网络'

        //先默认为 蜂窝-未识别.
        result = 7

        let signalType: radio.NetworkType = radio.NetworkType.NETWORK_TYPE_UNKNOWN
        try {
          //卡槽1
          let signalInfo1: Array<radio.SignalInformation> = radio.getSignalInformationSync(0);

          if (signalInfo1.length > 0) {
            signalType = signalInfo1[0].signalType
          }
          //卡槽2
          let signalInfo2: Array<radio.SignalInformation> = radio.getSignalInformationSync(1);
          if (signalType == radio.NetworkType.NETWORK_TYPE_UNKNOWN && signalInfo2.length > 0) {
            signalType = signalInfo2[0].signalType
          }

          BYLog.debug(TAG +
            `[getNetworkType] signal information signalInfo1 size is:${signalInfo1.length}  , signalInfo2 size is:${signalInfo2.length}`);

        } catch (e) {
          BYLog.printE(e)
        }

        BYLog.debug(TAG + `[getNetworkType] signalType:${signalType}  `);

        // GSM：2G
        // CDMA：电信2G
        // WCDMA：3G
        // TDSCDMA：3G
        // LTE：4G
        // NR：5G
        if (signalType == radio.NetworkType.NETWORK_TYPE_GSM || signalType == radio.NetworkType.NETWORK_TYPE_CDMA) {
          result = 2
        } else if (signalType == radio.NetworkType.NETWORK_TYPE_WCDMA ||
          signalType == radio.NetworkType.NETWORK_TYPE_TDSCDMA) {
          result = 3
        } else if (signalType == radio.NetworkType.NETWORK_TYPE_LTE) {
          result = 4
        } else if (signalType == radio.NetworkType.NETWORK_TYPE_NR) {
          result = 5
        }

      } else if (netCapabilities.bearerTypes.includes(connection.NetBearType.BEARER_WIFI)) {
        // return 'Wi-Fi网络'
        result = 1
      } else if (netCapabilities.bearerTypes.includes(connection.NetBearType.BEARER_ETHERNET)) {
        // return '以太网网络'
        result = 6
      } else {
        // return '无网络'
      }
    } catch (e) {
      BYLog.printE(e)
    }
    return result
  }

  // 设备类型, 0:未识别,1:手机,2:平板,3:机顶盒 ， phone、tablet
  static getDeviceType(): number {
    let type = 0;
    try {
      let deviceT = deviceInfo.deviceType
      if (deviceT === "phone" || deviceT === "phones") {
        type = 1
      } else if (deviceT === "tablet") {
        type = 2
      }
    } catch (e) {
      BYLog.printE(e)
    }
    return type;
  }

  // 设备品牌，HUAWEI
  static getDeviceBrand(): string {
    let result: string = ""
    try {
      result = deviceInfo.brand
    } catch (e) {
      BYLog.printE(e)
    }
    return result
  }

  // 设备型号, ALN-AL80
  static getDeviceModel(): string {
    let result: string = ""
    try {
      result = deviceInfo.productModel
    } catch (e) {
      BYLog.printE(e)
    }
    return result
  }

  // 制造商 HUAWEI
  static getDeviceMake(): string {
    let result: string = ""
    try {
      result = deviceInfo.manufacture
    } catch (e) {
      BYLog.printE(e)
    }
    return result
  }

  // 获取操作系统版本，5.0.0.60
  static getOSV(): string {
    let result: string = ""
    try {
      result =
        `${deviceInfo.majorVersion}.${deviceInfo.seniorVersion}.${deviceInfo.featureVersion}.${deviceInfo.buildVersion}`
    } catch (e) {
      BYLog.printE(e)
    }
    return result
  }

  // 类似AndroidID作用, 64a2face-c129-e3fc-abfe-171f1da096d2
  static getDeviceODID(): string {
    let result: string = ""
    try {
      result = BYSetting.get().savedODID
      if (!BYStrUtil.isEmpty(result)) {
        return result
      }

      let cacheV: BYCacheResult<string> = BYCacheUtil.get(BY_CACHE_KEY_ODID, CACHE_TIME_MONTH)
      if (!cacheV.needRefresh && cacheV.cacheValue && BYStrUtil.isNotEmpty(cacheV.cacheValue)) {
        return cacheV.cacheValue
      }

      result = deviceInfo.ODID
      BYSetting.get().savedODID = result
      BYCacheUtil.save(BY_CACHE_KEY_ODID, result)
    } catch (e) {
      BYLog.printE(e)
    }
    return result
  }

  //获取设备名称，比如 ：HUAWEI Mate 60 Pro
  static getDeviceName(): string {
    let result: string = ""
    try {
      result = deviceInfo.marketName
    } catch (e) {
      BYLog.printE(e)
    }
    return result
  }

  // todo 本地缓存
  // 获取WLAN连接信息，使用Promise异步回调。
  //
  // 需要权限： ohos.permission.GET_WIFI_INFO 。
  //
  // 当macType是1 - 设备MAC地址时，获取 macAddress 还需申请ohos.permission.GET_WIFI_LOCAL_MAC权限（该权限仅系统应用可申请），无该权限时，macAddress 返回空字符串。
  //
  //获取网卡mac地址（基本macType是0，获取到的是随机mac地址）
  static async getMacAddress(): Promise<string> {
    let result: string = ""
    try {
      let cusPrivacy = BYConstant.privacyController
      let customMac: string = ''
      if (cusPrivacy) {
        customMac = cusPrivacy.getMacAddress() ?? ""

        if (!cusPrivacy.isCanUseWifiState()) {
          if (BYStrUtil.isNotEmpty(customMac)) {
            BYLog.debug(TAG + "使用app传递的mac信息")
            return customMac
          }
        }
      }


      let hasNetPer: boolean = await BYPermissionUtil.checkPermissions('ohos.permission.GET_WIFI_INFO')
      if (!hasNetPer) {
        BYLog.debug(TAG + "无【GET_WIFI_INFO】权限，使用app传递的mac信息")
        return customMac;
      }
      let linkInf = await wifiManager.getLinkedInfo()
      result = linkInf.macAddress
      BYLog.devDebug(TAG + "使用SDK获取到的mac信息")
    } catch (e) {
      BYLog.printE(e)
    }
    return result
  }


  //无对应目录和文件，无法获取到
  static getBootId(): string {
    let result: string = ""

    try {
      // 打开文件
      let file = fs.openSync('/proc/sys/kernel/random/boot_id', fs.OpenMode.READ_WRITE);
      // 从文件读取一段内容
      let arrayBuffer = new ArrayBuffer(1024);
      let readOptions: ReadOptions = {
        offset: 0,
        length: arrayBuffer.byteLength
      };
      let readLen = fs.readSync(file.fd, arrayBuffer, readOptions);
      let buf = buffer.from(arrayBuffer, 0, readLen);
      result = buf.toString()
      BYLog.debug("getBootId result: " + result)

    } catch (e) {
      BYLog.printE(e)

    }
    return result

  }


  /**
   * 获取设备的Configuration
   * @returns
   */
  static getConfiguration(): Promise<resourceManager.Configuration> {
    return getContext().resourceManager.getConfiguration();
  }

  /**
   * 获取设备的Configuration
   * @returns
   */
  static getConfigurationSync(): resourceManager.Configuration {
    return getContext().resourceManager.getConfigurationSync();
  }

  /**
   * 获取当前设备屏幕方向。
   * resourceManager.Direction:
   *   DIRECTION_VERTICAL 0 竖屏。
   *   DIRECTION_HORIZONTAL 1 横屏。
   * @returns
   */
  static getDirection(): Number {
    return BYDevice.getConfigurationSync().direction
  }


  /**
   * 设备当前是否以竖屏方式显示（竖屏）
   */
  static isPortrait(): Boolean {
    let direction = BYDevice.getDirection();
    return direction == resourceManager.Direction.DIRECTION_VERTICAL;
  }

  /**
   * 设备当前是否以横屏方式显示（横屏）
   */
  static isLandscape(): Boolean {
    let direction = BYDevice.getDirection();
    return direction == resourceManager.Direction.DIRECTION_HORIZONTAL;
  }
}