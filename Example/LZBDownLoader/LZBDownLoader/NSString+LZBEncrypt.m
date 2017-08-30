//
//  NSString+LZBEncrypt.m
//  LZBDownLoader
//
//  Created by zibin on 2017/7/23.
//  Copyright © 2017年 Apple. All rights reserved.
//

#import "NSString+LZBEncrypt.h"
#include <CommonCrypto/CommonDigest.h>

@implementation NSString (LZBEncrypt)
- (NSString *)md5
{
    //转化成C的字符串
    const char *data = self.UTF8String;
    
    //16位字符串
    unsigned char md[CC_MD5_DIGEST_LENGTH];
    
    //把C语言字符串转化为md5 C字符串
    CC_MD5(data, (CC_LONG)strlen(data), md);
    
    //转化为32位NSString
    NSMutableString *result = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    for (int i = 0 ; i < CC_MD5_DIGEST_LENGTH; i++) {
        
        [result appendFormat:@"%02x",md[i]];
    }
    return result;
}
@end
