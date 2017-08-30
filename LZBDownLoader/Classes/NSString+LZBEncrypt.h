//
//  NSString+LZBEncrypt.h
//  LZBDownLoader
//
//  Created by zibin on 2017/7/23.
//  Copyright © 2017年 Apple. All rights reserved.
// 加密算法

#import <Foundation/Foundation.h>

@interface NSString (LZBEncrypt)
/**
 MD5加密
 */
- (NSString *)md5;
@end
