import { AdvanceCloseType } from '../model/AdvanceCloseType'
import { AdvanceError } from '../model/AdvanceError'
import { AdvanceSupplier } from '../model/AdvanceSupplier'
import { AdvanceDislike } from './AdvanceDislike'


export interface AdvanceCommListener {
  onLoaded: (supplier: AdvanceSupplier) => void //广告加载成功
  onError: (err: AdvanceError) => void //策略获取失败
}

export interface AdvanceBaseEventListener extends AdvanceCommListener {
  onShow: () => void //广告曝光成功
  onClick: () => void //广告点击
  onRenderSuccess: () => void // 在调用广告的render方法后，广告渲染成功，会回调该方法，此时表示广告已准备好，待展示
  onRenderFail: (err: AdvanceError) => void //广告曝光成功
}

export interface AdvanceSplashListener extends AdvanceBaseEventListener {
  onClose: (closeType: AdvanceCloseType) => void //广告关闭回调
}

export interface AdvanceFeedListener extends AdvanceBaseEventListener {
  onDislike: (dislike: AdvanceDislike) => void //广告关闭回调
}


export interface AdvanceNativeListener extends AdvanceBaseEventListener {
  onDislike: (dislike: AdvanceDislike) => void //广告关闭回调

}

