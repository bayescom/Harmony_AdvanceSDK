import { router } from '@kit.ArkUI';
import { AdvanceSDK } from 'advancesdk';
import { PageTitleView } from '../components/PageTitleView';

@Entry
@Component
struct Index {

  build() {
    Column({space: 20}) {
      PageTitleView({title: 'AdvanceDemo'})
      Text(`V${AdvanceSDK.getSDKVersion()}`)
        .fontSize(20)
        .fontWeight(FontWeight.Bold)
        .fontColor(Color.Gray)
      Button('开屏广告')
        .width('100%')
        .onClick(() => {
          router.pushUrl({ url: "pages/Splash" })
        })
      Button('横幅广告')
        .width('100%')
        .onClick(() => {
          router.pushUrl({ url: "pages/Banner" })
        })
      Button('插屏广告')
        .width('100%')
        .onClick(() => {
          router.pushUrl({ url: "pages/Interstitial" })
        })
      Button('激励视频广告')
        .width('100%')
        .onClick(() => {
          router.pushUrl({ url: "pages/RewardVideo" })
        })
      Button('信息流广告（模版渲染）')
        .width('100%')
        .onClick(() => {
          router.pushUrl({ url: "pages/FeedChoose" })
        })
      Button('信息流广告（自渲染）')
        .width('100%')
        .onClick(() => {
          router.pushUrl({ url: "pages/FeedChoose" })
        })
    }
    .height('100%')
    .width('100%')
    .padding({
      top: 10,
      left: 20,
      right: 20,
      bottom: 10
    })
  }
}