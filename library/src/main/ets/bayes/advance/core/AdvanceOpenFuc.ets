import { AdvanceSupplier } from '../model/AdvanceSupplier'

export interface AdvanceBaseOpenFuc {
  loadStrategy(): void

  getWinSupplier():AdvanceSupplier |undefined

  destroy(): void
}