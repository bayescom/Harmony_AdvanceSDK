import { AdvanceError } from './AdvanceError'

@Sendable
export class AdvanceAdnResult {
  adID: string = ''
  resultStatus: number = -1 //1代表成功返回
  bidPrice: number = 0 //竞价价格
  errCode: string = '' //异常code
  errMsg: string = '' //异常msg
}