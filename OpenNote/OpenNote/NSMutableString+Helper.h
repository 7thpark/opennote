//
//  NSMutableString+Helper.h
//  Delegate_Protocol
//
//  Created by Zin ZH on 12-12-4.
//  Copyright (c) 2012年 NOTEON.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSMutableString (Helper)

+ (NSMutableString *)timestamp;
+ (NSMutableString *)nonce;

- (NSMutableString *)URLEncodedString;
- (NSMutableString *)URLDecodedString;

- (NSMutableString *)add:(NSString *)string;
- (NSMutableString *)substringFromLast;

- (NSDictionary *)queryToDictionary;

@end
