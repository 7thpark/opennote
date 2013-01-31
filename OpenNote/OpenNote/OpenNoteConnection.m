//
//  OpenNoteRequest.m
//  OpenNote
//
//  Created by Zin ZH on 12-11-21.
//  Copyright (c) 2012年 NOTEON.com. All rights reserved.
//

#import "OpenNoteConnection.h"

@interface OpenNoteConnection (Private)

- (void)connectWithMethod:(NSString *)method
                     type:(NSString *)type
                   header:(NSDictionary *)header
                  content:(NSDictionary *)content;

@end

@implementation OpenNoteConnection

@synthesize url;
@synthesize delegate;

+ (OpenNoteConnection *)connectionWithURL:(NSURL *)url delegate:(id<OpenNoteConnectionDelegate>)delegate {
    OpenNoteConnection *connection = [[OpenNoteConnection alloc] init];
    connection.url = url;
    connection.delegate = delegate;
    return connection;
}

- (void)getWithHeader:(NSDictionary *)header
{
    
    NSString *method = @"GET";
    [self connectWithMethod:method type:nil header:header content:nil];
}
// POST application
- (void)postWithHeader:(NSDictionary *)header
               content:(NSDictionary *)content
{
    NSString *type = @"application/x-www-form-urlencoded";
    [self postWithHeader:header content:content type:type];
}
// POST multipart
- (void)postWithHeader:(NSDictionary *)header
               content:(NSDictionary *)content
                  type:(NSString *)type
{
    if (![type isEqualToString:@"application/x-www-form-urlencoded"]) type=@"multipart/form-data";
    NSString *method = @"POST";
    [self connectWithMethod:method type:type header:header content:content];
}

#pragma mark - OpenNoteConnetion (Private)
- (void)connectWithMethod:(NSString *)method
                     type:(NSString *)type
                   header:(NSDictionary *)header
                  content:(NSDictionary *)content
{
    // 初始化response info
    responseInfo = nil;
    responseInfo = [NSMutableDictionary dictionaryWithObject:url.path forKey:@"url-path"];
    // make a request
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url
                                                                method:method
                                                           contentType:type
                                                                header:header
                                                               content:content];
    // connection
    [NSURLConnection connectionWithRequest:request delegate:self];
}

#pragma mark - NSURLConnectionDelegate
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    recievedData = [NSMutableData data];
    if ([delegate respondsToSelector:@selector(opennoteConnection:didRecieveResponse:)]) {
        [delegate opennoteConnection:self didRecieveResponse:response];
    }
}
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [recievedData appendData:data];// receive data可能会出问题，数据会出现延时，多次发送
}
- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    if ([delegate respondsToSelector:@selector(opennoteConnection:didRecieveData:userinfo:)]) {
        [delegate opennoteConnection:self didRecieveData:recievedData userinfo:responseInfo];
    }    
}

@end