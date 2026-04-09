import { PageTitleView } from '../../components/PageTitleView';
import { PosIdSelector } from '../../components/PosIdSelector'
import { router } from '@kit.ArkUI';

@Entry
@Component
struct NativeExpressEntry {
  @State placementId: string = '10014807' // bidding
  private readonly placementIdArr: Array<[string, string]> = [
    ['10014807', '模板信息流-Bidding'],
    ['10014651', '模板信息流-倍业'],
    ['10014649', '模板信息流-穿山甲'],
    ['10014650', '模板信息流-优量汇'],
    ['10014676', '模板信息流-快手'],
  ];

  build() {
    Column({ space: 20 }) {
      PageTitleView({title: '模板信息流广告'})
      PosIdSelector({
        posId: this.placementId,
        posIdArr: this.placementIdArr,
      })
      Button('消息流示例')
        .width('100%')
        .onClick(() => {
          router.pushUrl({
            url: "pages/NativeExpress/NativeExpress",
            params: {"placementId" : this.placementId}
          })
        })
    }.width('100%')
    .padding({
      top: 10,
      left: 20,
      right: 20,
      bottom: 10
    })
  }
}