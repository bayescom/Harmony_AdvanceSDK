# Harmony 横幅广告

**素材类型：图片 || 常见尺寸： 7:1、5:2**
***
<font color=#757575 size=2>**简介：** Banner广告(横幅广告)一般呈现在app顶部、中部、底部任意一处，横向贯穿app页面，可在一段时间后自动刷新</font>

## 1.广告位接口说明
| 方法| 	介绍|
|--------- |---------------| 
| constructor(config: AdvanceAdLoadConfig) |广告位初始化方法 <br>config: 广告位配置类| 
| setAdListener(listener: AdvanceBannerListener) | 设置广告监听回调 |
| loadAd() |加载广告| 
| isAdValid() |广告是否有效，建议在展示广告之前判断| 
| getAdComponent() |获取广告视图| 
| getAcceptWidth() |获取广告视图宽度| 
| getAcceptHeight() |获取广告视图高度| 

## 2.广告位监听回调
| 回调方法| 	介绍|
|--------- |---------------|  
| onAdLoaded(adInfo: AdvanceAdInfo) | 广告加载成功回调 |  
| onAdLoadFailed(err: AdvanceError) | 广告加载失败回调 |  
| onAdShow() | 广告曝光回调|  
| onAdShowFailed(error: AdvanceError) |广告展示失败回调|
| onAdClick() |广告点击回调|
| onAdClose() |广告关闭回调|


## 3.接入代码示例

- <span style="background-color: #297497"><font  color=#FFFFF> banner广告类为AdvanceBanner</font></span>
- 横幅广告暂不支持广告自动刷新。

#### 加载广告
```
// 创建广告请求配置
let config: AdvanceAdLoadConfig = {
    placementId: 'your placement id',
    adWidth: 375,
    adHeight: 120
}
// 创建广告对象
this.bannerAd = new AdvanceBanner(config)
// 设置广告监听
this.bannerAd.setAdListener(this.listener)
// 加载广告
this.bannerAd.loadAd()
```

#### 展示广告
```
if (this.isShowAd && this.bannerAd?.isAdValid()) {
    NodeContainer(this.bannerAd?.getAdComponent())
        .width(this.bannerAd?.getAcceptWidth())
        .height(this.bannerAd?.getAcceptHeight())
}
```

#### 广告回调：
```
listener: AdvanceBannerListener = {
    onAdLoaded: (adInfo: AdvanceAdInfo) => {
      logToast(`onAdLoaded, adInfo: ${JSON.stringify(adInfo)}`)
      this.isShowAd = true
    },
    onAdLoadFailed: (err: AdvanceError) => {
      logToast(`onAdLoadFailed, err: ${err.toString()}`)
      this.bannerAd = undefined
    },
    onAdShow: () => {
      logToast(`onAdShow`)
    },
    onAdShowFailed: (error: AdvanceError) => {
      logToast(`onAdShowFailed, err: ${error.toString()}`)
      this.bannerAd = undefined
      this.isShowAd = false
    },
    onAdClick: () => {
      logToast(`onAdClick`)
    },
    onAdClose: () => {
      this.bannerAd = undefined
      this.isShowAd = false
    },
  }
```

