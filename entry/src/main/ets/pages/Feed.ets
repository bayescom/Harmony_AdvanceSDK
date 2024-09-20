import { AdvanceFeed } from 'advSDK'
import { AdvanceOption } from 'advSDK/src/main/ets/bayes/advance/config/AdvanceOption';
import { AdvanceDislike } from 'advSDK/src/main/ets/bayes/advance/core/AdvanceDislike';
import { AdvanceError } from 'advSDK/src/main/ets/bayes/advance/model/AdvanceError';
import { AdvanceSupplier } from 'advSDK/src/main/ets/bayes/advance/model/AdvanceSupplier';
import { logToast } from '../util/Toast';

@Entry
@Component
export struct Feed {
  @State private listArray: Array<string | AdvanceFeed> = new Array();
  @State private errorMsg: string | undefined = undefined;
  @State private dislikeStatus: boolean = false;

  aboutToAppear(): void {
    for (let index = 0; index < 20; index++) {
      this.listArray.push(`测试item：${index}`)
    }

    let op = new AdvanceOption('10011073')
    // op.widthVP = 390
    // op.heightVP = 0
    let advFeed = new AdvanceFeed(op)
    advFeed.setListener({
      onShow: (): void => {
        logToast(`onShow`)
      },
      onDislike: (dislike: AdvanceDislike): void => {
        logToast(`onDislike , dislike = ${JSON.stringify(dislike)}`)
      },
      onLoaded: (supplier: AdvanceSupplier): void => {
        logToast(`onLoaded , supplier : ${JSON.stringify(supplier)}`)
        advFeed.render(this.getUIContext())
        //插入当前信息流对象
        this.listArray.splice(3, 0, advFeed)
      },
      onClick: (): void => {
        logToast(`onClick`)
      },
      onRenderSuccess: (): void => {
        logToast(`onRenderSuccess`)
      },
      onRenderFail: (err: AdvanceError): void => {
        logToast(`onRenderFail , ${err.toString()}`)
      },
      onError: (err: AdvanceError): void => {
        logToast(`onError , err = ${err.toString()}`)
      }
    })
    advFeed.loadStrategy()


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
        ForEach(this.listArray, (item: string | AdvanceFeed) => {
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
        }, (item: string | AdvanceFeed, index: number) => {
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
        .height(50)
        .width('100%')
        .key("key")
        .textAlign(TextAlign.Center)
        .padding({ top: 5, bottom: 5 })
    }
  }
}