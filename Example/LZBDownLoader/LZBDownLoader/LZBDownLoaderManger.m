//
//  LZBDownLoaderManger.m
//  LZBDownLoader
//
//  Created by zibin on 2017/7/23.
//  Copyright © 2017年 Apple. All rights reserved.
//

#import "LZBDownLoaderManger.h"
#import "NSString+LZBEncrypt.h"
static LZBDownLoaderManger *_instance;

@interface LZBDownLoaderManger()<NSCopying,NSMutableCopying>
@property (nonatomic, strong) NSMutableDictionary *downLoaderDictionary;
@end
@implementation LZBDownLoaderManger

- (LZBDownLoader *)downLoadWithURL:(NSURL *)url
{
  LZBDownLoader *downLoader =  [self downLoadWithURL:url downLoadInfo:nil downLoadState:nil progress:nil success:^(NSString *cachePath) {
        
    } failed:^(NSError *error) {
        
    }];
    return downLoader;
}

- (LZBDownLoader *)getDownLoaderWithURL: (NSURL *)url {
    NSString *urlMD5 = [url.absoluteString md5];
    LZBDownLoader *downLoader = [self.downLoaderDictionary valueForKey:urlMD5];
    return downLoader;
}



- (LZBDownLoader *)downLoadWithURL:(NSURL *)url downLoadInfo:(DownLoadInfoType)downLoadInfoBlock downLoadState:(DownLoadStateType)downLoadStateBlcok progress:(DownLoadProgressType)downLoadProgressBlock success:(DownLoadSuccessType)downLoadSuccessBlcok failed:(DownLoadFailedType)downLoadFailedBlock
{
    
    //1.检测URL对应的下载器是否已经开始
    NSString *urlMD5 = [url.absoluteString md5];
    LZBDownLoader *downLoader = [self.downLoaderDictionary valueForKey:urlMD5];
    if(downLoader){
        [downLoader resumeCurrentTask];
        return  downLoader;
    }
    downLoader = [[LZBDownLoader alloc]init];
    [self.downLoaderDictionary setValue:downLoader forKey:urlMD5];
    
    //2.开启下载
    __weak typeof(self) weakSelf = self;
     [downLoader downLoadWithURL:url downLoadInfo:downLoadInfoBlock downLoadState:downLoadStateBlcok progress:downLoadProgressBlock success:^(NSString *cachePath) {
         
         //拦截block，下载成功之后要移除url
         [weakSelf.downLoaderDictionary removeObjectForKey:urlMD5];
         
          if(downLoadSuccessBlcok)
              downLoadSuccessBlcok(cachePath);
     } failed:^(NSError *error) {
         //拦截block，下载成功之后要移除url
         [weakSelf.downLoaderDictionary removeObjectForKey:urlMD5];
         if(downLoadFailedBlock)
             downLoadFailedBlock(error);
         
     }];
    return downLoader;
}

- (void)pauseWithURL:(NSURL *)url
{
    if(url.absoluteString.length == 0) return;
    NSString *urlMD5 = url.absoluteString.md5;
    LZBDownLoader *loader = [self.downLoaderDictionary valueForKey:urlMD5];
    [loader pauseCurrentTask];
}

- (void)resumeWithURL:(NSURL *)url
{
    if(url.absoluteString.length == 0) return;
    NSString *urlMD5 = url.absoluteString.md5;
    LZBDownLoader *loader = [self.downLoaderDictionary valueForKey:urlMD5];
    [loader resumeCurrentTask];
}

- (void)cancelWithURL:(NSURL *)url
{
    if(url.absoluteString.length == 0) return;
    NSString *urlMD5 = url.absoluteString.md5;
    LZBDownLoader *loader = [self.downLoaderDictionary valueForKey:urlMD5];
    [loader cancelCurrentTask];
}

- (void)pauseAllURL
{
    [self.downLoaderDictionary.allValues performSelector:@selector(pauseCurrentTask)];
}

- (void)resumeAllURL
{
  [self.downLoaderDictionary.allValues performSelector:@selector(resumeCurrentTask)];
}

- (void)cancelAllURL
{
    [self.downLoaderDictionary.allValues performSelector:@selector(cancelCurrentTask)];
}


#pragma mark - pravite

+ (instancetype)shareInstance
{
   if(_instance == nil)
   {
       _instance = [[self alloc]init];
   }
    return _instance;
}

+(instancetype)allocWithZone:(struct _NSZone *)zone
{
   if(_instance == nil)
   {
       static dispatch_once_t onceToken;
       dispatch_once(&onceToken, ^{
           _instance = [super allocWithZone:zone];
       });
   }
    return _instance;
}

- (id)copyWithZone:(NSZone *)zone{
    return _instance;
}
- (id)mutableCopyWithZone:(NSZone *)zone{
    return _instance;
}
-(NSMutableDictionary *)downLoaderDictionary
{
  if(_downLoaderDictionary == nil)
  {
      _downLoaderDictionary = [NSMutableDictionary dictionary];
  }
    return _downLoaderDictionary;
}

@end
