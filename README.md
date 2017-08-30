# LZBDownLoader

[![CI Status](http://img.shields.io/travis/lzbgithubcode/LZBDownLoader.svg?style=flat)](https://travis-ci.org/lzbgithubcode/LZBDownLoader)
[![Version](https://img.shields.io/cocoapods/v/LZBDownLoader.svg?style=flat)](http://cocoapods.org/pods/LZBDownLoader)
[![License](https://img.shields.io/cocoapods/l/LZBDownLoader.svg?style=flat)](http://cocoapods.org/pods/LZBDownLoader)
[![Platform](https://img.shields.io/cocoapods/p/LZBDownLoader.svg?style=flat)](http://cocoapods.org/pods/LZBDownLoader)

## 简单介绍

LZBDownLoader是一个单个下载器，LZBDownLoaderManger管理多个下载器，您可以直接使用下载器下载音频、视频、文件资源，代码侵入性小、耦合低。

* 支持单个任务下载
* 支持多任务下载管理
* 可以下载音频、视频、文件资源
* 下载文件采用MD5加密保存

## 类的介绍
* LZBDownLoaderManger  多个下载器管理
* LZBDownLoader  单个下载器管理
* LZBFileManger  下载文件管理
* NSString+LZBEncrypt  文件加密保存分类

## 使用CocoaPods导入

```ruby
pod "LZBDownLoader"
```

## 手动导入

将`LZBDownLoader`文件夹中的所有源代码拽入项目中

导入主头文件：`#import "LZBDownLoaderManger.h"`


##可以使用的方法

* 单个下载器LZBDownLoader,代理、block两种方式具体事件传递和状态传递

```objc
//状态改变通知 传递URL 和状态@"downLoadURL" @"downLoadState"

#define kLZBLZBDownLoaderURLAndStateChangeNotification @"LZBLZBDownLoaderURLAndStateChangeNotification"
typedef NS_ENUM(NSInteger,LZBDownLoaderState)
{
LZBDownLoaderState_Pause = 0, //暂停
LZBDownLoaderState_Downing = 1, //下载中
LZBDownLoaderState_DownSuccess = 2, //下载成功
LZBDownLoaderState_DownFailed = 3, //下载失败
};
//下载总大小
typedef void(^DownLoadInfoType)(long long totalSize);
//下载状态
typedef void(^DownLoadStateType)(LZBDownLoaderState state);
//下载进度
typedef void(^DownLoadProgressType)(CGFloat progress);
//下载成功
typedef void(^DownLoadSuccessType)(NSString *cachePath);
//下载失败
typedef void(^DownLoadFailedType)(NSError *error);



@protocol LZBDownLoaderDelegate <NSObject>

/**下载总大小*/
- (void)downLoad:(LZBDownLoader *)downLoader downLoadInfo:(long long)totalSize;
/**下载状态*/
- (void)downLoad:(LZBDownLoader *)downLoader downLoadState:(LZBDownLoaderState)state;
/**下载进度*/
- (void)downLoad:(LZBDownLoader *)downLoader downLoadProgress:(CGFloat)progress;
/**下载成功*/
- (void)downLoad:(LZBDownLoader *)downLoader downLoadSuccess:(NSString *)cachePath;
/**下载失败*/
- (void)downLoad:(LZBDownLoader *)downLoader downLoadFailed:(NSError *)error;
@end

@interface LZBDownLoader : NSObject

/**
下载文件方法
*/
- (void)downLoadWithURL:(NSURL *)url downLoadInfo:(DownLoadInfoType)downLoadInfoBlock downLoadState:(DownLoadStateType)downLoadStateBlcok progress:(DownLoadProgressType)downLoadProgressBlock success:(DownLoadSuccessType)downLoadSuccessBlcok failed:(DownLoadFailedType)downLoadFailedBlock;
/**
下载文件

@param url 文件的URL路径
*/
- (void)downLoadWithURL:(NSURL *)url;

/**
暂停当前的任务
*/
- (void)pauseCurrentTask;

/**
继续下载的任务
*/
- (void)resumeCurrentTask;

/**
取消当前的任务
*/
- (void)cancelCurrentTask;

/**
取消任务并清除临时下载的文件
*/
- (void)cancelAndClean;

/**下载状态*/
@property (nonatomic, assign, readonly) LZBDownLoaderState state;

/**下载进度*/
@property (nonatomic, assign, readonly) CGFloat progress;

/**下载代理*/
@property (nonatomic, weak) id <LZBDownLoaderDelegate>delgate;


```

* 多任务下载管理类LZBDownLoaderManger

```objc

//单例
+ (instancetype)shareInstance;


/**
根据URL下载资源

@param url url
@return 下载器
*/
- (LZBDownLoader *)downLoadWithURL:(NSURL *)url;


// 获取url对应的downLoader
- (LZBDownLoader *)getDownLoaderWithURL: (NSURL *)url;

//下载文件
- (LZBDownLoader *)downLoadWithURL:(NSURL *)url downLoadInfo:(DownLoadInfoType)downLoadInfoBlock downLoadState:(DownLoadStateType)downLoadStateBlcok progress:(DownLoadProgressType)downLoadProgressBlock success:(DownLoadSuccessType)downLoadSuccessBlcok failed:(DownLoadFailedType)downLoadFailedBlock;


/**
暂停某个URL任务
*/
- (void)pauseWithURL:(NSURL *)url;

/**
取消某个URL任务
*/
- (void)resumeWithURL:(NSURL *)url;

/**
取消某个URL任务
*/
- (void)cancelWithURL:(NSURL *)url;

/**
暂停所有任务
*/
- (void)pauseAllURL;

/**
继续所有任务
*/
- (void)resumeAllURL;

/**
取消所有任务
*/
- (void)cancelAllURL;


```

## 联系作者
* QQ : 1835064412
* 简书：[摸着石头过河_崖边树](http://www.jianshu.com/u/268ed1ef819e)
* email:1835064412@qq.com

## Author

lzbgithubcode, 1835064412@qq.com

## 期待
* 如果在使用过程中遇到BUG，希望你能联系我，谢谢
* 如果您觉得这个这个demo对您有所帮助，请给我一颗❤️❤️,star一下
* 如果你想了解更多的开源姿势，可以关注公众号‘开发者源代码’

![image](https://github.com/lzbgithubcode/LZBDownLoader/raw/master/screenshotImage/developerCoder08.jpg)

