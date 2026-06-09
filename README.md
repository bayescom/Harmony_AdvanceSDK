# AdvanceSDK
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
![Platform](https://img.shields.io/badge/Platform-HarmonyOS-007D9C)

# 私有化部署改动内容

将 AdvanceSDK 转自用，可能需要进行替换更新内容如下：

1.请求策略地址：修改全局字符串变量 baseUrl 和 baseUrlHttps 链接地址为自己的请求地址即可，也就是[**Stella**](https://github.com/bayescom/EasyAds-Pro_Stella)项目搭建的私有化服务的请求地址：http://yourdomain.com/stella

2.请求加密key：全局搜索**BYSecurity**类名，修改其中的**SECRET_KEY**为自己的key，key需要是16位字符串

# AdvanceSDK对接文档-Harmony

本文档为AdvanceSDK接入参考文档。用户可以参考Demo工程中的配置以及各广告位接入代码进行开发。

目前聚合的广告平台有：倍业，广点通，穿山甲，快手，华为。

## 目前AdvanceSDK支持统一管理的广告位类型为：

- [开屏广告位(Splash)](./_docs/ads/splash.md)
- [横幅广告位(Banner)](./_docs/ads/banner.md)
- [插屏广告位（Interstitial)](./_docs/ads/interstitial.md)
- [激励视频(RewardVideo)](./_docs/ads/reward.md)
- [原生模板信息流广告位(NativeExpress)](./_docs/ads/nativeExpress.md)
- [原生自渲染信息流广告位(RenderFeed)](./_docs/ads/renderFeed.md)


## SDK集成

- 下载demo工程，打开根目录，保留advancesdk核心代码库以及您所需要的渠道adapter代码库（mercury_adapter为必须），将需要的文件拖入advance文件目录（新建）并copy到您的工程根目录。
- 在工程根目录的 build-profile.json5 中添加SDK代码库模块并启用标准化的 OHMUrl 格式：
```
    "modules": [
    {
      "name": "entry",
       ...
       ...
    },
    {
      "name": "advancesdk",
      "srcPath": "./advance/advancesdk"
    },
    {
      "name": "csj_adapter",
      "srcPath": "./advance/csj_adapter"
    },
    {
      "name": "gdt_adapter",
      "srcPath": "./advance/gdt_adapter",
    },
    {
      "name": "ks_adapter",
      "srcPath": "./advance/ks_adapter",
    },
    {
      "name": "mercury_adapter",
      "srcPath": "./advance/mercury_adapter",
    },
    {
      "name": "huawei_adapter",
      "srcPath": "./advance/huawei_adapter",
    }
  ]
```
```
    "products": [
      {
        "buildOption": {
          "strictMode": {
            "useNormalizedOHMUrl": true  // 启用标准化的模块寻址方式
          }
        }
      }
    ]
```
- 在应用主module的 oh-package.json5 中添加adapter的依赖配置：
```
    "dependencies": {
        "advancesdk": "file:../advance/advancesdk",
        "csj_adapter": "file:../advance/csj_adapter",
        "gdt_adapter": "file:../advance/gdt_adapter",
        "ks_adapter": "file:../advance/ks_adapter",
        "mercury_adapter": "file:../advance/mercury_adapter",
        "huawei_adapter": "file:../advance/huawei_adapter"
    }
```
- 在上一步骤中的module下的 build-profile.json5 中添加以下配置:
```
    "buildOption": {
    "arkOptions": {
      "runtimeOnly": {
        "packages": [
          "csj_adapter",
          "gdt_adapter",
          "ks_adapter",
          "mercury_adapter",
          "huawei_adapter"
        ]
      }
    }
  }
```
 

**********************

## 添加权限
广告依赖部分设备信息进行转化，需要媒体在module.json5文件中添加以下权限：
```
    "requestPermissions": [
      {
        "name": "ohos.permission.INTERNET", //访问网络  必选
      },
      {
        "name": 'ohos.permission.APP_TRACKING_CONSENT',
      },
      {
        "name": 'ohos.permission.APPROXIMATELY_LOCATION',
      },
      {
        "name": 'ohos.permission.GET_WIFI_INFO',
      },
      {
        "name": 'ohos.permission.GET_NETWORK_INFO',
      }
]
```

| 权限名称 | 说明 | 用途 | 必要性 |
| ---- | ---- | ---- | ---- |
|ohos.permission.INTERNET|'允许使用Internet网络' | SDK用于网络请求 | 必选 |
|ohos.permission.APP_TRACKING_CONSENT|'允许应用读取开放匿名设备标识符' | SDK用于获取oaid；影响转化 | 可选 |
|ohos.permission.GET_WIFI_INFO|'允许应用获取Wi-Fi信息' | SDK用于判断设备连接wifi状态 | 可选 |
|ohos.permission.GET_NETWORK_INFO|'允许应用获取Network信息' | SDK检查蜂窝数据业务是否启用 | 可选 |
|ohos.permission.APPROXIMATELY_LOCATION|'允许应用获取设备模糊位置信息' | SDK用于获取经纬度 | 可选 |

**********************

## 初始化SDK

<span style="background-color: #297497"><font  color=#FFFFF>appId必须要在具体广告位初始化之前设置</font></span>

```
onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    let ctx = this.context
    AdvanceSDK.debug()
    //初始化SDK
    AdvanceSDK.initSDK(ctx, 'your appId')
}
```

## 接入代码
您可以点击上述支持的广告位类型进行查看具体广告位的对接代码，也可以运行自带的Demo工程，参考Demo工程中的接入代码进行开发。

## 验收测试
代码对接完成后请提供测试包给我方对接测试人员进行验收。
