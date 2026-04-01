import { router } from '@kit.ArkUI';
import {
  AdvanceError,
  AdvanceAdLoadConfig,
  AdvanceAdInfo,
  AdvanceRenderFeedWrapper,
  AdvanceRenderFeed,
} from 'advancesdk';
import { util } from '@kit.ArkTS';
import { logToast } from '../../util/Toast';

@Entry
@Component
export struct RenderFeed {
  @State private listArray: Array<string | AdvanceRenderFeedWrapper> = new Array();
  private placementId: string = ''
  renderFeedAd?: AdvanceRenderFeed = undefined

  aboutToAppear(): void {
    let params: object = router.getParams()
    let recordObj: Record<string, string> = params as Record<string, string>;
    this.placementId = recordObj["placementId"]
    // 模拟正常信息流内容
    for (let index = 0; index < 20; index++) {
      this.listArray.push(`测试item：${index}`)
    }
    // 加载广告
    this.loadRenderFeedAd()
  }

  loadRenderFeedAd(): void {
    let config: AdvanceAdLoadConfig = {
      placementId: this.placementId
    }
    this.renderFeedAd = new AdvanceRenderFeed(config)
    this.renderFeedAd.setAdListener({
      onAdLoaded: (adInfo: AdvanceAdInfo) => {
        logToast(`onAdLoaded, adInfo: ${JSON.stringify(adInfo)}`)
      },
      onAdLoadFailed: (err: AdvanceError): void => {
        logToast(`onAdLoadFailed , err = ${err.toString()}`)
        this.renderFeedAd = undefined
      },
      onRenderSuccess: (wrapper: AdvanceRenderFeedWrapper): void => {
        logToast(`onRenderSuccess`)
        // 在指定位置插入当前信息流对象
        if (wrapper) {
          this.listArray.splice(2, 0, wrapper)
        }
      },
      onRenderFail: (err: AdvanceError): void => {
        logToast(`onRenderFail , ${err.toString()}`)
        this.renderFeedAd = undefined
      },
      onAdShow: (): void => {
        logToast(`onAdShow`)
      },
      onAdClick: (): void => {
        logToast(`onAdClick`)
      },
      onVideoPlayEnd: () => {
        logToast(`onAdVideoEnd`)
      }
    })
    this.renderFeedAd.loadAd()
  }

  /**
   * UI布局构建
   */
  build() {
    Row() {
      List() {
        ForEach(this.listArray, (item: string | AdvanceRenderFeedWrapper) => {
          ListItem() {
            if (typeof item === 'string') {
              this.BuildCommonItem(item)
            } else if (item) {
              this.buildAdLayout(item);
            }
          }
          .align(Alignment.Center)
          .backgroundColor((typeof item === 'string') ? Color.Orange : Color.White)
          .width('100%')
        }, (item: string | AdvanceRenderFeedWrapper, index: number) => {
          return item.toString() + "_" + index
        })
      }
      .divider({ strokeWidth: 1, color: Color.Gray })
      .scrollBar(BarState.Off)
      .align(Alignment.Center)
    }
  }

