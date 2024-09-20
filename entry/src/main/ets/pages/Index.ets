import { router } from '@kit.ArkUI';

@Entry
@Component
struct Index {
  @State message: string = 'OH_AdvanceDemo';

  aboutToAppear(): void {
  }

  build() {
    Column() {
      Text(this.message)
        .id('HelloWorld')
        .fontSize(30)
        .padding(20)
        .fontWeight(FontWeight.Bold)
        .alignRules({
          // center: { anchor: '__container__', align: VerticalAlign.Center },
          middle: { anchor: '__container__', align: HorizontalAlign.Center }
        })

      Button('开屏广告').margin(10).onClick((ev) => {
        router.pushUrl({ url: "pages/Splash" })
      })
      Button('信息流广告').margin(10).onClick((ev) => {
        router.pushUrl({ url: "pages/Feed" })
      })
    }
    .height('100%')
    .width('100%')
  }
}