//
//  LZBDownLoaderManger.h
//  LZBDownLoader
//
//  Created by zibin on 2017/7/23.
//  Copyright © 2017年 Apple. All rights reserved.
//多个下载器管理，当个下载器管理使用LZBDownLoader

#import <Foundation/Foundation.h>
#import "LZBDownLoader.h"

@interface LZBDownLoaderManger : NSObject

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
@end
