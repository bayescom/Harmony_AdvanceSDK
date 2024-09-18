import { CSJCustomPrivacyController } from '@csj/openadsdk';
import { AdvancePrivacyController } from '../../config/AdvancePrivacyController';

export class AdvCsjPrivacy extends CSJCustomPrivacyController {
  advPrivacy: AdvancePrivacyController

  constructor(advPrivacy: AdvancePrivacyController) {
    super()
    this.advPrivacy = advPrivacy
  }

  isCanUseAppTrackingConsent(): boolean {
    return this.advPrivacy.isCanUseAppTrackingConsent()
  }

  isCanUseLocation(): boolean {
    return this.advPrivacy.isCanUseLocation()
  }

  isCanUseWifiState(): boolean {
    return this.advPrivacy.isCanUseWifiState()
  }

  getDevOaid(): string | undefined {
    return this.advPrivacy.getCusOaid()
  }

  getTTLocation(): number[] | undefined {
    let advLoca = this.advPrivacy.getCusLocation()
    if (advLoca) {
      return [advLoca.latitude, advLoca.longitude]
    }
    return undefined
  }

  getMacAddress(): string | undefined {
    return this.advPrivacy.getMacAddress()
  }
}