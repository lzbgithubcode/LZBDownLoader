//
//  LZBDownLoader.h
//  LZBDownLoader
//
//  Created by zibin on 2017/7/20.
//  Copyright © 2017年 Apple. All rights reserved.
////一个下载器一个URL

#import <Foundation/Foundation.h>
#import <AVKit/AVKit.h>
@class LZBDownLoader;
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


@end
