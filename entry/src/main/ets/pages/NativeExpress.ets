import { logToast } from '../util/Toast';
import { AdvanceDislike, AdvanceError, AdvanceNativeExpress, AdvanceOption, AdvanceAdInfo } from 'AdvanceSDK'
import { router } from '@kit.ArkUI';
import { AdInf, DemoUtil } from '../util/DemoUtil';

// import{AdSlot, AdSlotBuilder} from 'csjSDK'

@Entry
@Component
export struct NativeExpress {
  @State private listArray: Array<string | AdvanceNativeExpress> = new Array();
  @State private errorMsg: string | undefined = undefined;
  @State private dislikeStatus: boolean = false;


  aboutToAppear(): void {
    let posId = ''

    let adinf = router.getParams() as AdInf
    posId = adinf.adId
    if (DemoUtil.isEmpty(posId)) {
      posId = '10011073'
    }
    //模拟正常信息流内容
    for (let index = 0; index < 20; index++) {
      this.listArray.push(`测试item：${index}`)
    }


    //请求聚合广告
    let op = new AdvanceOption(posId)
    op.widthVP = 390
    op.heightVP = 0
    let advFeed = new AdvanceNativeExpress(op)
    advFeed.setListener({
      onAdShow: (): void => {
        logToast(`onAdShow`)
      },
      onAdClose: () => {

      },
      onDislike: (dislike: AdvanceDislike): void => {
        logToast(`onDislike , dislike = ${JSON.stringify(dislike)}`)

        //同步关闭状态
        this.dislikeStatus = true
      },
      onAdLoaded: (supplier: AdvanceAdInfo): void => {
        logToast(`onAdLoaded , supplier : ${JSON.stringify(supplier)}`)

        //开始渲染广告
        advFeed.render(this.getUIContext())
        //插入当前信息流对象
        this.listArray.splice(3, 0, advFeed)
      },
      onAdClick: (): void => {
        logToast(`onAdClick`)
      },
      onRenderSuccess: (): void => {
        logToast(`onRenderSuccess`)
      },
      onRenderFail: (err: AdvanceError): void => {
        logToast(`onRenderFail , ${err.toString()}`)
      },
      onAdLoadFailed: (err: AdvanceError): void => {
        logToast(`onAdLoadFailed , err = ${err.toString()}`)
      }
    })
    // advFeed.loadStrategy()


  }

  /**
   * 构建广告UI
   */
  build() {
    Row() {
      if (this.errorMsg) {
        Text(this.errorMsg).fontSize(18).fontColor(Color.Red).margin(10);
      }
      List() {
        ForEach(this.listArray, (item: string | AdvanceNativeExpress) => {
          ListItem() {
            if (typeof item === 'string') {
              this.BuildCommonItem(item)
            } else if (item && !this.dislikeStatus) {
              NodeContainer(item.getAdComponent()).width("100%")
            }
          }
          .align(Alignment.Center)
          .backgroundColor((typeof item === 'string') ? Color.Orange : Color.White)
          .width('100%')
          .onDisAppear(() => {
            if (typeof item != 'string') {
              item.destroy(); //释放资源
            }
          })
        }, (item: string | AdvanceNativeExpress, index: number) => {
          return item.toString() + "_" + index
        })
      }.divider({ strokeWidth: 1, color: Color.Gray }).scrollBar(BarState.Off).align(Alignment.Center)

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
        .height(60)
        .width('100%')
        .key("key")
        .textAlign(TextAlign.Center)
        .padding({ top: 5, bottom: 5 })
    }
  }
}