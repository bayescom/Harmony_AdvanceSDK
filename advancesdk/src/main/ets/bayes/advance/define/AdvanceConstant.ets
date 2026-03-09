export class AdvanceConstant {
  public static readonly ADV_API_VERSION_NAME: string = '3.1.0'
  public static readonly ADV_SDK_VERSION_NAME: string = '1.0'
  // SDK标识id
  public static readonly ADV_SDK_ID_MERCURY: string = '1'
  public static readonly ADV_SDK_ID_GDT: string = '2'
  public static readonly ADV_SDK_ID_CSJ: string = '3'
  public static readonly ADV_SDK_ID_BAIDU: string = '4'
  public static readonly ADV_SDK_ID_KS: string = '5'
  public static readonly ADV_SDK_ID_TANX: string = '7'

  //默认并发组超时时间
  public static readonly ADV_PARA_GROUP_TIMEOUT: number = 5000

  //广告返回状态标记
  public static readonly ADV_ADN_STATUS_LOADING: number = -1
  public static readonly ADV_ADN_STATUS_FAILED: number = 0
  public static readonly ADV_ADN_STATUS_SUCCESS: number = 1

  // adn广告初始化状态标记
  public static readonly ADV_ADN_INIT_DEFAULT: number = 0
  public static readonly ADV_ADN_INIT_LOADING: number = -1
  public static readonly ADV_ADN_INIT_SUCCESS: number = 1
  public static readonly ADV_ADN_INIT_FAILED: number = 2
}