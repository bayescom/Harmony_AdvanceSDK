# Harmony 自渲染信息流广告

**素材类型：图片、视频 || 常见尺寸： 16:9、9:16**
***
<font color=#757575 size=2>**简介：** 自渲染广告在原生广告中是相对比较高级的用法，开发者可获取广告的所有素材内容进行自定义布局的广告渲染。一般开发者会嵌套在产品自身的布局中实现。</font>

## 1.广告位接口说明
| 方法| 	介绍|
|--------- |---------------| 
| constructor(config: AdvanceAdLoadConfig) |广告位初始化方法 <br>config: 广告位配置类| 
| setAdListener(listener: AdvanceRenderFeedListener) | 设置广告监听回调 |
| loadAd() |加载广告| 

## 2.广告包装类对象说明(AdvanceRenderFeedWrapper)
| 方法| 	介绍|
|--------- |---------------|  
|getTitle() |获取广告标题| 
|getDescription() |获取广告描述| 
|getButtonText() |广告创意按钮文案| 
|getIconUrl() |获取广告Icon| 
|getImageUrlList |获取图片列表-url| 
|isVideoAd |是否为视频广告| 
|getAdLogoView |获取广告角标Logo| 
|getAdComponent |获取视频组件| 
|registerViewForInteraction(uiContext: UIContext, rootViewId: string, clickableViewIds:string[]) |用于注册交互事件，包括曝光和点击等操作| 
|getClickHandler() |控件点击监听回调对象| 
|getVisibleAreaRatios() |获取可⻅区域监听数组| 
|getVisibleAreaChangeListener() |可见区域监听方法，用于SDK内部判断页面展示比例，处理广告曝光&视频播放等| 



## 3.广告位监听回调
| 回调方法| 	介绍|
|--------- |---------------|  
| onAdLoaded(adInfo: AdvanceAdInfo) | 广告加载成功回调 |  
| onAdLoadFailed(err: AdvanceError) | 广告加载失败回调 |  
| onRenderSuccess() | 广告渲染成功回调 |  
| onRenderFail(err: AdvanceError) | 广告渲染失败回调 | 
| onAdShow() | 广告曝光回调|  
| onAdClick() |广告点击回调|
| onVideoPlayStart() |视频开始播放回调|
| onVideoPlayEnd() |视频播放完成回调|
| onVideoPlayFailed(err: AdvanceError) |视频播放失败回调|


## 4.接入代码示例

- <span style="background-color: #297497"><font  color=#FFFFF> 自渲染信息流广告类为AdvanceRenderFeed</font></span>
- 请设置广告容器组件rootId。
- 对于需要点击的组件，请设置组件Id，并在组件的`onClick`回调中实现`getClickHandler()`。
- 请在容器组件的`onAppear`回调中注册交互计费事件`registerViewForInteraction`，并在`onVisibleAreaChange`回调中添加可见区域监听`getVisibleAreaChangeListener()`。
- 开发者自行处理广告关闭逻辑，需要将广告对象移除并执行销毁操作。

#### 加载广告
```
// 创建广告请求配置
let config: AdvanceAdLoadConfig = {
    placementId: 'your placement id',
}
// 创建广告对象
this.renderFeedAd = new AdvanceRenderFeed(config)
// 设置广告监听
this.renderFeedAd.setAdListener(this.listener)
// 加载广告
this.renderFeedAd.loadAd()
```

#### 创建视图
```
List() {
    ForEach(this.listArray, (item: string | AdvanceRenderFeedWrapper) => {
        ListItem() {
            if (typeof item === 'string') {
              this.BuildCommonItem(item)
            } else if (item) {
              this.buildAdLayout(item);
    }
}
```

```
buildAdLayout(wrapper: AdvanceRenderFeedWrapper, clickViewIds: string[] = new Array<string>(), rootViewId: string = util.generateRandomUUID()) {
    Column() {
      Row() {
        Row() {
          //广告主Icon
          Image(wrapper.getIconUrl())
            .height(32)
            .width(32)
            .id(this.generateViewId(clickViewIds)) //设置组件Id，需要全局保证唯一性，涉及计费
            .onClick(event => { //控件点击监听
              wrapper.getClickHandler()(event)
            })
            ...
            ...
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

      //视频|图片区域
      Stack({ alignContent: Alignment.BottomStart }) {
        if (wrapper.isVideoAd()) {
          NodeContainer(wrapper.getAdComponent())
        } else if (wrapper.getImageUrlList().length > 0) {
          this.buildImageLayout(wrapper, clickViewIds)
        }
      }
      .width('100%')
      .aspectRatio(16 / 9)
        
      ...
      ...
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
```
```
// 广告关闭操作
onAdClose() {
    this.listArray.splice(2, 1); // 从数组中移除数据
    this.renderFeedAd?.destroyAdapters()
    this.renderFeedAd = undefined
}
```

#### 广告回调

```
listener: AdvanceRenderFeedListener = {
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
  }
```

