import { NodeController } from '@kit.ArkUI'
import {
  AdvanceError,
  AdvanceOption,
  AdvanceRenderOption,
  AdvanceSplash,
  AdvanceAdInfo } from 'AdvanceSDK'
import { DemoConstants } from '../entryability/DemoConstants'
import { logToast, toast } from '../util/Toast'

@Entry
@Component
struct Splash {
  @State adID: string = '10011044'
  @State splash?: AdvanceSplash = undefined
  @State splashAdComponent?: NodeController = undefined

  build() {
    Stack() {

      //操作选择区域
      Column() {
        Row() {
          Text('广告位id：')
          TextInput({ placeholder: `${this.adID}` })
            .width(200)
            .type(InputType.Number)
            .onChange((value) => {
              this.adID = value
            })
        }

        Button('请求开屏广告').width('100%')
          .onClick(() => {
            let opt = new AdvanceOption(this.adID)
            this.splash = new AdvanceSplash(opt)
            this.splash.setAdListener({
              onAdLoaded: (adInfo: AdvanceAdInfo) => {
                logToast(`onAdLoaded, adInfo: ${JSON.stringify(adInfo)}`)
              },
              onAdLoadFailed: (err: AdvanceError) => {
                logToast(`onAdLoadFailed, err: ${err.toString()}`)
              },
              onAdShow: () => {
                logToast(`onAdShow`)
              },
              onAdShowFailed: (error: AdvanceError) => {
                logToast(`onAdShowFailed, err: ${error.toString()}`)
              },
              onAdClick: () => {
                logToast(`onAdClick`)
              },
              onAdClose: () => {
                logToast(`onAdClose`)
              },
            })
            this.splash.loadAd()
          })
          .margin({
            top: 20
          })

        Button('subWindow展示开屏').width('100%')
          .onClick(() => {
            if (!this.splash) {
              toast(`请先请求广告`)
              return
            }
            // let renOp = new AdvanceRenderOption(DemoConstants.windowStage)
            if (this.splash.isAdValid()) {
              this.splash.showAd()
            }
          }).margin({
          top: 20
        })

        Button('view展示开屏')
          .width('100%')
          .onClick(() => {
            // if (!this.splash) {
            //   toast(`请先请求广告`)
            //   return
            // }
            // this.splashAdComponent = this.splash?.getAdComponent()

          }).margin({
          top: 20
        })


      }.width('100%').padding({
        top: 10,
        left: 20,
        right: 20,
        bottom: 10
      })

      //view形式
      NodeContainer(this.splashAdComponent)
    }
  }
}