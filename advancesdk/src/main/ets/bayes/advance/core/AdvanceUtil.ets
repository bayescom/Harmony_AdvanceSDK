import { BYStrUtil } from '../../basic/util/BYStrUtil';
import { systemDateTime } from '@kit.BasicServicesKit';
import { AdvanceSupplierModel } from '../model/AdvanceNetModel';
import { AdvanceAdInfo } from '../model/AdvanceAdInfo';
import { AdvanceError } from '../define/AdvanceError';
import { AdvanceAdnReportTKEventType } from '../define/AdvanceDefine';

export class AdvanceUtil {
  static getAdvanceAdInfo(supplier: AdvanceSupplierModel): AdvanceAdInfo {
    let result = new AdvanceAdInfo()
    if (supplier) {
      result.adnID = supplier.id
      result.adnName = supplier.name
      result.appID = supplier.mediaid
      result.adSlotID = supplier.adspotid
      result.biddingType = supplier.is_head_bidding
      result.price = supplier.sdk_price
    }
    return result
  }

  // tk上报拼接参数
  static joinUrlParameters(url: string, eventType: AdvanceAdnReportTKEventType, price: number,
    loadTimeStamp: number, cacheReqId?: string, error?: AdvanceError): string {
    // replace timestamp
    let currentTimeStamp = systemDateTime.getTime()
    url = BYStrUtil.replaceAll(url, "__TIME__", `${currentTimeStamp}`)
    /// append is_cahced & cached_reqid
    if (BYStrUtil.isNotEmpty(cacheReqId)) {
      url += `&is_cahced=1&cached_reqid=${cacheReqId}`
    }
    let costTime = currentTimeStamp - loadTimeStamp
    switch (eventType) {
      case AdvanceAdnReportTKEventType.loaded:
        // 拼接SDK启动耗时
        url += `&t_msg=l_${costTime}`
        break
      case AdvanceAdnReportTKEventType.succeed:
        // 拼接竞价
        if (price) {
          url += `&bidResult=${price}`
        }
        break
      case AdvanceAdnReportTKEventType.exposed:
      case AdvanceAdnReportTKEventType.bidWin:
        // 拼接广告曝光/竞价成功耗时
        url += `&t_msg=tt_${costTime}`
        // 拼接竞价
        if (price) {
          url += `&bidResult=${price}`
        }
        break
      case AdvanceAdnReportTKEventType.failed:
        // 拼接错误码
        if (error) {
          url += `&t_msg=err_${error.code}`
        }
        break
      default:
        break
    }
    return url
  }
}