import { AdvanceNativeListener } from '../AdvanceOpenListener'
import { AdvanceNativeData } from '../native/AdvanceNativeData'
import { AdvanceADNCommonAdapter } from './AdvanceADNCommonAdapter'

export abstract class AdvanceADNCommonNativeAdapter extends AdvanceADNCommonAdapter {
  nativeListener?: AdvanceNativeListener

  setNativeListener(nativeListener: AdvanceNativeListener) {
    this.nativeListener = nativeListener
    this.baseListener = nativeListener
  }

  abstract getNativeData(): AdvanceNativeData | undefined
}