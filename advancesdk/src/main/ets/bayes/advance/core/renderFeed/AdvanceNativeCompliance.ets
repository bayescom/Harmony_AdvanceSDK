export interface  AdvanceNativeCompliance {
  getAppName(): string;

  getAppVersion(): string;

  getDeveloperName(): string;

  getPrivacyUrl(): string;

  getPermissionsMap(): Map<string, string>;

  getPermissionUrl(): string;

  getFunctionDescUrl(): string;
}