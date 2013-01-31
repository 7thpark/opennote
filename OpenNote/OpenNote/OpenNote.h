//
//  OpenNote.h
//  OpenNote
//
//  Created by Zin ZH on 12-11-21.
//  Copyright (c) 2012年 NOTEON.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Config.h"
#import "NSMutableString+Helper.h"
#import "OAHMAC_SHA1SignatureProvider.h"
#import "OpenNoteConnection.h"
#import "OpenNoteAuthorizeView.h"

@protocol OpenNoteDelegate;

@interface OpenNote : NSObject <OpenNoteConnectionDelegate, OpenNoteAuthorizeViewDelegate> {
    NSInteger statusCode;
}

@property (copy, nonatomic) NSString *consumerKey;
@property (copy, nonatomic) NSString *consumerSecret;
@property (weak, nonatomic) id<OpenNoteDelegate> delegate;
@property (copy, nonatomic) NSString *accessToken;
@property (copy, nonatomic) NSString *accessTokenSecret;
@property (copy, nonatomic) NSString *authorizedURLScheme;// 授权后呼叫的应用url scheme
@property (copy, nonatomic) NSString *accessTokenUDKey;
@property (copy, nonatomic) NSString *accessTokenSecretUDKey;
@property (copy, nonatomic) NSString *userinfoUDKey;

- (OpenNote *) initWithConsumerKey:(NSString *)aConsumerKey ConsumerSecret:(NSString *)aConsumerSecret;
- (OpenNote *) initWithConsumerKey:(NSString *)aConsumerKey ConsumerSecret:(NSString *)aConsumerSecret delegate:(id)aDelegate;

// 用户授权
- (BOOL)isLoggedIn;// 是否已经登录
- (void)authorize;// 开始授权：获取request token，组装authorize url，打开safari授权（需要appAuthorizedURLScheme）
- (void)authorizeWithURLScheme:(NSString *)urlScheme;// 开始授权
- (void)accessTokenWithToken:(NSString *)token verifier:(NSString *)verifier;// 用户通过safari登录并授权后调用以获取access token
- (void)logout;


#pragma mark - Youdao note open api interface

// 用户信息
- (void)userGet;
- (NSDictionary *)getUserinfo;

// 笔记本
// 列出全部笔记本
- (void)notebookAll;
// 列出某笔记本下全部笔记
- (void)notebookListWithNotebook:(NSString *)notebook;
// 新建笔记本
- (void)notebookCreateWithName:(NSString *)name;
// 删除笔记本
- (void)notebookDeleteWithNotebook:(NSString *)notebook;

// 笔记
// 新建一篇笔记
- (void)noteCreateWithContent:(NSString *)content;
// 新建一篇笔记及其他属性
- (void)noteCreateWithContent:(NSString *)content
                       source:(NSString *)source
                       author:(NSString *)author
                        title:(NSString *)title
                     notebook:(NSString *)notebook;
// 读取笔记
- (void)noteGetWithPath:(NSString *)path;
// 修改笔记
- (void)noteUpdateWithPath:(NSString *)path
                   content:(NSString *)content;
// 修改笔记及其他属性
- (void)noteUpdateWithPath:(NSString *)path
                   content:(NSString *)content
                    source:(NSString *)source
                    author:(NSString *)author
                     title:(NSString *)title;
// 移动笔记
- (void)noteMoveWithPath:(NSString *)path notebook:(NSString *)notebook;
// 删除笔记
- (void)noteDeleteWithPath:(NSString *)path;

// 附件
// 上传附件
- (void)resouceUploadWithFile:(id)file;
// 下载附件
- (void)resouceDownloadWithURL:(NSString *)url;

@end


#pragma mark - OpenNote Delegate
// 需要第三方应用实现的接口
@protocol OpenNoteDelegate <NSObject>

@optional

// 用户授权
- (void)opennote:(OpenNote *)opennote didLoggedIn:(BOOL)yn;
- (void)opennote:(OpenNote *)opennote didLoggedOut:(BOOL)yn;

// 用户信息
- (void)opennote:(OpenNote *)opennote didUserGet:(NSDictionary *)userinfo;

// 笔记本
- (void)opennote:(OpenNote *)opennote didNotebookAll:(NSArray *)notebooks;
- (void)opennote:(OpenNote *)opennote didNotebookList:(NSArray *)notes;
- (void)opennote:(OpenNote *)opennote didNotebookCreate:(NSDictionary *)notebook;
- (void)opennote:(OpenNote *)opennote didNotebookDelete:(BOOL)deleted;

// 笔记
- (void)opennote:(OpenNote *)opennote didNoteCreate:(NSDictionary *)note;
- (void)opennote:(OpenNote *)opennote didNoteGet:(NSDictionary *)note;
- (void)opennote:(OpenNote *)opennote didNoteUpdate:(BOOL)updated;
- (void)opennote:(OpenNote *)opennote didNoteMove:(NSDictionary *)note;
- (void)opennote:(OpenNote *)opennote didNoteDelete:(BOOL)deleted;

// 附件
- (void)opennote:(OpenNote *)opennote didResourceUpload:(NSDictionary *)file;
- (void)opennote:(OpenNote *)opennote didResourceDownload:(id)file;

@end
