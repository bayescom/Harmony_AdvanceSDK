import { AdvanceConstant } from '../../define/AdvanceConstant'
import { AdvanceAdType } from '../../define/AdvanceDefine'
import { AdvanceSupplierModel } from '../../model/AdvanceNetModel'

//聚合adn侧使用的
export class AdvanceADNUnitData {
  groupID: number = 0 //广告位所属组
  adType: AdvanceAdType = AdvanceAdType.unknown // 广告位类型
  //adn渠道策略信息
  supplier?: AdvanceSupplierModel
  //补充内容
  ext?: AdvanceSupplierExt
  resultStatus: number = AdvanceConstant.ADV_ADN_STATUS_LOADING //1代表成功返回

  //被选中为最优
  chooseBest: boolean = false
}


//一些渠道上运行需要信息补充
export class AdvanceSupplierExt {
  vpWidth: number = 0
  vpHeight: number = 0
}