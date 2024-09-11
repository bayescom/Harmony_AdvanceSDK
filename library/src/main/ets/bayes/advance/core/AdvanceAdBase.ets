import { BYLog } from '../../basic/BYLog'
import { AdvanceOption } from '../config/AdvanceOption'
import { AdvanceADNUnitData } from '../model/AdvanceADNUnitData'
import { AdvanceParaGroup } from '../model/AdvanceGroup'
import { AdvanceRequestManger } from '../net/AdvanceRequestManger'
import { AdvanceADNCommonAdapter } from './AdvanceADNCommonAdapter'
import { AdvanceBaseOpenFuc } from './AdvanceOpenFuc'
import { AdvanceBaseListener } from './AdvanceOpenListener'

export abstract class AdvanceAdBase implements AdvanceBaseOpenFuc {
  adOption: AdvanceOption
  baseListener ?: AdvanceBaseListener
  //策略组
  supplierGroups: AdvanceParaGroup[] = []
  //当前执行的SDK
  currentAD ?: AdvanceADNUnitData
  adapterMap: Map<number, AdvanceADNCommonAdapter> = new Map()

  constructor(option: AdvanceOption) {
    this.adOption = option
    // try {
    //
    // } catch (e) {
    //   BYLog.printE(e)
    // }
  }

  loadStrategy(): void {
    AdvanceRequestManger.requestStrategy(this.adOption, (err, data) => {
      if (err) {
        return
      }
      if (!data) {
        return
      }

    })
  }


  //根据currentAD 找到对应adapter
  getCurrentAdapter(): AdvanceADNCommonAdapter | undefined {
    try {
      let key = this.currentAD?.supplier?.priority
      if (key) {
        return this.adapterMap[key]
      }
    } catch (e) {
      BYLog.printE(e)
    }
    return
  }
}