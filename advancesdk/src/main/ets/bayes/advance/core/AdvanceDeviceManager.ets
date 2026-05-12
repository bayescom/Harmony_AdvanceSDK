import { BYLog } from '../../basic/BYLog';
import identifier from '@ohos.identifier.oaid'
import { deviceInfo, systemDateTime } from '@kit.BasicServicesKit';
import { connection } from '@kit.NetworkKit';
import { data, radio, sim } from '@kit.TelephonyKit';
import AAID from '@hms.core.AAID';
import { BYPermissionUtil } from '../../basic/util/BYPermissionUtil';
import { BYPreferencesUtil } from '../../basic/cache/BYPreferencesUtil';
import { AdvanceDeviceModel } from '../model/AdvanceNetModel';
import { JSON } from '@kit.ArkTS';
import { BYSecurity } from '../../basic/BYSecurity';

const TAG: string = "AdvanceDeviceManager-"

export const CACHE_EXPIRE_TIME_MONTH = 30*24*60*60*1000 // 30天（毫秒）
export const CACHE_EXPIRE_TIME_HOUR = 60*60*1000 // 1小时（毫秒）

export const CACHE_INVARIABLE_DEVICE_KEY = 'CACHE_INVARIABLE_DEVICE_KEY'
export const CACHE_OAID_DATA_KEY = 'CACHE_OAID_DATA_KEY'
export const CACHE_OAID_Expired_KEY = 'CACHE_OAID_Expired_KEY'
export const CACHE_AAID_DATA_KEY = 'CACHE_AAID_DATA_KEY'
export const CACHE_AAID_Expired_KEY = 'CACHE_AAID_Expired_KEY'
export const CACHE_ODID_DATA_KEY = 'CACHE_ODID_DATA_KEY'
export const CACHE_ODID_Expired_KEY = 'CACHE_ODID_Expired_KEY'
export const CACHE_CARRIER_DATA_KEY = 'CACHE_CARRIER_DATA_KEY'
export const CACHE_CARRIER_Expired_KEY = 'CACHE_CARRIER_Expired_KEY'

export class AdvanceDeviceManager {

  // 设置不变的设备数据
  static getInvariableDeviceInfoString(): string {
    let deviceInfoString = BYPreferencesUtil.getStringSync(CACHE_INVARIABLE_DEVICE_KEY)
    if (!deviceInfoString) {
      let deviceInfo = new AdvanceDeviceModel()
      deviceInfo.os = 4
      deviceInfo.make = AdvanceDeviceManager.getDeviceMake()
      deviceInfo.model = AdvanceDeviceManager.getDeviceModel()
      deviceInfoString = JSON.stringify(deviceInfo)
      BYPreferencesUtil.put(CACHE_INVARIABLE_DEVICE_KEY, deviceInfoString)
    }
    return deviceInfoString
  }

  //获取加密后的设备参数
  static async getEncryptedDeviceInfo(): Promise<string> {
    let result = ""
    try {
      const deviceInfoString = AdvanceDeviceManager.getInvariableDeviceInfoString()
      let deviceInfo = JSON.parse(deviceInfoString) as AdvanceDeviceModel
      deviceInfo.osv = AdvanceDeviceManager.getOSV()
      deviceInfo.network = AdvanceDeviceManager.getNetworkType()
      deviceInfo.devicetype = AdvanceDeviceManager.getDeviceType()
      deviceInfo.carrier = AdvanceDeviceManager.getSimOperatorNumeric()
      // deviceInf.sw = BYDisplay.getScreenWPX()
      // deviceInf.sh = BYDisplay.getScreenHPX()
      // deviceInf.dpi = BYDisplay.getScreenDPI()
      // deviceInf.density = BYDisplay.getScreenDensity()
      // deviceInf.ppi = BYDisplay.getScreenPPI()
      // deviceInf.mac = await AdvanceDeviceManager.getMacAddress()
      deviceInfo.odid = AdvanceDeviceManager.getODID()
      deviceInfo.aaid = await AdvanceDeviceManager.getAAid()
      deviceInfo.oaid= await AdvanceDeviceManager.getOAID()

      let deviceOri = JSON.stringify(deviceInfo)
      BYLog.debug(`deviceOri = ${deviceOri}`)
      //加密
      result = await BYSecurity.encrypt(deviceOri)
      BYLog.debug(`deviceEncrypt = ${result}`)
    } catch (e) {
      BYLog.printE(e)
    }
    return result;
  }

