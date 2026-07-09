import { NodeController, window } from '@kit.ArkUI';
import { AdvanceAdType, AdvBidWinLossResult, AdvRewardVideoModel } from '../../model/AdvanceAdInfo';
import { AdvanceCommonBannerAdapterBridge } from './AdvanceCommonBannerAdapterBridge';
import { AdvanceCommonInterstitialAdapterBridge } from './AdvanceCommonInterstitialAdapterBridge';
import { AdvanceCommonNativeExpressAdapterBridge } from './AdvanceCommonNativeExpressAdapterBridge';
import { AdvanceCommonRenderFeedAdapterBridge } from './AdvanceCommonRenderFeedAdapterBridge';
import { AdvanceCommonRewardVideoAdapterBridge } from './AdvanceCommonRewardVideoAdapterBridge';
import { AdvanceCommonSplashAdapterBridge } from './AdvanceCommonSplashAdapterBridge';

// 传递给 adapter 的参数信息
export class AdvanceADNUnitData {
  // 渠道id
  adnId: string = ''
  // 广告位类型
  adType: AdvanceAdType = AdvanceAdType.unknown
  // 广告位id
  placementId: string = ''
  // 超时时间
  timeout: number = 0
  // 广告位宽度
  vpWidth?: number
  // 广告位高度
  vpHeight?: number
  // 激励视频奖励信息（外部传入）
  rewardVideoModel?: AdvRewardVideoModel
  // 激励视频服务端下发的奖励名称
  serverRewardName?: string
  // 激励视频服务端下发的奖励数量
  serverRewardCount?: number
  // 自定义adn扩展信息
  custom_adn_extra?: Record<string, string | number>
}

export abstract class AdvanceCommonAdapter {
  //渠道参数
  unitData: AdvanceADNUnitData
  //是否来自缓存
  isFromCache: boolean = false
  //竞价价格
  price: number = 0

  // 构造函数
  constructor(unitData: AdvanceADNUnitData) {
    this.unitData = unitData
  }

  // 加载广告的方法
  abstract adapter_loadAd()

  // 广告是否有效
  adapter_isAdValid(): boolean { // 默认实现
    return true
  }

  // Adn竞胜/竞败后回传信息
  adapter_sendNotification(result: AdvBidWinLossResult) {}
}

// 开屏广告的adapter广告协议
export abstract class AdvanceCommonSplashAdapter extends AdvanceCommonAdapter {
  bridge?: AdvanceCommonSplashAdapterBridge

  /// 设置开屏 bridge 用于回传广告状态
  adapter_setSplashBridge(bridge: AdvanceCommonSplashAdapterBridge) {
    this.bridge = bridge
  }

  /// 展示广告
  abstract adapter_showAd(windowStage: window.WindowStage)
}

// Banner广告的adapter广告协议
export abstract class AdvanceCommonBannerAdapter extends AdvanceCommonAdapter {
  bridge?: AdvanceCommonBannerAdapterBridge

  /// 设置横幅 bridge 用于回传广告状态
  adapter_setBannerBridge(bridge: AdvanceCommonBannerAdapterBridge) {
    this.bridge = bridge
  }

  /// 渲染广告
  abstract adapter_render(context: UIContext)

  /// 获取广告组件
  abstract adapter_getAdComponent(): NodeController | undefined
}

// 插屏广告的adapter广告协议
export abstract class AdvanceCommonInterstitialAdapter extends AdvanceCommonAdapter {
  bridge?: AdvanceCommonInterstitialAdapterBridge

  /// 设置插屏 bridge 用于回传广告状态
  adapter_setInterstitialBridge(bridge: AdvanceCommonInterstitialAdapterBridge) {
    this.bridge = bridge
  }

  /// 展示广告
  abstract adapter_showAd(windowStage: window.WindowStage)
}

// 激励视频广告的adapter广告协议
export abstract class AdvanceCommonRewardVideoAdapter extends AdvanceCommonAdapter {
  bridge?: AdvanceCommonRewardVideoAdapterBridge

  /// 设置激励视频 bridge 用于回传广告状态
  adapter_setRewardVideoBridge(bridge: AdvanceCommonRewardVideoAdapterBridge) {
    this.bridge = bridge
  }

  /// 展示广告
  abstract adapter_showAd(windowStage: window.WindowStage)
}

// 信息流（模板渲染）广告的adapter广告协议
export abstract class AdvanceCommonNativeExpressAdapter extends AdvanceCommonAdapter {
  bridge?: AdvanceCommonNativeExpressAdapterBridge

  /// 设置信息流 bridge 用于回传广告状态
  adapter_setNativeExpressBridge(bridge: AdvanceCommonNativeExpressAdapterBridge) {
    this.bridge = bridge
  }

  /// 渲染广告
  abstract adapter_render(context: UIContext)

  /// 获取广告组件
  abstract adapter_getAdComponent(): NodeController | undefined
}

// 信息流（自渲染）广告的adapter广告协议
export abstract class AdvanceCommonRenderFeedAdapter extends AdvanceCommonAdapter {
  bridge?: AdvanceCommonRenderFeedAdapterBridge

  /// 设置信息流 bridge 用于回传广告状态
  adapter_setRenderFeedBridge(bridge: AdvanceCommonRenderFeedAdapterBridge) {
    this.bridge = bridge
  }

  /// 渲染广告
  abstract adapter_render(context: UIContext)
}