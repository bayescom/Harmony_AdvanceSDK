import { window } from '@kit.ArkUI'



export default class AdvanceConstant{
  public static readonly ADV_API_VERSION_NAME: string = '3.1.0'
  public static readonly ADV_SDK_VERSION_NAME: string = '1.0'
  public static readonly ADV_SDK_ID_MERCURY: string = '1'
  public static readonly ADV_SDK_ID_YLH: string = '2'
  public static readonly ADV_SDK_ID_CSJ: string = '3'
  public static readonly ADV_SDK_ID_BAIDU: string = '4'
  public static readonly ADV_SDK_ID_KS: string = '5'
  public static readonly ADV_SDK_ID_TANX: string = '7'
  public static readonly ADV_SDK_ID_TAP: string = '10'
  public static readonly ADV_AD_TYPE_SPLASH: number = 1
  public static readonly ADV_AD_TYPE_FEED: number = 2
  public static readonly ADV_PARA_GROUP_TIMEOUT: number = 5000

  //广告返回状态标记
  public static readonly ADV_ADN_RESULT_LOADING: number = -1
  public static readonly ADV_ADN_RESULT_FAILED: number = 0
  public static readonly ADV_ADN_RESULT_SUCCESS: number = 1

  static windowStage: window.WindowStage
}