  static async getOAID(): Promise<string> {
    // 每月更新缓存
    let oaid = BYPreferencesUtil.getStringSync(CACHE_OAID_DATA_KEY)
    let expiredTimestamp = BYPreferencesUtil.getNumberSync(CACHE_OAID_Expired_KEY)
    if (!oaid || systemDateTime.getTime() > expiredTimestamp) { // 更新缓存
      //首先检查权限
      let hasPerm = await BYPermissionUtil.checkPermissions('ohos.permission.APP_TRACKING_CONSENT');
      if (!hasPerm) {
        BYLog.warn(TAG + `getOAID failed ; no permission: ohos.permission.APP_TRACKING_CONSENT`);
        return oaid;
      }
      //缓存过期时间戳
      let timestamp = systemDateTime.getTime() + CACHE_EXPIRE_TIME_MONTH
      BYPreferencesUtil.putSync(CACHE_OAID_Expired_KEY, timestamp)
      //缓存oaid
      oaid = await identifier.getOAID()
      BYPreferencesUtil.putSync(CACHE_OAID_DATA_KEY, oaid)
    }
    return oaid
  }

  static async getAAid(): Promise<string> {
    // 每月更新缓存
    let aaid = BYPreferencesUtil.getStringSync(CACHE_AAID_DATA_KEY)
    let expiredTimestamp = BYPreferencesUtil.getNumberSync(CACHE_AAID_Expired_KEY)
    if (!aaid || systemDateTime.getTime() > expiredTimestamp) { // 更新缓存
      //缓存过期时间戳
      let timestamp = systemDateTime.getTime() + CACHE_EXPIRE_TIME_MONTH
      BYPreferencesUtil.putSync(CACHE_AAID_Expired_KEY, timestamp)
      //缓存aaid
      aaid = await AAID.getAAID()
      BYPreferencesUtil.putSync(CACHE_AAID_DATA_KEY, aaid)
    }
    return aaid
  }

  static getODID(): string {
    // 每月更新缓存
    let odid = BYPreferencesUtil.getStringSync(CACHE_ODID_DATA_KEY)
    let expiredTimestamp = BYPreferencesUtil.getNumberSync(CACHE_ODID_Expired_KEY)
    if (!odid || systemDateTime.getTime() > expiredTimestamp) { // 更新缓存
      //缓存过期时间戳
      let timestamp = systemDateTime.getTime() + CACHE_EXPIRE_TIME_MONTH
      BYPreferencesUtil.putSync(CACHE_ODID_Expired_KEY, timestamp)
      //缓存odid
      odid = deviceInfo.ODID
      BYPreferencesUtil.putSync(CACHE_ODID_DATA_KEY, odid)
    }
    return odid
  }

  /**
   * 获取指定卡槽SIM卡的归属PLMN（Public Land Mobile Network）号。
   * @param slotId 卡槽ID（0-卡槽1、1-卡槽2）。 默认移动数据的SIM卡。
   * @returns
   */
  static getSimOperatorNumeric(): string {
    // 每小时更新缓存
    let carrier = BYPreferencesUtil.getStringSync(CACHE_CARRIER_DATA_KEY)
    let expiredTimestamp = BYPreferencesUtil.getNumberSync(CACHE_CARRIER_Expired_KEY)
    if (!carrier || systemDateTime.getTime() > expiredTimestamp) { // 更新缓存
      //缓存过期时间戳
      let timestamp = systemDateTime.getTime() + CACHE_EXPIRE_TIME_HOUR
      BYPreferencesUtil.putSync(CACHE_CARRIER_Expired_KEY, timestamp)
      //缓存carrier
      let slotId = data.getDefaultCellularDataSlotIdSync(); //默认移动数据的SIM卡
      carrier = sim.getSimOperatorNumericSync(slotId)
      BYPreferencesUtil.putSync(CACHE_CARRIER_DATA_KEY, carrier)
    }
    return carrier
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


  // 需要权限： ohos.permission.GET_WIFI_INFO 。
  //
  // 当macType是1 - 设备MAC地址时，获取 macAddress 还需申请ohos.permission.GET_WIFI_LOCAL_MAC权限（该权限仅系统应用可申请），无该权限时，macAddress 返回空字符串。
  //
  //获取网卡mac地址（基本macType是0，获取到的是随机mac地址）
  // static async getMacAddress(): Promise<string> {
  //   let result: string = ""
  //   try {
  //     let cusPrivacy = BYConstant.privacyController
  //     let customMac: string = ''
  //     if (cusPrivacy) {
  //       customMac = cusPrivacy.getMacAddress() ?? ""
  //
  //       if (!cusPrivacy.isCanUseWifiState()) {
  //         if (BYStrUtil.isNotEmpty(customMac)) {
  //           BYLog.debug(TAG + "使用app传递的mac信息")
  //           return customMac
  //         }
  //       }
  //     }
  //
  //
  //     let hasNetPer: boolean = await BYPermissionUtil.checkPermissions('ohos.permission.GET_WIFI_INFO')
  //     if (!hasNetPer) {
  //       BYLog.debug(TAG + "无【GET_WIFI_INFO】权限，使用app传递的mac信息")
  //       return customMac;
  //     }
  //     let linkInf = await wifiManager.getLinkedInfo()
  //     result = linkInf.macAddress
  //     BYLog.debug(TAG + "使用SDK获取到的mac信息")
  //   } catch (e) {
  //     BYLog.printE(e)
  //   }
  //   return result
  // }

}