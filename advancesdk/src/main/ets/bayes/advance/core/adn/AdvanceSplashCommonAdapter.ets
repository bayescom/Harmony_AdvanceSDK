import { AdvanceSplashListener } from '../AdvanceOpenListener';
import { AdvanceCommonAdapter } from './AdvanceCommonAdapter';

export abstract class AdvanceSplashCommonAdapter extends AdvanceCommonAdapter {
  splashListener?: AdvanceSplashListener

  setSplashListener(splashListener: AdvanceSplashListener) {
    this.splashListener = splashListener
    this.baseListener = splashListener
  }
}