import { router } from '@kit.ArkUI'

@Entry
@Component
export struct FeedChoose {
  private adExpressId = '' //
  private adNativeId = '' //

  build() {
    Column() {
      Row() {
        Text("模板广告位id：")
        TextInput({ placeholder: "adm" })
          .width("80%")
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
          router.pushUrl({
            url: "pages/Feed",
            params: this.adExpressId
          })
        })

      Row() {
        Text("自渲染广告位id：")
        TextInput({ placeholder: "adm" })
          .width("80%")
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
          router.pushUrl({
            url: "pages/Native",
            params: this.adNativeId
          })
        })
    }
  }
}