# Harmony 开屏广告 

**素材类型：图片、视频 || 常见尺寸： 2:3、9:16**
***
<font color=#757575 size=2>**简介：** 开屏广告以App启动作为曝光时机，可展示5S的广告。用户可以点击广告跳转到落地面或相应的广告主App内；或者点击右上角的“跳过”按钮，跳转到app主界面，若用户不进行任何点击，则等待广告展示完毕后也会进入您的app主界面。</font>

## 1.广告位接口说明
| 方法| 	介绍|
|--------- |---------------| 
| constructor(config: AdvanceAdLoadConfig) |广告位初始化方法 <br>config: 广告位配置类| 
| setAdListener(listener: AdvanceSplashListener) | 设置广告监听回调 |
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
- <span style="background-color: #297497"><font  color=#FFFFF> 开屏广告类为 AdvanceSplash</font></span>

#### 加载广告
```
// 创建广告请求配置
let config: AdvanceAdLoadConfig = {
    placementId: 'your placement id',
}
// 创建广告对象
this.splashAd = new AdvanceSplash(config)
// 设置广告监听
this.splashAd.setAdListener(this.listener)
// 加载广告
this.splashAd.loadAd()
```

#### 展示广告
```
if (this.splashAd.isAdValid()) {
    this.splashAd.showAd()
}
```

#### 广告回调

```
listener: AdvanceSplashListener = {
    onAdLoaded: (adInfo: AdvanceAdInfo) => {
      logToast(`onAdLoaded, adInfo: ${JSON.stringify(adInfo)}`)
    },
    onAdLoadFailed: (err: AdvanceError) => {
      logToast(`onAdLoadFailed, err: ${err.toString()}`)
      this.splashAd = undefined
    },
    onAdShow: () => {
      logToast(`onAdShow`)
    },
    onAdShowFailed: (error: AdvanceError) => {
      logToast(`onAdShowFailed, err: ${error.toString()}`)
      this.splashAd = undefined
    },
    onAdClick: () => {
      logToast(`onAdClick`)
    },
    onAdClose: () => {
      this.splashAd = undefined
    },
  }
```
