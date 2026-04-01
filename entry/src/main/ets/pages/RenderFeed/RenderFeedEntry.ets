import { PageTitleView } from '../../components/PageTitleView';
import { PosIdSelector } from '../../components/PosIdSelector'
import { router } from '@kit.ArkUI';

@Entry
@Component
struct RenderFeedEntry {
  @State placementId: string = '10014698' // mercury
  private readonly placementIdArr: Array<[string, string]> = [
    ['10014698', '自渲染信息流-倍业'],
    ['10014696', '自渲染信息流-穿山甲'],
    ['10014697', '自渲染信息流-优量汇'],
    ['10014699', '自渲染信息流-快手'],
  ];

  build() {
    Column({ space: 20 }) {
      PageTitleView({title: '自渲染信息流广告'})
      PosIdSelector({
        posId: this.placementId,
        posIdArr: this.placementIdArr,
      })
      Button('消息流示例')
        .width('100%')
        .onClick(() => {
          router.pushUrl({
            url: "pages/RenderFeed/RenderFeed",
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