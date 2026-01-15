import { router } from '@kit.ArkUI';
import {
  AdvanceDislike,
  AdvanceError,
  AdvanceOption,
  AdvanceSupplier,
  AdvanceRenderFeedData,
  AdvanceRenderFeed,
  AdvanceNativeInteractionModel
} from 'AdvanceSDK';
import { AdInf, DemoUtil } from '../util/DemoUtil';
import { ArrayList, util } from '@kit.ArkTS';

import { logToast } from '../util/Toast';

@Entry
@Component
export struct RenderFeed {
  @State private listArray: Array<string | AdvanceRenderFeedData> = new Array();
  @State private errorMsg: string | undefined = undefined;
  @State private dislikeStatus: boolean = false;

  aboutToAppear(): void {

    let posId = ''
    let adinf = router.getParams() as AdInf
    posId = adinf.adId
    if (DemoUtil.isEmpty(posId)) {
      posId = '10011085'
    }

    //模拟正常信息流内容
    for (let index = 0; index < 20; index++) {
      this.listArray.push(`测试item：${index}`)
    }


    //请求聚合广告
    let op = new AdvanceOption(posId)
    op.widthVP = 360
    let advNative = new AdvanceRenderFeed(op)
    let data: AdvanceRenderFeedData | undefined = undefined
    advNative.setListener({
      onShow: (): void => {
        logToast(`onShow`)
      },
      onDislike: (dislike: AdvanceDislike): void => {
        logToast(`onDislike , dislike = ${JSON.stringify(dislike)}`)

        //同步关闭状态
        this.dislikeStatus = true
      },
      onLoaded: (supplier: AdvanceSupplier): void => {
        logToast(`onLoaded , supplier : ${JSON.stringify(supplier)}`)

        //进行渲染操作
        data = advNative.getNativeData()
        data?.render(this.getUIContext())
      },
      onClick: (): void => {
        logToast(`onClick`)
      },
      onRenderSuccess: (): void => {
        logToast(`onRenderSuccess`)

        //插入当前信息流对象
        if (data) {
          this.listArray.splice(3, 0, data)
        }
      },
      onRenderFail: (err: AdvanceError): void => {
        logToast(`onRenderFail , ${err.toString()}`)
      },
      onError: (err: AdvanceError): void => {
        logToast(`onError , err = ${err.toString()}`)
      }
    })

    advNative.loadStrategy()

  }

  /**
   * UI布局构建
   */
  build() {
    Row() {
      if (this.errorMsg != "") {
        Text(this.errorMsg).fontSize(12).fontColor(Color.Red).margin(5)
      }
      List() {
        ForEach(this.listArray, (item: string | AdvanceRenderFeedData) => {
          ListItem() {
            if (typeof item === 'string') {
              this.BuildCommonItem(item)
            } else
              if (!this.dislikeStatus) {
                if (item.isExpressAd()) {
                  NodeContainer(item.getAdComponent())
                } else {
                  this.buildAdLayout(item);
                }
              }
          }
          .align(Alignment.Center)
          .width('100%')
          .onDisAppear(() => {
            if (typeof item != 'string') {
              item.destroy(); //释放资源
            }
          })
        }, (item: string | AdvanceRenderFeedData, index: number) => {
          return item.toString() + "_" + index
        })
      }.divider({ strokeWidth: 1, color: Color.Gray }).scrollBar(BarState.Off)
    }
  }

  /**
   * 非广告Item
   * @param text
   */
  @Builder
  BuildCommonItem(text: string) {
    Row() {
      Text(text)
        .width('100%')
        .key("key")
        .height(80)
        .textAlign(TextAlign.Center)
        .padding({ top: 10, bottom: 10 })
    }
  }

