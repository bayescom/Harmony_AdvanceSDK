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

export interface AdvRewardVideoModel {
  //app user Identifier
  userId?: string
  //optional. serialized string.
  extra?: string
  //reward name.
  rewardName?: string
  //number of rewards
  rewardAmount?: number
}

export interface AdvRewardCallbackInfo {
  sourceId: string // SDK渠道Id
  rewardName: string // 激励名称
  rewardAmount: number // 激励数量
}