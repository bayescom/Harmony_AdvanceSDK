import { AdvanceConstant } from '../define/AdvanceConstant'
import { AdvanceError } from '../define/AdvanceError'

@Sendable
export class AdvanceAdnResult {
  adID: string = ''
  resultStatus: number = AdvanceConstant.ADV_ADN_RESULT_LOADING //1代表成功返回
  bidPrice: number = 0 //竞价价格
  errCode: string = '' //异常code
  errMsg: string = '' //异常msg
}