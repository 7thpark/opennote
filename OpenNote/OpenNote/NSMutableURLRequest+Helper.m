//
//  NSMutableURLRequest+Helper.m
//  OpenNote
//
//  Created by Zin ZH on 12-11-21.
//  Copyright (c) 2012年 NOTEON.com. All rights reserved.
//
/*
 * 构建url request是比较麻烦的一部分，需要判断POST时候Content-Type类型进行签名，并手动组装http content
 * GET时候需要对请求参数进行url encode一起签名，将请求参数及authorization参数分别放入header参数
 */


#import "NSMutableURLRequest+Helper.h"
#import "OAHMAC_SHA1SignatureProvider.h"

#define ONTimeoutInterval           240
#define ONBoundary                  @"3240las9f9a0g0qb0z09fg0q9jab0aAF9IE02CC65OQ"

@interface NSMutableData (Helper)

+ (NSMutableData *)dataRFC2045WithDictionary:(NSDictionary *)dictionary;
+ (NSMutableData *)dataRFC1738WithDictionary:(NSDictionary *)dictionary;

- (void)appendDataString:(NSString *)dataString;

@end

@implementation NSMutableData (Helper)

+ (NSMutableData *)dataRFC2045WithDictionary:(NSDictionary *)dictionary {
    
    NSString *prefixString = [NSString stringWithFormat:@"--%@\r\n", ONBoundary];
    NSString *suffixString = [NSString stringWithFormat:@"--%@--\r\n", ONBoundary];
    
    NSMutableData *data = [NSMutableData data];
    [data appendDataString:[NSString stringWithFormat:@"Content-Type: multipart/form-data; boundary=%@\r\n", ONBoundary]];
    
    NSMutableDictionary *dataDictionary = [NSMutableDictionary dictionary];// todo:处理附件
    // 发送文本
    for (id key in [dictionary keyEnumerator]) {
        if (([[dictionary valueForKey:key] isKindOfClass:[UIImage class]]) || ([[dictionary valueForKey:key] isKindOfClass:[NSData class]])) {
            [dataDictionary setObject:[dictionary valueForKey:key] forKey:key];
        }
        [data appendDataString:prefixString];
        [data appendDataString:[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n%@\r\n", key, [dictionary valueForKey:key]]];
        }
    // 发送附件
    // todo:文件名filename
    if ([dataDictionary count] > 0) {
        for (id key in dataDictionary) {
            [data appendDataString:prefixString];
            id dataParam = [dataDictionary valueForKey:key];
			if ([dataParam isKindOfClass:[UIImage class]]) {
				NSData *imageData = UIImagePNGRepresentation((UIImage *)dataParam);
				[data appendDataString:[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"; filename=\"file\"\r\n", key]];
				[data appendDataString:@"Content-Type: image/png\r\nContent-Transfer-Encoding: binary\r\n\r\n"];
                [data appendData:imageData];
			} else {
				[data appendDataString:[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"; filename=\"file\"\r\n", key]];
				[data appendDataString:@"Content-Type: Multipart/alternative\r\nContent-Transfer-Encoding: binary\r\n\r\n"];
				[data appendData:(NSData *)dataParam];
			}
			[data appendDataString:@"\r\n"];
        }
    }
    // todo: 文本跟附件一起发送以及一个name下多个file时，参考 www.w3.org/TR/html401/interact/forms.html#h-17.13.4.2
    
    [data appendDataString:suffixString];
    
    //NSLog(@"RFC2045 HTTP Content\n%@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
    
    return data;
}

+ (NSMutableData *)dataRFC1738WithDictionary:(NSDictionary *)dictionary {
    NSMutableString *contentString = [NSMutableString stringWithCapacity:512];
    for (NSMutableString *key in [dictionary allKeys]) {
        [[[[contentString add:[key URLEncodedString]] add:@"="] add:[[dictionary objectForKey:key] URLEncodedString]] add:@"&"];
    }
    [contentString substringFromLast];
    NSMutableData *data = [NSMutableData dataWithData:[contentString dataUsingEncoding:NSUTF8StringEncoding]];
    //NSLog(@"依据[RFC 1738]对content进行url encode构建http body: %@\nencoded: %@", contentString, body);
    return data;
}

- (void)appendDataString:(NSString *)dataString {
    [self appendData:[dataString dataUsingEncoding:NSUTF8StringEncoding]];
}

@end

@implementation NSMutableURLRequest (Helper)


+ (NSMutableURLRequest *)requestWithURL:(NSURL *)url
                                 method:(NSString *)method
                            contentType:(NSString *)contentType
                                 header:(NSDictionary *)header
                                content:(NSDictionary *)content
{
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url
                                                           cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
                                                       timeoutInterval:ONTimeoutInterval];
    
    [request setHTTPMethod:method];
    
    // 设置header
    for (NSString *key in [header keyEnumerator]) {
        [request setValue:[header objectForKey:key] forHTTPHeaderField:key];
    }
    // POST时设置http content
    if ([method isEqualToString:@"POST"] && content) {
        if ([contentType isEqualToString:@"multipart/form-data"]) {
            [request setValue:[NSString stringWithFormat:@"%@; boundary=%@", contentType, ONBoundary] forHTTPHeaderField:@"Content-Type"];// 默认为urlencoded，可以仅设置multipart的content type
            [request setHTTPBody:[NSMutableData dataRFC2045WithDictionary:content]];
        } else {
            [request setHTTPBody:[NSMutableData dataRFC1738WithDictionary:content]];
        }
    }
    
    return request;
}

@end