  onAdClose() {
    this.listArray.splice(2, 1); // 从数组中移除数据
    this.renderFeedAd?.destroyAdapters()
    this.renderFeedAd = undefined
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
        .height(100)
        .textAlign(TextAlign.Center)
        .padding({ top: 30, bottom: 30 })
    }
  }

  /**
   * Feed自渲染广告
   * @param ad
   */
  @Builder
  private buildAdLayout(wrapper: AdvanceRenderFeedWrapper, clickViewIds: string[] = new Array<string>(), rootViewId: string = util.generateRandomUUID()) {
    Column() {
      Row() {
        Row() {
          //广告主Icon
          Image(wrapper.getIconUrl())
            .height(32)
            .width(32)
            .borderRadius(5)
            .margin({ right: 5 })
            .id(this.generateViewId(clickViewIds)) //设置组件Id，需要全局保证唯一性，涉及计费
            .onClick(event => { //控件点击监听
              wrapper.getClickHandler()(event)
            })

          //描述内容
          Text(wrapper.getDescription())
            .fontSize(12)
            .textAlign(TextAlign.Start)
            .maxLines(2)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .id(this.generateViewId(clickViewIds)) //设置组件Id，需要全局保证唯一性，涉及计费
            .onClick(event => { //控件点击监听
              wrapper.getClickHandler()(event)
            })
        }
        .height(35)
        .width("85%")
        .justifyContent(FlexAlign.Start);

        Row() {
          //dislike 按钮
          Image($r("app.media.icon_dislike")).onClick(() => {
            this.onAdClose()
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
        if (wrapper.isVideoAd()) {
          NodeContainer(wrapper.getAdComponent())
        } else if (wrapper.getImageUrlList().length > 0) {
          this.buildImageLayout(wrapper, clickViewIds)
        }

        Flex({ direction: FlexDirection.Column, justifyContent: FlexAlign.End }) { // 子组件在容器主轴上行布局
          NodeContainer(wrapper.getAdLogoView())
        }
        .width("100%")
        .height(20)
        .padding({left: 2})

      }
      .width('100%')
      .aspectRatio(16 / 9)

      Row() {
        //标题
        Text(wrapper.getTitle())
          .fontSize(12)
          .textAlign(TextAlign.Center)
          .id(this.generateViewId(clickViewIds)) //设置组件Id，需要全局保证唯一性，涉及计费
          .onClick(event => { //控件点击监听
            wrapper.getClickHandler()(event)
          })


        //交互按钮
        Button(wrapper.getButtonText(), { type: ButtonType.Normal })
          .fontSize(12)
          .borderRadius(5)
          .id(this.generateViewId(clickViewIds)) //设置组件Id，需要全局保证唯一性，涉及计费
          .onClick(event => { //控件点击监听
            wrapper.getClickHandler()(event)
          })

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
    .id(rootViewId) //设置广告容器组件rootId
    .onAppear(() => {
      //注册计费事件
      wrapper.registerViewForInteraction(this.getUIContext(), rootViewId, clickViewIds)
    })
    // 添加可见区域监听，SDK内部处理曝光逻辑
    .onVisibleAreaChange(wrapper.getVisibleAreaRatios(), wrapper.getVisibleAreaChangeListener())
  }

  /**
   * 图片类型广告布局
   * @param ad
   */
  @Builder
  buildImageLayout(wrapper: AdvanceRenderFeedWrapper,clickViewIds: string[]) {
    if (wrapper.getImageUrlList().length > 1) {
      Row({ space: 10 }) {
        ForEach((wrapper.getImageUrlList() ?? new Array<string>()), (url: string) => {
          Image(url)
            .objectFit(ImageFit.Cover)
            .width(((100 / (wrapper.getImageUrlList().length ?? 0) - 1) + "%"))
            .height("100%")
            .id(this.generateViewId(clickViewIds)) //设置组件Id，需要全局保证唯一性，涉及计费;
            .onClick(event => { //控件点击监听
              wrapper.getClickHandler()(event)
            })
        })
      }.justifyContent(FlexAlign.SpaceBetween).width("100%").alignItems(VerticalAlign.Center).height("100%")
    } else if (wrapper.getImageUrlList().length == 1) {
      Image(wrapper.getImageUrlList()[0])
        .objectFit(ImageFit.Cover)
        .id(this.generateViewId(clickViewIds)) //设置组件Id，需要全局保证唯一性，涉及计费
        .onClick(event => { //控件点击监听
          wrapper.getClickHandler()(event)
        })
    }
  }

  generateViewId(clickViewIds: string[]): string {
    let viewId = util.generateRandomUUID()
    clickViewIds.push(viewId)
    return viewId
  }
}