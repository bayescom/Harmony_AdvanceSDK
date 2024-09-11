import { AdvanceSupplierModel } from './AdvanceNetModel'

//聚合adn侧使用的
export class AdvanceADNUnitData {
  //adn渠道策略信息
  supplier?: AdvanceSupplierModel
  //补充内容
  ext?: AdvanceSupplierExt
}


//一些渠道上运行需要信息补充
export class AdvanceSupplierExt{

}