import { AdvanceAdType } from '../../define/AdvanceDefine'
import { AdvanceSupplierModel } from '../../model/AdvanceNetModel'

// 传递给adapter内的参数信息
export class AdvanceADNUnitData {
  //adn渠道对象
  supplier = new AdvanceSupplierModel()
  // 广告位类型
  adType: AdvanceAdType = AdvanceAdType.unknown
  // 扩展信息
  ext?: AdvanceSupplierExt
}


//一些渠道上运行需要信息补充
export class AdvanceSupplierExt {
  vpWidth: number = 0
  vpHeight: number = 0
}