  /**
   * Feed自渲染广告
   * @param ad
   */
  @Builder
  private buildAdLayout(ad: AdvanceRenderFeedData, clickViewIds: ArrayList<string> = new ArrayList(),
    creativeViewIds: ArrayList<string> = new ArrayList(), rootComponentId: string = util.generateRandomUUID()) {
    Column() {
      Row() {
        Row() {
          //广告主Icon
          Image(ad.getIconUrl())
            .height(32)
            .width(32)
            .borderRadius(5)
            .margin({ right: 5 })
            .id(this.generateViewId(clickViewIds)) //设置组件Id，需要全局保证唯一性，涉及计费

          //描述内容
          Text(ad.getDescription())
            .fontSize(12)
            .textAlign(TextAlign.Start)
            .maxLines(2)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .id(this.generateViewId(clickViewIds)) //设置组件Id，需要全局保证唯一性，涉及计费
        }
        .height(35)
        .width("85%")
        .justifyContent(FlexAlign.Start);

        Row() {
          //dislike 按钮
          Image($r("app.media.icon_dislike")).onClick(() => {

            ad.showDislikeDialog(this)
          })
            .height(16)
            .width(16)
            .borderRadius(8)
        }.height(35)
        .width("10%")
        .justifyContent(FlexAlign.End);
      }
      .justifyContent(FlexAlign.SpaceBetween)
      .height(35)
      .width("100%")
      .padding({ left: 10, right: 10, bottom: 4 })

      //视频|图片区域
      Stack({ alignContent: Alignment.BottomStart }) {
        if (ad.isVideo()) {
          NodeContainer(ad.getAdComponent())
        } else if (ad.getImageUrlList().length > 0) {
          this.buildImageLayout(ad, creativeViewIds)
        }

        Flex({ direction: FlexDirection.Column, justifyContent: FlexAlign.End }) { // 子组件在容器主轴上行布局
          if (typeof ad.getAdLogo() === "string") {
            Text(ad.getAdLogo())
              .fontSize(6)
              .height(18)
              .width(30)
              .fontColor(Color.White)
              .backgroundColor("#40ffffff")
              .align(Alignment.Center)
              .padding({ left: 2 })
          } else {
            Image(ad.getAdLogo()).height(20).width(30).objectFit(ImageFit.Auto).onClick((event: ClickEvent) => {
              ad.onAdClick(2, event);
            })
          }
        }.width("100%")
        .height(20)

      }.height(200)

      Row() {
        //标题
        Text(ad.getTitle())
          .fontSize(12)
          .textAlign(TextAlign.Center)
          .id(this.generateViewId(creativeViewIds)) //设置组件Id，需要全局保证唯一性，涉及计费


        //创意按钮
        Button(ad.getButtonText(), { type: ButtonType.Normal })
          .fontSize(12)
          .borderRadius(5)
          .id(this.generateViewId(creativeViewIds)) //设置组件Id，需要全局保证唯一性，涉及计费

      }
      .justifyContent(FlexAlign.SpaceBetween)
      .height(35)
      .width("100%")
      .padding({
        top: 5,
        bottom: 5,
        left: 10,
        right: 10
      })
    }
    .backgroundColor("#08000000")
    .id(rootComponentId) //设置广告容器组件rootId
    .onAppear(() => {
      let advInter = new AdvanceNativeInteractionModel()
      advInter.rootAdComponentId = rootComponentId
      advInter.uiContext = this.getUIContext()
      advInter.clickViewIds = clickViewIds
      advInter.creativeViewIds = creativeViewIds
      //注册计费事件
      ad.registerViewForInteraction(advInter)
    })
  }

  /**
   * 图片类型广告布局
   * @param ad
   */
  @Builder
  buildImageLayout(ad: AdvanceRenderFeedData, creativeViewIds: ArrayList<string>) {
    if (ad.getImageUrlList().length > 1) {
      Row({ space: 10 }) {
        ForEach((ad.getImageUrlList() ?? new ArrayList<string>()).convertToArray(), (url: string) => {
          Image(url)
            .objectFit(ImageFit.Cover)
            .width(((100 / (ad.getImageUrlList().length ?? 0) - 1) + "%"))
            .height("100%")
            .id(this.generateViewId(creativeViewIds)) //设置组件Id，需要全局保证唯一性，涉及计费;
        })
      }.justifyContent(FlexAlign.SpaceBetween).width("100%").alignItems(VerticalAlign.Center).height("100%")
    } else if (ad.getImageUrlList().length == 1) {
      Image(ad.getImageUrlList()[0])
        .objectFit(ImageFit.Cover)
        .id(this.generateViewId(creativeViewIds)) //设置组件Id，需要全局保证唯一性，涉及计费
    }
  }

  generateViewId(savedViewIds: ArrayList<string>): string {
    let viewId = util.generateRandomUUID()
    savedViewIds.add(viewId)
    return viewId
  }
}