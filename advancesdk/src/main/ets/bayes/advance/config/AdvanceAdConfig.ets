import { window } from '@kit.ArkUI'

export interface AdvanceAdLoadConfig {
  placementId: string
  adWidth?: number // 单位：vp
  adHeight?: number // 单位: vp
}


// export class AdvanceRenderOption {
//   constructor(windowStage: window.WindowStage) {
//     this.windowStage = windowStage
//   }
//
//   //window必传
//   windowStage: window.WindowStage
//   //底部自定义布局 --开屏logo区域
//   customBottomBuilder?: WrappedBuilder<[]>
//   //跳过|关闭按钮的自定义布局
//   // customSkipBuilder?: WrappedBuilder<[]>
// }
