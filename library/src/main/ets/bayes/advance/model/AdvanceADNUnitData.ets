import { AdvanceSupplierModel } from './AdvanceNetModel'

//聚合adn侧使用的
export class AdvanceADNUnitData {
  adType:number = 0 //广告位类型，默认0 未知， 1开屏、2 信息流
  //adn渠道策略信息
  supplier?: AdvanceSupplierModel
  //补充内容
  ext?: AdvanceSupplierExt

}


//一些渠道上运行需要信息补充
export class AdvanceSupplierExt{

}