import { logToast } from '../../util/Toast';
import { AdvanceError, AdvanceNativeExpress, AdvanceAdLoadConfig, AdvanceAdInfo,
  AdvanceNativeExpressListener } from 'advancesdk'
import { router } from '@kit.ArkUI';

@Entry
@Component
export struct NativeExpress {
  @State private listArray: Array<string | AdvanceNativeExpress> = new Array();
  private placementId: string = ''
  nativeExpressAd?: AdvanceNativeExpress = undefined

  aboutToAppear(): void {
    let params: object = router.getParams()
    let recordObj: Record<string, string> = params as Record<string, string>;
    this.placementId = recordObj["placementId"]
    // 模拟正常信息流内容
    for (let index = 0; index < 20; index++) {
      this.listArray.push(`测试item：${index}`)
    }
    // 加载广告
    this.loadNativeExpressAd()
  }

  listener: AdvanceNativeExpressListener = {
    onAdLoaded: (adInfo: AdvanceAdInfo) => {
      logToast(`onAdLoaded, adInfo: ${JSON.stringify(adInfo)}`)
    },
    onAdLoadFailed: (err: AdvanceError): void => {
      logToast(`onAdLoadFailed , err = ${err.toString()}`)
      this.nativeExpressAd = undefined
    },
    onRenderSuccess: (): void => {
      logToast(`onRenderSuccess`)
      // 在指定位置插入当前信息流对象
      if (this.nativeExpressAd) {
        this.listArray.splice(2, 0, this.nativeExpressAd)
      }
    },
    onRenderFail: (err: AdvanceError): void => {
      logToast(`onRenderFail , ${err.toString()}`)
      this.nativeExpressAd = undefined
    },
    onAdShow: (): void => {
      logToast(`onAdShow`)
    },
    onAdClick: (): void => {
      logToast(`onAdClick`)
    },
    onAdClose: () => {
      this.listArray.splice(2, 1); // 从数组中移除数据
      this.nativeExpressAd = undefined
    },
    onVideoPlayEnd: () => {
      logToast(`onAdVideoEnd`)
    }
  }

  loadNativeExpressAd(): void {
    let config: AdvanceAdLoadConfig = {
      placementId: this.placementId,
      adWidth: 390,
      adHeight: 0
    }
    this.nativeExpressAd = new AdvanceNativeExpress(config)
    this.nativeExpressAd.setAdListener(this.listener)
    this.nativeExpressAd.loadAd()
  }

  /**
   * 构建广告UI
   */
  build() {
    Row() {
      List() {
        ForEach(this.listArray, (item: string | AdvanceNativeExpress) => {
          ListItem() {
            if (typeof item === 'string') {
              this.BuildCommonItem(item)
            } else if (item) {
              NodeContainer(item.getAdComponent())
                .width("100%")
            }
          }
          .align(Alignment.Center)
          .backgroundColor((typeof item === 'string') ? Color.Orange : Color.White)
          .width('100%')
        }, (item: string | AdvanceNativeExpress, index: number) => {
          return item.toString() + "_" + index
        })
      }
      .divider({ strokeWidth: 1, color: Color.Gray })
      .scrollBar(BarState.Off)
      .align(Alignment.Center)

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
        .height(100)
        .width('100%')
        .key("key")
        .textAlign(TextAlign.Center)
        .padding({ top: 30, bottom: 30 })
    }
  }
}