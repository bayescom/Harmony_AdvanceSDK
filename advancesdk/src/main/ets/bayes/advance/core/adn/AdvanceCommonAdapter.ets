import { NodeController, window } from '@kit.ArkUI';
import { AdvanceADNUnitData } from '../../../../../../../Index';

export abstract class AdvanceCommonAdapter {
  //渠道参数
  unitData: AdvanceADNUnitData
  //是否来自缓存
  isFromCache: boolean = false
  //竞价价格
  price: number = 0

  constructor(unitData: AdvanceADNUnitData) {
    this.unitData = unitData
  }

  abstract adapter_loadAd()

  adapter_showAd(windowStage: window.WindowStage) {} // 默认实现

  adapter_isAdValid(): boolean {
    return true
  }

  adapter_getAdComponent(): NodeController | undefined { // for banner & native express
    return undefined
  }

  adapter_render(context: UIContext) {} // for banner & native express & render feed

}
