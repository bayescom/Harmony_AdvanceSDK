# Harmony 激励视频广告

**素材类型：一图一视频 || 常见尺寸： 9:16、2:1**
***
<font color=#757575 size=2>**简介：** 激励视频广告是指将短视频融入到app的业务场景当中，成为app“任务”之一，用户观看短视频广告后可以得到一些应用内奖励</font>


## 1.广告位接口说明
| 方法| 	介绍|
|--------- |---------------| 
| constructor(config: AdvanceAdLoadConfig) |广告位初始化方法 <br>config: 广告位配置类| 
| setAdListener(listener: AdvanceRewardVideoListener) | 设置广告监听回调 |
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
| onAdRewardSuccess(rewardInfo: AdvRewardCallbackInfo) |奖励发放成功回调|
| onAdServerRewardFail(error: AdvanceError) |服务端验证奖励失败回调|
| onVideoPlayEnd() |视频播放完成回调|

## 3.接入代码示例

- <span style="background-color: #297497"><font  color=#FFFFF> 激励视频广告类为AdvanceRewardVideo</font></span>

#### 加载广告
```
// 奖励设置（可选）
const model: AdvRewardVideoModel = {
    userId: '123456',
    rewardAmount: 100,
    rewardName: '福利',
    extra: JSON.stringify({"key1": "value1"}) // 透传参数
}
// 创建广告请求配置
let config: AdvanceAdLoadConfig = {
    placementId: 'your placement id',
    rewardVideoModel: model
}
// 创建广告对象
this.rewardVideoAd = new AdvanceRewardVideo(config)
// 设置广告监听
this.rewardVideoAd.setAdListener(this.listener)
// 加载广告
this.rewardVideoAd.loadAd()
```

#### 展示广告
```
if (this.rewardVideoAd.isAdValid()) {
    this.rewardVideoAd.showAd()
}
```

#### 广告回调

```
listener: AdvanceRewardVideoListener = {
    onAdLoaded: (adInfo: AdvanceAdInfo) => {
      logToast(`onAdLoaded, adInfo: ${JSON.stringify(adInfo)}`)
    },
    onAdLoadFailed: (err: AdvanceError) => {
      logToast(`onAdLoadFailed, err: ${err.toString()}`)
      this.rewardVideoAd = undefined
    },
    onAdShow: () => {
      logToast(`onAdShow`)
    },
    onAdShowFailed: (error: AdvanceError) => {
      logToast(`onAdShowFailed, err: ${error.toString()}`)
      this.rewardVideoAd = undefined
    },
    onAdClick: () => {
      logToast(`onAdClick`)
    },
    onAdClose: () => {
      this.rewardVideoAd = undefined
    },
    onAdRewardSuccess: (rewardInfo: AdvRewardCallbackInfo) => {
      logToast(`onAdRewardSuccess`)
    },
    onAdServerRewardFail: (error: AdvanceError) => {
      logToast(`onAdServerRewardFail`)
    },
    onVideoPlayEnd: () => {
      logToast(`onVideoPlayEnd`)
    }
  }
```

## 4.服务端激励验证说明
为满足开发者对激励视频奖励发放加强校验的需求，Advance为开发者提供服务端回调功能，开发者可依照此文档进行相关配置，基于此功能开发者可在服务端对观看激励视频用户是否发放奖励进行二次校验。

### 4.1 使用Advance聚合服务端激励配置

在倍联后台，创建**聚合**激励视频广告位时，需选中**服务端激励回调**，填入回调地址信息，同时广告平台的激励id需要选中**客户端回调**方式，以避免多次发起服务端验证。

开发者在代码中通过聚合SDK的API 传入UserID(用户唯一ID)和用户自定义数据，这些参数最终将通过回调URL 回传给开发者 （参考第二部分代码示例）

当客户端播放激励视频广告，触发激励发放时，首先由广告SDK通过客户端回调方式回调激励达成事件，聚合SDK收到激励达成事件后，会通过Advance服务器请求开发者配置在**倍联后台的服务端激励回调url**（APP服务端和Advance服务端之间的具体交互说明可参考 4.2 中内容），拿到结果后再通过`onAdRewardSuccess: (rewardInfo: AdvRewardCallbackInfo)`或者`onAdServerRewardFail: (error: AdvanceError)` 回调形式告诉开发者。


* AdvRewardCallbackInfo 信息内容详解

| 成员 | 类型 | 含义
|:------------- |:--------------- |:---------------|  
| sourceId | String |SDK渠道id
|rewardAmount | int | 激励数量
|rewardName | String |激励名称

### 4.2 APP服务端接收Advance服务器回调说明

1）开发者需选择了**Advance聚合服务端激励**方式，并设置开发者服务端激励的回调URL，如下图所示：

![聚合服务端激励配置](../../common/image/advance_reward_callback_setting.jpg)

2）Advance服务器会将通过**GET**方式请求开发者的回调URL，并同时拼接携带以下参数在url链接中

| 字段名称           | 数据类型         | 用途说明                                                    |
|----------------|--------------|---------------------------------------------------------|
| secret         | String       | 广告位和秘钥的签名，开发者用于验证回调的正确性                                 |
| timestamp      | Long         | 当前时间戳                                                   |
| user_id        | String       | 用户id，由开发者通过Advance SDK API设置                            |
| extra          | String       | 用户业务参数, 由开发者通过Advance SDK API设置                         |
| reward_amount  | int          | 激励数量，开发者传入或后台配置                                         |
| reward_name    | String       | 激励名称，开发者传入或后台配置                                         |
| trans_id       | String       | 聚合SDK生成唯一id标识，等效于reqid，（开发者通过广告位实例调用`getAdvanceId()`获取） |
| placement_id   | String       | advance聚合广告位id                                          |
| adn_channel_id | String       | 广告SDK平台id标识                                             |
| adn_adspot_id  | String       | 广告SDK平台得广告位id                                           |

3）签名验证说明

开发者需要使用以下规则对回调参数进行签名验证，确保回调的正确性。
使用请求的广告位id和系统中的秘钥进行签名，签名规则如下：广告位id、secret、timestamp拼接成的字符串进行MD5加密，生成32位小写字符串。

例如：

广告位id为：10001000
秘钥为：1234567890abcdef
时间戳：1761212009000
签名结果是：e2c13093a71a09cf0821c161282534cc

4）验证结果约定

开发者回调URL收到Advance的服务端激励回调后，需给服务器返回**success**或者**fail**，表示激励验证结果。 Advance的服务端收到success或者fail后，将不会重发服务端激励回调。
Advance服务器发起服务端激励回调后2秒内无响应则视为超时，超时后会每隔一会（比如2秒，4秒）重试发送激励回调。最大重试3次还超时，则不再向开发者回调URL发起激励回调。