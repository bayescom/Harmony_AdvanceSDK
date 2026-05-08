//对外暴露的渠道信息
export class AdvanceAdInfo {
  adnID: string = ""
  adnName: string = ""
  appID: string = ""
  adSlotID: string = ""
  biddingType: number = 0 // 0 非bidding， 1 客户端bidding
  price: number = 0
  fromCache: boolean = false
}