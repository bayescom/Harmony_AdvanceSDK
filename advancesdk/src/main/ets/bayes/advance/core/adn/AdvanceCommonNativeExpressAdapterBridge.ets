import { AdvanceError } from "../../define/AdvanceError";
import { AdvanceCommonNativeExpressAdapter } from "./AdvanceCommonAdapter";

/// 模板渲染信息流广告adapter的回调协议
export interface AdvanceCommonNativeExpressAdapterBridge {

  nativeExpress_didAdLoaded: (adapter: AdvanceCommonNativeExpressAdapter, price: number) => void

  nativeExpress_didAdLoadFailed: (adapter: AdvanceCommonNativeExpressAdapter, error: AdvanceError) => void

  nativeExpress_didAdRenderSuccess: (adapter: AdvanceCommonNativeExpressAdapter) => void

  nativeExpress_didAdRenderFail: (adapter: AdvanceCommonNativeExpressAdapter, error: AdvanceError) => void

  nativeExpress_didAdShow: (adapter: AdvanceCommonNativeExpressAdapter) => void

  nativeExpress_didAdClick: (adapter: AdvanceCommonNativeExpressAdapter) => void

  nativeExpress_didAdClose: (adapter: AdvanceCommonNativeExpressAdapter) => void

  nativeExpress_didAdVideoPlayStart: (adapter: AdvanceCommonNativeExpressAdapter) => void

  nativeExpress_didAdVideoPlayEnd: (adapter: AdvanceCommonNativeExpressAdapter) => void

  nativeExpress_didAdVideoPlayFailed: (adapter: AdvanceCommonNativeExpressAdapter, error: AdvanceError) => void

}