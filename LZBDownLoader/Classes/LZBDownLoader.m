//
//  LZBDownLoader.m
//  LZBDownLoader
//
//  Created by zibin on 2017/7/20.
//  Copyright © 2017年 Apple. All rights reserved.
//

#import "LZBDownLoader.h"
#import "LZBFileManger.h"
#import <Foundation/Foundation.h>

#define kLZBDownLoaderTemp  NSTemporaryDirectory()
#define kLZBDownLoaderCache NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES).firstObject

@interface LZBDownLoader()<NSURLSessionDataDelegate>
{
    long long _tempSize; //临时文件的大小
    long long _totalSize; //请求文件总共的大小
}
/**下载中路径*/
@property (nonatomic, strong) NSString *downLoadingPath;
/**下载完成路径*/
@property (nonatomic, strong) NSString *downLoadedPath;
/**请求会话*/
@property (nonatomic, strong) NSURLSession *session;
/**输出流*/
@property (nonatomic, strong) NSOutputStream *outputStream;
/**请求任务，任务被session引用，所以用weak*/
@property (nonatomic, weak) NSURLSessionDataTask *dataTask;
/**下载失败的error*/
@property (nonatomic, strong) NSError *failError;
//下载的URL
@property (nonatomic, strong) NSURL *url;

//block方式传递事件 同时也可以通过代理方式
@property (nonatomic, copy) DownLoadInfoType downLoadInfoBlock;
@property (nonatomic, copy) DownLoadStateType downLoadStateBlock;
@property (nonatomic, copy) DownLoadProgressType downLoadProgressBlock;
@property (nonatomic, copy) DownLoadSuccessType downLoadSuccessBlock;
@property (nonatomic, copy) DownLoadFailedType downLoadFailedBlock;
@end

@implementation LZBDownLoader

#pragma mark - open API
-(void)downLoadWithURL:(NSURL *)url downLoadInfo:(DownLoadInfoType)downLoadInfoBlock downLoadState:(DownLoadStateType)downLoadStateBlcok progress:(DownLoadProgressType)downLoadProgressBlock success:(DownLoadSuccessType)downLoadSuccessBlcok failed:(DownLoadFailedType)downLoadFailedBlock
{
    self.downLoadInfoBlock = downLoadInfoBlock;
    self.downLoadStateBlock = downLoadStateBlcok;
    self.downLoadProgressBlock = downLoadProgressBlock;
    self.downLoadSuccessBlock = downLoadSuccessBlcok;
    self.downLoadFailedBlock = downLoadFailedBlock;
    [self downLoadWithURL:url];
}

- (void)downLoadWithURL:(NSURL *)url
{
   //1.判断文件路径是否正确
    if(url.absoluteString.length == 0) return;
    self.url = url;
    
    //1.1判断路径任务是否存在，如果存在，继续下载
    if([url isEqual:self.dataTask.originalRequest.URL])
    {
        if(self.state == LZBDownLoaderState_Pause)
        {
            [self resumeCurrentTask];
            return;
        }
    }
    
    //路径不存在  或者路径存在，但是url不相同
   //2.获取文件的路径
    NSString *fileName = url.lastPathComponent;
    self.downLoadingPath = [kLZBDownLoaderTemp stringByAppendingPathComponent:fileName];
    self.downLoadedPath =[kLZBDownLoaderCache stringByAppendingPathComponent:fileName];
    
    //3.判断cache中文件是否存在,如果存在直接返回
    if([LZBFileManger fileIsExitWithPath:self.downLoadedPath])
    {
        //告诉外界文件存在
        self.state = LZBDownLoaderState_DownSuccess;
        return;
    }
    
    //4.如果cache文件不存在，那个从temp文件中寻找,如果temp中不存在
    if(![LZBFileManger fileIsExitWithPath:self.downLoadingPath])
    {
        //不存在，从0开始下载
        [self downLoadWithURL:url offset:0];
        return;
    }
    
    //5.如果temp中存在文件
     // 比较本地文件 与 网络资源文件的大小
     // 本地文件 == 网络资源文件   从temp中移到cache retern
     // 本地文件 > 网络资源文件   从temp中移除，重写加载
     // 本地文件 < 网络资源文件   从temp这个offset加载
    _tempSize = [LZBFileManger fileSizeWithPath:self.downLoadingPath];
    [self downLoadWithURL:url offset:_tempSize];
    
}

//暂停
- (void)pauseCurrentTask
{   //必须是在正在下载中暂停
    if(self.state == LZBDownLoaderState_Downing)
    {
        [self.dataTask suspend];
        self.state = LZBDownLoaderState_Pause;
    }
    
}
//取消
- (void)cancelCurrentTask
{
    [self.session invalidateAndCancel];
    self.session = nil;
    self.state = LZBDownLoaderState_Pause;
}
//取消并清除
- (void)cancelAndClean
{
    [self cancelCurrentTask];
    [LZBFileManger removeFile:self.downLoadingPath];
}
//继续下载
- (void)resumeCurrentTask{
    //必须是在暂停中开始下载
    if(self.dataTask && self.state == LZBDownLoaderState_Pause)
    {
        [self.dataTask resume];
        self.state = LZBDownLoaderState_Downing;
    }
}

