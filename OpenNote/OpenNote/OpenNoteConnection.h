//
//  OpenNoteRequest.h
//  OpenNote
//
//  Created by Zin ZH on 12-11-21.
//  Copyright (c) 2012年 NOTEON.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NSMutableURLRequest+Helper.h"

@protocol OpenNoteConnectionDelegate;

@interface OpenNoteConnection: NSObject <NSURLConnectionDataDelegate> {
    NSURL                           *url;
    NSString                        *oauthParams;
    NSString                        *apiParams;
    NSMutableData                   *recievedData;// 用于返回接收到的数据
    NSMutableDictionary             *responseInfo;// 错误信息及识别码error:,error-msg:,url-path:
}

@property (strong, nonatomic) NSURL *url;
@property (weak, nonatomic) id<OpenNoteConnectionDelegate> delegate;

+ (OpenNoteConnection *)connectionWithURL:(NSURL *)url delegate:(id<OpenNoteConnectionDelegate>)delegate;
- (void)getWithHeader:(NSDictionary *)header;
- (void)postWithHeader:(NSDictionary *)header content:(NSDictionary *)content;
- (void)postWithHeader:(NSDictionary *)header content:(NSDictionary *)content type:(NSString *)type;

@end


@protocol OpenNoteConnectionDelegate <NSObject>

@optional

- (void)opennoteConnection:(OpenNoteConnection *)connection didRecieveResponse:(NSURLResponse *)response;
- (void)opennoteConnection:(OpenNoteConnection *)connection didRecieveData:(NSData *)data userinfo:(NSDictionary *)userinfo;
// todo: 错误响应

@end
