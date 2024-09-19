import { AdvanceSplashListener } from '../AdvanceOpenListener';
import { AdvanceADNCommonAdapter } from './AdvanceADNCommonAdapter';

export abstract class AdvanceADNCommonSplashAdapter extends AdvanceADNCommonAdapter {
  splashListener?: AdvanceSplashListener

  setSplashListener(splashListener: AdvanceSplashListener) {
    this.splashListener = splashListener
    this.baseListener = splashListener
  }
}