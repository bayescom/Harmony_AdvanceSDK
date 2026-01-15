import { router } from '@kit.ArkUI'
import { AdInf } from '../util/DemoUtil'

@Entry
@Component
export struct FeedChoose {
  private adExpressId:string = '' //
  private adNativeId :string= '' //
  private adinf :AdInf =  new AdInf()

  aboutToAppear(): void {

  }


  build() {
    Column() {
      Row() {
        Text("模板广告位id：")
        TextInput({ placeholder: "adm" })
          .width("80%")
          .type(InputType.Number)
          .onChange((value) => {
            this.adExpressId = value
            console.log(`csjAdm onChanage ${value}`)
          })
      }.margin({ top: 20 })

      Button("Feed模板信息流广告")
        .width('100%')
        .margin({
          top: 20
        })
        .onClick(() => {
          this.adinf.adId = this.adExpressId
          router.pushUrl({
            url: "pages/NativeExpress",
            params: this.adinf,
          })
        })

      Row() {
        Text("自渲染广告位id：")
        TextInput({ placeholder: "adm" })
          .width("80%")
          .type(InputType.Number)
          .onChange((value) => {
            this.adNativeId = value
            console.log(`csjAdm onChanage ${value}`)
          })
      }.margin({ top: 50 })

      Button("Native自渲染广告")
        .width('100%')
        .margin({
          top: 20
        })
        .onClick(() => {
          this.adinf.adId = this.adNativeId
          router.pushUrl({
            url: "pages/RenderFeed",
            params: this.adinf
          })
        })
    }
  }
}
