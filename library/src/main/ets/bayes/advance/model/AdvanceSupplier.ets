//对外暴露的渠道信息
export class AdvanceSupplier {
  adnID: string = ""
  adnName: string = ""
  appID: string = ""
  // appKey: string = ""
  adSlotID: string = ""
  biddingType: number = 0 // 0代表非bidding， 1 客户端bidding，2 服务端bidding（预留）
  price: number = 0
}