import { AdvanceADNUnitData } from './AdvanceADNUnitData';

//并行组信息类
export class AdvanceParaGroup {
  //并行组唯一id
  groupID: number = 0;
  //并行的组成员(包含bidding成员)
  paraMembers: AdvanceADNUnitData[] = []
  //有广告返回的 最优渠道，一般是比价后胜出的那一个渠道、如果未包含比较渠道，则是价格最高的渠道
  bestADN?: AdvanceADNUnitData
  maxPrice: number = 0; //组内最高价格
  minPrice: number = 0; //组内最低价格

  //是否包含bidding广告位的组
  isBiddingGroup: boolean = false;
  //是否所有bidding已有返回结果
  isBiddingAllResult: boolean = false;
  //组内成员已经全部返回
  isGroupAllResult: boolean = false;
  //是否当前层级已经请求超时
  isTimeOut: boolean = false;
}