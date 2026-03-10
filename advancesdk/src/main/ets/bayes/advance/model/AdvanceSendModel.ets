import { AdvanceAdLoadState } from '../../../../../../Index'

@Sendable
export class AdvanceAdnStatusResult {
  adID: string = ''
  status: number = AdvanceAdLoadState.loading
  bidPrice: number = 0 //竞价价格
  errCode: string | number = '' //异常code
  errMsg: string = '' //异常msg
}

export class AdvanceAdnInitResult{
  success: boolean = false
  code: string | number  = ''
  msg: string = ''
}