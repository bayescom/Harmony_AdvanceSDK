import { AdvanceConstant } from '../define/AdvanceConstant'

@Sendable
export class AdvanceAdnStatusResult {
  adID: string = ''
  status: number = AdvanceConstant.ADV_ADN_STATUS_LOADING //1代表成功返回
  bidPrice: number = 0 //竞价价格
  errCode: string = '' //异常code
  errMsg: string = '' //异常msg
}