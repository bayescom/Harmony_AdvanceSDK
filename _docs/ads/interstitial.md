# Harmony 插屏广告

**素材类型：图片、视频 || 常见尺寸： 9:16、1:1**
***
<font color=#757575 size=2>**简介：** 插屏广告在App流程中弹出，当App展示插屏广告时，用户可以点击广告，访问其落地页或广告主App，也可以将其关闭，返回应用。 </font>


## 1.广告位接口说明
| 方法| 	介绍|
|--------- |---------------| 
| constructor(config: AdvanceAdLoadConfig) |广告位初始化方法 <br>config: 广告位配置类| 
| setAdListener(listener: AdvanceInterstitialListener) | 设置广告监听回调 |
| loadAd() |加载广告| 
| showAd(windowStage?: window.WindowStage) | 展示广告 <br>windowStage: 传入窗口管理器| 
| isAdValid() |广告是否有效，建议在展示广告之前判断| 

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

- <span style="background-color: #297497"><font  color=#FFFFF> 插屏广告类为AdvanceInterstitial</font></span>

#### 加载广告
```
// 创建广告请求配置
let config: AdvanceAdLoadConfig = {
    placementId: 'your placement id',
}
// 创建广告对象
this.interstitialAd = new AdvanceInterstitial(config)
// 设置广告监听
this.interstitialAd.setAdListener(this.listener)
// 加载广告
this.interstitialAd.loadAd()
```

#### 展示广告
```
if (this.interstitialAd.isAdValid()) {
    this.interstitialAd.showAd()
}
```

#### 广告回调
```
listener: AdvanceInterstitialListener = {
    onAdLoaded: (adInfo: AdvanceAdInfo) => {
      logToast(`onAdLoaded, adInfo: ${JSON.stringify(adInfo)}`)
    },
    onAdLoadFailed: (err: AdvanceError) => {
      logToast(`onAdLoadFailed, err: ${err.toString()}`)
      this.interstitialAd = undefined
    },
    onAdShow: () => {
      logToast(`onAdShow`)
    },
    onAdShowFailed: (error: AdvanceError) => {
      logToast(`onAdShowFailed, err: ${error.toString()}`)
      this.interstitialAd = undefined
    },
    onAdClick: () => {
      logToast(`onAdClick`)
    },
    onAdClose: () => {
      this.interstitialAd = undefined
    },
  }
```
