import { window } from '@kit.ArkUI'


export class AdvanceOption {
  codeId: string
  widthVP :number = 0
  heightVP :number = 0

  constructor(codeId: string) {
    this.codeId = codeId
  }
}


export class AdvanceRenderOption {
  constructor(windowStage: window.WindowStage) {
    this.windowStage = windowStage
  }

  //window必传
  windowStage: window.WindowStage
  //底部自定义布局 --开屏logo区域
  customBottomBuilder?: WrappedBuilder<[]>
  //跳过|关闭按钮的自定义布局
  customSkipBuilder?: WrappedBuilder<[]>
}
