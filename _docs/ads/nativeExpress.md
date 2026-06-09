# Harmony 原生模板信息流广告

**素材类型：图片、视频 || 常见尺寸： 16:9、9:16**
***
<font color=#757575 size=2>**简介：** 平台模板包含多种广告场景：动态信息流/横幅/贴片,在应用的内容流中与应用内容穿插展示</font>

## 1.广告位接口说明
| 方法| 	介绍|
|--------- |---------------| 
| constructor(config: AdvanceAdLoadConfig) |广告位初始化方法 <br>config: 广告位配置类| 
| setAdListener(listener: AdvanceNativeExpressListener) | 设置广告监听回调 |
| loadAd() |加载广告| 
| getAdComponent() |获取广告视图| 

## 2.广告位监听回调
| 回调方法| 	介绍|
|--------- |---------------|  
| onAdLoaded(adInfo: AdvanceAdInfo) | 广告加载成功回调 |  
| onAdLoadFailed(err: AdvanceError) | 广告加载失败回调 |  
| onRenderSuccess() | 广告渲染成功回调 |  
| onRenderFail(err: AdvanceError) | 广告渲染失败回调 | 
| onAdShow() | 广告曝光回调|  
| onAdClick() |广告点击回调|
| onAdClose() |广告关闭回调|
| onVideoPlayStart() |视频开始播放回调|
| onVideoPlayEnd() |视频播放完成回调|
| onVideoPlayFailed(err: AdvanceError) |视频播放失败回调|

## 3.接入代码示例

- <span style="background-color: #297497"><font  color=#FFFFF> 原生模板信息流广告类为AdvanceNativeExpress</font></span>

#### 加载广告
```
// 创建广告请求配置
let config: AdvanceAdLoadConfig = {
    placementId: 'your placement id',
    adWidth: 390,
    adHeight: 0
}
// 创建广告对象
this.nativeExpressAd = new AdvanceNativeExpress(config)
// 设置广告监听
this.nativeExpressAd.setAdListener(this.listener)
// 加载广告
this.nativeExpressAd.loadAd()
```

#### 展示广告
```
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
```


#### 广告回调

```
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
```

