import { CSJComplianceInfo } from '@csj/openadsdk';
import { AdvanceNativeCompliance } from 'AdvanceSDK';

export class AdvCsjNativeComplianceConvert implements AdvanceNativeCompliance {
  csjAppInf: CSJComplianceInfo

  constructor(csjAppInf: CSJComplianceInfo) {
    this.csjAppInf = csjAppInf
  }

  getAppName(): string {
    return this.csjAppInf.getAppName()
  }

  getAppVersion(): string {
    return this.csjAppInf.getAppVersion()
  }

  getDeveloperName(): string {
    return this.csjAppInf.getDeveloperName()

  }

  getPrivacyUrl(): string {
    return this.csjAppInf.getPrivacyUrl()

  }

  getPermissionsMap(): Map<string, string> {
    return this.csjAppInf.getPermissionsMap()

  }

  getPermissionUrl(): string {
    return this.csjAppInf.getPermissionUrl()

  }

  getFunctionDescUrl(): string {
    return this.csjAppInf.getFunctionDescUrl()

  }
}