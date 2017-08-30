//
//  LZBFileManger.m
//  LZBDownLoader
//
//  Created by zibin on 2017/7/20.
//  Copyright © 2017年 Apple. All rights reserved.
//

#import "LZBFileManger.h"

@implementation LZBFileManger
+ (BOOL)fileIsExitWithPath:(NSString *)filePath
{
    if(filePath.length == 0) return NO;
    return [[NSFileManager defaultManager] fileExistsAtPath:filePath];
}

+ (long long)fileSizeWithPath:(NSString *)filePath
{
    if(![self fileIsExitWithPath:filePath]) return 0;
    NSDictionary *fileInfo = [[NSFileManager defaultManager] attributesOfItemAtPath:filePath error:nil];
    return [fileInfo[NSFileSize] longLongValue];
}
+ (void)moveFileFromPath:(NSString *)fromPath toPath:(NSString *)toPath
{
   if(![self fileIsExitWithPath:fromPath]) return;
    [[NSFileManager defaultManager] moveItemAtPath:fromPath toPath:toPath error:nil];
}
+ (void)removeFile:(NSString *)filePath
{
    if(![self fileIsExitWithPath:filePath]) return;
    [[NSFileManager defaultManager] removeItemAtPath:filePath error:nil];

}
@end