#pragma mark - 事件传递
- (void)setState:(LZBDownLoaderState)state
{
    if(_state == state) return;
    _state = state;
    //下载状态事件
    if(self.downLoadStateBlock)
        self.downLoadStateBlock(_state);
    if([self.delgate respondsToSelector:@selector(downLoad:downLoadState:)])
        [self.delgate downLoad:self downLoadState:_state];
    
    //下载成功事件
    if(_state == LZBDownLoaderState_DownSuccess)
    {
          if(self.downLoadSuccessBlock)
              self.downLoadSuccessBlock(self.downLoadedPath);
          if([self.delgate respondsToSelector:@selector(downLoad:downLoadSuccess:)])
              [self.delgate downLoad:self downLoadSuccess:self.downLoadedPath];
    }
    
    //下载失败事件
    if(_state == LZBDownLoaderState_DownFailed)
    {
        if(self.downLoadFailedBlock)
            self.downLoadFailedBlock(self.failError);
        if([self.delgate respondsToSelector:@selector(downLoad:downLoadFailed:)])
            [self.delgate downLoad:self downLoadFailed:self.failError];
    }
    
    //状态改变发出通知
    [[NSNotificationCenter defaultCenter] postNotificationName:kLZBLZBDownLoaderURLAndStateChangeNotification object:nil userInfo:@{@"downLoadURL": self.url,
                              @"downLoadState": @(_state)}];
}
- (void)setProgress:(CGFloat)progress
{
    _progress = progress;
    
    //下载进度
    if(self.downLoadProgressBlock)
        self.downLoadProgressBlock(progress);
    if([self.delgate respondsToSelector:@selector(downLoad:downLoadProgress:)])
        [self.delgate downLoad:self downLoadProgress:progress];
    
}

#pragma mark - NSURLSessionDataDelegate

//第一次接收到响应头数据的时候调用，但是还没有接收到数据，这个可以判断是否运行继续接受数据
- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveResponse:(NSHTTPURLResponse *)response completionHandler:(void (^)(NSURLSessionResponseDisposition))completionHandler
{
    //1.从响应头里面取出文件大小数据，但是 先从Content-Length 中取，让后在Content-Range中取Content-Range比较准确，但是如果没有range,就没有这个字段
    _totalSize = [response.allHeaderFields[@"Content-Length"] longLongValue];
    NSString *contentRangeString = response.allHeaderFields[@"Content-Range"];
    if(contentRangeString.length != 0)
        _totalSize = [[contentRangeString componentsSeparatedByString:@"/"].lastObject longLongValue];
    
    //2.1传递总大小事件
    if(self.downLoadInfoBlock)
        self.downLoadInfoBlock(_totalSize);
    if([self.delgate respondsToSelector:@selector(downLoad:downLoadInfo:)])
        [self.delgate downLoad:self downLoadInfo:_totalSize];
    
    //2.比较数据
    if(_tempSize == _totalSize)
    {
      //1.移动文件到cache
        [LZBFileManger moveFileFromPath:self.downLoadingPath toPath:self.downLoadedPath];
      //2.取消请求
        //NSLog(@"移动文件");
        completionHandler(NSURLSessionResponseCancel);
      //3.下载完成状态
        self.state = LZBDownLoaderState_DownSuccess;
        return;
    }
    
    if(_tempSize > _totalSize)
    {
        //1.删除临时缓存
        [LZBFileManger removeFile:self.downLoadingPath];
        
        //2.重新请求
        [self downLoadWithURL:response.URL offset:0];
        
        //3.取消上一次请求
        //NSLog(@"删除临时缓存");
        completionHandler(NSURLSessionResponseCancel);
        
        return;
    }
    
    
    // 3.临时文件比网络文件小，可以继续接受数据,打开输出流
    self.state = LZBDownLoaderState_Downing;
    [self.outputStream open];
    completionHandler(NSURLSessionResponseAllow);
}

//接受请求的数据,继续接受数据的时候调用
- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data
{
    //计算进度
    _tempSize +=data.length;
    self.progress = 1.0 * _tempSize/_totalSize;
    
    [self.outputStream write:data.bytes maxLength:data.length];
}
// 请求完成的时候调用( != 请求成功/失败)
- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error
{
    if(error == nil)
    {
       //请求成功 文件大小验证 文件完整性验证
        self.state = LZBDownLoaderState_DownSuccess;
    }
    else  //网络问题、请求取消
    {
        if(error.code == -999)
        {
            self.state = LZBDownLoaderState_Pause;
        }
        else
        {
            self.failError = error;
            self.state = LZBDownLoaderState_DownFailed;
        }
        
    }
    [self.outputStream close];
}



#pragma mark- pravite

/**
  从某个点开始下载文件

 @param url 文件路径
 @param offset 从那个点下载
 */
- (void)downLoadWithURL:(NSURL *)url offset:(long long)offset{
     //1.创建请求
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:0];
    //2.设置请求范围
    [request setValue:[NSString stringWithFormat:@"bytes=%lld-", offset] forHTTPHeaderField:@"Range"];
    
    //3.创建请求任务
    self.dataTask = [self.session dataTaskWithRequest:request];
    
    //4.开始请求
    [self resumeCurrentTask];
}

#pragma mark - lazy

- (NSURLSession *)session
{
  if(_session == nil)
  {
      NSURLSessionConfiguration *config = [NSURLSessionConfiguration  defaultSessionConfiguration];
      _session = [NSURLSession sessionWithConfiguration:config delegate:self delegateQueue:[NSOperationQueue mainQueue]];
  }
    return _session;
}
- (NSOutputStream *)outputStream
{
   if(_outputStream == nil)
   {
       _outputStream = [NSOutputStream outputStreamToFileAtPath:self.downLoadingPath append:YES];
   }
    return _outputStream;
}
@end
