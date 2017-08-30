//
//  LZBFileManger.h
//  LZBDownLoader
//
//  Created by zibin on 2017/7/20.
//  Copyright © 2017年 Apple. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LZBFileManger : NSObject

/**
  判断文件是否存在

 @param filePath 文件路径
 */
+ (BOOL)fileIsExitWithPath:(NSString *)filePath;

/**
 根据文件路径计算大小
 
 @param filePath 文件路径
 */
+ (long long)fileSizeWithPath:(NSString *)filePath;


/**
 移动文件 从fromPath - 到toPath

 @param fromPath 源文件
 @param toPath 目的文件
 */
+ (void)moveFileFromPath:(NSString *)fromPath toPath:(NSString *)toPath;


/**
 移除文件

 @param filePath 文件路径
 */
+ (void)removeFile:(NSString *)filePath;
@end
