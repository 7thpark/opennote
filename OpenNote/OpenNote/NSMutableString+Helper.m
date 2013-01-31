//
//  NSMutableString+Helper.m
//  Delegate_Protocol
//
//  Created by Zin ZH on 12-12-4.
//  Copyright (c) 2012年 NOTEON.com. All rights reserved.
//

#import "NSMutableString+Helper.h"

@implementation NSMutableString (Helper)

+ (NSMutableString *)timestamp {
    return [NSMutableString stringWithFormat:@"%ld", time(NULL)];
}

+ (NSMutableString *)nonce{
    CFUUIDRef uuid = CFUUIDCreate(NULL);
    CFStringRef s = CFUUIDCreateString(NULL, uuid);
    CFRelease(uuid);
    return (__bridge NSMutableString *)(s);
}

- (NSMutableString *)URLEncodedString {
    NSMutableString *result = (__bridge NSMutableString *)CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
                                                                                    (CFStringRef)self,
                                                                                    NULL,
                                                                                    CFSTR("!*'();:@&=+$,/?%#[]"),
                                                                                    kCFStringEncodingUTF8);
    return result;
}

- (NSMutableString *)URLDecodedString {
    NSMutableString *result = (__bridge NSMutableString *)CFURLCreateStringByReplacingPercentEscapesUsingEncoding(kCFAllocatorDefault,
                                                                                                    (CFStringRef)self,
                                                                                                    CFSTR(""),
                                                                                                    kCFStringEncodingUTF8);
    return result;
}

- (NSMutableString *)add:(NSString *)string {
    if ([string isKindOfClass:[NSString class]]) [self appendString:string];
    if ([string isKindOfClass:[NSNumber class]]) [self appendString:[(NSNumber *)string stringValue]];
    return self;
}

- (NSString *)substringFromLast {
    const int n = [self length] - 1;
    if (n>=0) [self deleteCharactersInRange:NSMakeRange(n, 1)];
    return self;
}

- (NSDictionary *)queryToDictionary {
	NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
	NSArray *pairs = [self componentsSeparatedByString:@"&"];
	for (NSString *pair in pairs) {
		NSArray *keyValue = [pair componentsSeparatedByString:@"="];
		[dictionary setObject:[keyValue objectAtIndex:1] forKey:[keyValue objectAtIndex:0]];
	}
	return dictionary;
}

@end
