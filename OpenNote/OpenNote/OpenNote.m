//
//  OpenNote.m
//  OpenNote
//
//  Created by Zin ZH on 12-11-21.
//  Copyright (c) 2012年 NOTEON.com. All rights reserved.
//

#import "OpenNote.h"

@interface OpenNote (Private)

- (NSString *)secret;
- (NSString *)signatureWithURL:(NSURL *)url method:(NSString *)method params:(NSDictionary *)params;
- (NSString *)makeAuthorizationHeaderWithParams:(NSDictionary *)params signature:(NSString *)signature;

@end

@implementation OpenNote

@synthesize consumerKey;
@synthesize consumerSecret;
@synthesize delegate;
@synthesize accessToken;
@synthesize accessTokenSecret;
@synthesize authorizedURLScheme;
@synthesize accessTokenUDKey;
@synthesize accessTokenSecretUDKey;
@synthesize userinfoUDKey;

- (OpenNote *) initWithConsumerKey:(NSString *)aConsumerKey
                    ConsumerSecret:(NSString *)aConsumerSecret
{
    return [self initWithConsumerKey:aConsumerKey
                      ConsumerSecret:aConsumerSecret
                            delegate:nil];
}
- (OpenNote *) initWithConsumerKey:(NSString *)aConsumerKey
                    ConsumerSecret:(NSString *)aConsumerSecret
                          delegate:(id <OpenNoteDelegate>)aDelegate
{
    if ((self = [super init])) {
        self.consumerKey = aConsumerKey;
        self.consumerSecret = aConsumerSecret;
        self.delegate = aDelegate;
        self.accessTokenUDKey = [NSString stringWithFormat:@"%@-AccessToken", aConsumerKey];
        self.accessTokenSecretUDKey = [NSString stringWithFormat:@"%@-AccessTokenSecret", aConsumerKey];
        self.userinfoUDKey = [NSString stringWithFormat:@"%@-Userinfo", aConsumerKey];
        // 读取access token及secret
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        self.accessToken = [userDefaults objectForKey:self.accessTokenUDKey];
        self.accessTokenSecret = [userDefaults objectForKey:self.accessTokenSecretUDKey];
    }
    return self;
}

// 用户授权
- (BOOL)isLoggedIn
{
    return accessToken!=nil;
}
- (void)authorize
{
    if (self.authorizedURLScheme==nil) return;//todo: 抛出错误，authorized url scheme未设置
	// todo: 重复授权检查及强制授权
	// 清空缓存的access token secret
	self.accessTokenSecret = nil;
    // request url
    NSURL *requestURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", OpenNoteBaseURL, OpenNoteRequestTokenPath]];
    // params
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
                            consumerKey, @"oauth_consumer_key",
                            OpenNoteOauthSignatureMethod, @"oauth_signature_method",
                            OpenNoteOAuthVersion, @"oauth_version",
                            [NSMutableString nonce], @"oauth_nonce",
                            [NSMutableString timestamp], @"oauth_timestamp",
                            nil];
    // signature
    NSString *signature = [self signatureWithURL:requestURL method:@"GET" params:params];
    // authorization header
    NSString *authorizationHeader = [self makeAuthorizationHeaderWithParams:params signature:signature];
    NSDictionary *header = [NSDictionary dictionaryWithObjectsAndKeys:
                            authorizationHeader, @"Authorization",
                            nil];
    // request token
    NSLog(@"请求request token");
    OpenNoteConnection *onc = [OpenNoteConnection connectionWithURL:requestURL delegate:self];
    [onc getWithHeader:header];
}
- (void)authorizeWithURLScheme:(NSString *)urlScheme
{
    self.authorizedURLScheme = urlScheme;
    [self authorize];
}
- (void)accessTokenWithToken:(NSString *)token verifier:(NSString *)verifier// 用户登录并授权后调用该方法，获取access token，授权正式完成
{
    // access url
    NSURL *accessURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", OpenNoteBaseURL, OpenNoteAccessTokenPath]];
    // params
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
                            consumerKey, @"oauth_consumer_key",
                            token, @"oauth_token",
                            verifier, @"oauth_verifier",
                            OpenNoteOauthSignatureMethod, @"oauth_signature_method",
                            OpenNoteOAuthVersion, @"oauth_version",
                            [NSMutableString nonce], @"oauth_nonce",
                            [NSMutableString timestamp], @"oauth_timestamp",
                            nil];
    // signature
    NSString *signature = [self signatureWithURL:accessURL method:@"GET" params:params];
    // authorization header
    NSString *authorizationHeader = [self makeAuthorizationHeaderWithParams:params signature:signature];
    NSDictionary *header = [NSDictionary dictionaryWithObjectsAndKeys:
                            authorizationHeader, @"Authorization",
                            nil];
    // request token
    //NSLog(@"请求access token");
    OpenNoteConnection *onc = [OpenNoteConnection connectionWithURL:accessURL delegate:self];
    [onc getWithHeader:header];
}
- (void)logout {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:nil forKey:accessTokenUDKey];
    self.accessToken = nil;
    [userDefaults setObject:nil forKey:accessTokenSecretUDKey];
    self.accessTokenSecret = nil;
}

#pragma mark - Youdao note open api interface

// 用户信息
- (void)userGet
{
    // todo: api请求中关于签名的参数，url等有大量重复代码，可以进行整理，如放到signature方法中
    // api url
    NSURL *apiURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", OpenNoteBaseURL, OpenNoteAPIUserGet]];
    // params
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
                            consumerKey, @"oauth_consumer_key",
                            accessToken, @"oauth_token",
                            OpenNoteOauthSignatureMethod, @"oauth_signature_method",
                            OpenNoteOAuthVersion, @"oauth_version",
                            [NSMutableString nonce], @"oauth_nonce",
                            [NSMutableString timestamp], @"oauth_timestamp",
                            nil];
    // signature
    NSString *signature = [self signatureWithURL:apiURL method:@"GET" params:params];
    // header
    NSString *authorizationHeader = [self makeAuthorizationHeaderWithParams:params signature:signature];
    NSDictionary *header = [NSDictionary dictionaryWithObjectsAndKeys:
                            authorizationHeader, @"Authorization",
                            nil];
    // request api
    //NSLog(@"请求用户信息");
    OpenNoteConnection *onc = [OpenNoteConnection connectionWithURL:apiURL delegate:self];
    [onc getWithHeader:header];
}
- (NSDictionary *)getUserinfo {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    return [userDefaults objectForKey:userinfoUDKey];
}

// 笔记本
// 列出全部笔记本
- (void)notebookAll
{
    // api url
    NSURL *apiURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", OpenNoteBaseURL, OpenNoteAPINotebookAll]];
    // params
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
                            consumerKey, @"oauth_consumer_key",
                            accessToken, @"oauth_token",
                            OpenNoteOauthSignatureMethod, @"oauth_signature_method",
                            OpenNoteOAuthVersion, @"oauth_version",
                            [NSMutableString nonce], @"oauth_nonce",
                            [NSMutableString timestamp], @"oauth_timestamp",
                            nil];
    // signature
    NSString *signature = [self signatureWithURL:apiURL method:@"POST" params:params];
    // header
    NSString *authorizationHeader = [self makeAuthorizationHeaderWithParams:params signature:signature];
    NSDictionary *header = [NSDictionary dictionaryWithObjectsAndKeys:
                            authorizationHeader, @"Authorization",
                            nil];
    // request api
    //NSLog(@"列出全部笔记本");
    OpenNoteConnection *onc = [OpenNoteConnection connectionWithURL:apiURL delegate:self];// POST 默认Content-Type:application/x-www-form-urlencoded
    [onc postWithHeader:header content:nil];
}
// 列出某笔记本下全部笔记
- (void)notebookListWithNotebook:(NSString *)notebook
{
    // api url
    NSURL *apiURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", OpenNoteBaseURL, OpenNoteAPINotebookList]];
    // params
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
                            consumerKey, @"oauth_consumer_key",
                            accessToken, @"oauth_token",
                            OpenNoteOauthSignatureMethod, @"oauth_signature_method",
                            OpenNoteOAuthVersion, @"oauth_version",
                            [NSMutableString nonce], @"oauth_nonce",
                            [NSMutableString timestamp], @"oauth_timestamp",
                            nil];
    // signature
    NSMutableDictionary *signatureParams = [NSMutableDictionary dictionaryWithDictionary:params];
    // todo: 做一个NSMutableDictionary的helper，有相加相减的方法等
    [signatureParams setObject:[[NSMutableString stringWithString:notebook] URLEncodedString] forKey:@"notebook"];// 参数name和其他oauth参数一起签名，因为content会对api参数做转码，所以这里也要做一次转码
    NSString *signature = [self signatureWithURL:apiURL method:@"POST" params:signatureParams];
    // header
    NSString *authorizationHeader = [self makeAuthorizationHeaderWithParams:params signature:signature];
    NSDictionary *header = [NSDictionary dictionaryWithObjectsAndKeys:
                            authorizationHeader, @"Authorization",
                            nil];
    //NSLog(@"header: %@", header);
    // request api
    OpenNoteConnection *onc = [OpenNoteConnection connectionWithURL:apiURL delegate:self];
    [onc postWithHeader:header content:[NSDictionary dictionaryWithObjectsAndKeys:
                                        notebook, @"notebook",
                                        nil]];
}
// 新建笔记本
- (void)notebookCreateWithName:(NSString *)name
{
    // api url
    NSURL *apiURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", OpenNoteBaseURL, OpenNoteAPINotebookCreate]];
    // params
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
                            consumerKey, @"oauth_consumer_key",
                            accessToken, @"oauth_token",
                            OpenNoteOauthSignatureMethod, @"oauth_signature_method",
                            OpenNoteOAuthVersion, @"oauth_version",
                            [NSMutableString nonce], @"oauth_nonce",
                            [NSMutableString timestamp], @"oauth_timestamp",
                            nil];
    // signature
    NSMutableDictionary *signatureParams = [NSMutableDictionary dictionaryWithDictionary:params];
    [signatureParams setObject:[[NSMutableString stringWithString:name] URLEncodedString] forKey:@"name"];
    NSString *signature = [self signatureWithURL:apiURL method:@"POST" params:signatureParams];
    // header
    NSString *authorizationHeader = [self makeAuthorizationHeaderWithParams:params signature:signature];
    NSDictionary *header = [NSDictionary dictionaryWithObjectsAndKeys:
                            authorizationHeader, @"Authorization",
                            nil];
    // request api
    OpenNoteConnection *onc = [OpenNoteConnection connectionWithURL:apiURL delegate:self];
    [onc postWithHeader:header content:[NSDictionary dictionaryWithObjectsAndKeys:
                                        name, @"name",
                                        nil]];
}
// 删除笔记本
- (void)notebookDeleteWithNotebook:(NSString *)notebook
{
    // api url
    NSURL *apiURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", OpenNoteBaseURL, OpenNoteAPINotebookDelete]];
    // params
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
                            consumerKey, @"oauth_consumer_key",
                            accessToken, @"oauth_token",
                            OpenNoteOauthSignatureMethod, @"oauth_signature_method",
                            OpenNoteOAuthVersion, @"oauth_version",
                            [NSMutableString nonce], @"oauth_nonce",
                            [NSMutableString timestamp], @"oauth_timestamp",
                            nil];
    // signature
    NSMutableDictionary *signatureParams = [NSMutableDictionary dictionaryWithDictionary:params];
    [signatureParams setObject:[[NSMutableString stringWithString:notebook] URLEncodedString] forKey:@"notebook"];
    NSString *signature = [self signatureWithURL:apiURL method:@"POST" params:signatureParams];
    // header
    NSString *authorizationHeader = [self makeAuthorizationHeaderWithParams:params signature:signature];
    NSDictionary *header = [NSDictionary dictionaryWithObjectsAndKeys:
                            authorizationHeader, @"Authorization",
                            nil];
    // request api
    OpenNoteConnection *onc = [OpenNoteConnection connectionWithURL:apiURL delegate:self];
    [onc postWithHeader:header content:[NSDictionary dictionaryWithObjectsAndKeys:
                                        notebook, @"notebook",
                                        nil]];
}

// 笔记
// 新建一篇笔记
- (void)noteCreateWithContent:(NSString *)content
{
    [self noteCreateWithContent:content source:nil author:nil title:nil notebook:nil];
}
// 新建一篇笔记及其他属性
- (void)noteCreateWithContent:(NSString *)content
                       source:(NSString *)source
                       author:(NSString *)author
                        title:(NSString *)title
                     notebook:(NSString *)notebook
{
    // api url
    NSURL *apiURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", OpenNoteBaseURL, OpenNoteAPINoteCreate]];
    // params
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
                            consumerKey, @"oauth_consumer_key",
                            accessToken, @"oauth_token",
                            OpenNoteOauthSignatureMethod, @"oauth_signature_method",
                            OpenNoteOAuthVersion, @"oauth_version",
                            [NSMutableString nonce], @"oauth_nonce",
                            [NSMutableString timestamp], @"oauth_timestamp",
                            nil];
    // signature
    NSString *signature = [self signatureWithURL:apiURL method:@"POST" params:params];// multipart 方式api参数不参与签名
    // header
    NSString *authorizationHeader = [self makeAuthorizationHeaderWithParams:params signature:signature];
    NSDictionary *header = [NSDictionary dictionaryWithObjectsAndKeys:
                            authorizationHeader, @"Authorization",
                            nil];
    // request api
    OpenNoteConnection *onc = [OpenNoteConnection connectionWithURL:apiURL delegate:self];
    [onc postWithHeader:header content:[NSDictionary dictionaryWithObjectsAndKeys:
                                        content, @"content",
                                        source, @"source",
                                        author, @"author",
                                        title, @"title",
                                        notebook, @"notebook",
                                        nil] type:@"multipart"];
}
// 读取笔记
- (void)noteGetWithPath:(NSString *)path
{
    // api url
    NSURL *apiURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", OpenNoteBaseURL, OpenNoteAPINoteGet]];
    // params
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
                            consumerKey, @"oauth_consumer_key",
                            accessToken, @"oauth_token",
                            OpenNoteOauthSignatureMethod, @"oauth_signature_method",
                            OpenNoteOAuthVersion, @"oauth_version",
                            [NSMutableString nonce], @"oauth_nonce",
                            [NSMutableString timestamp], @"oauth_timestamp",
                            nil];
    // signature
    NSMutableDictionary *signatureParams = [NSMutableDictionary dictionaryWithDictionary:params];
    [signatureParams setObject:[[NSMutableString stringWithString:path] URLEncodedString] forKey:@"path"];
    NSString *signature = [self signatureWithURL:apiURL method:@"POST" params:signatureParams];
    // header
    NSString *authorizationHeader = [self makeAuthorizationHeaderWithParams:params signature:signature];
    NSDictionary *header = [NSDictionary dictionaryWithObjectsAndKeys:
                            authorizationHeader, @"Authorization",
                            nil];
    // request api
    OpenNoteConnection *onc = [OpenNoteConnection connectionWithURL:apiURL delegate:self];
    [onc postWithHeader:header content:[NSDictionary dictionaryWithObjectsAndKeys:
                                        path, @"path",
                                        nil]];
}
// 修改笔记
- (void)noteUpdateWithPath:(NSString *)path
                   content:(NSString *)content
{
    [self noteUpdateWithPath:path content:content source:nil author:nil title:nil];
}
// 修改笔记及其他属性
- (void)noteUpdateWithPath:(NSString *)path
                   content:(NSString *)content
                    source:(NSString *)source
                    author:(NSString *)author
                     title:(NSString *)title
{
    // 如果author为nil会被修改吗？
    // api url
    NSURL *apiURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", OpenNoteBaseURL, OpenNoteAPINoteUpdate]];
    // params
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
                            consumerKey, @"oauth_consumer_key",
                            accessToken, @"oauth_token",
                            OpenNoteOauthSignatureMethod, @"oauth_signature_method",
                            OpenNoteOAuthVersion, @"oauth_version",
                            [NSMutableString nonce], @"oauth_nonce",
                            [NSMutableString timestamp], @"oauth_timestamp",
                            nil];
    // signature
    NSString *signature = [self signatureWithURL:apiURL method:@"POST" params:params];
    // header
    NSString *authorizationHeader = [self makeAuthorizationHeaderWithParams:params signature:signature];
    NSDictionary *header = [NSDictionary dictionaryWithObjectsAndKeys:
                            authorizationHeader, @"Authorization",
                            nil];
    // request api
    OpenNoteConnection *onc = [OpenNoteConnection connectionWithURL:apiURL delegate:self];
    [onc postWithHeader:header content:[NSDictionary dictionaryWithObjectsAndKeys:
                                        path, @"path",
                                        content, @"content",
                                        source, @"source",
                                        author, @"author",
                                        title, @"tittle",
                                        nil] type:@"multipart"];
}
// 移动笔记
- (void)noteMoveWithPath:(NSString *)path notebook:(NSString *)notebook
{
    // api url
    NSURL *apiURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", OpenNoteBaseURL, OpenNoteAPINoteMove]];
    // params
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
                            consumerKey, @"oauth_consumer_key",
                            accessToken, @"oauth_token",
                            OpenNoteOauthSignatureMethod, @"oauth_signature_method",
                            OpenNoteOAuthVersion, @"oauth_version",
                            [NSMutableString nonce], @"oauth_nonce",
                            [NSMutableString timestamp], @"oauth_timestamp",
                            nil];
    // signature
    NSMutableDictionary *signatureParams = [NSMutableDictionary dictionaryWithDictionary:params];
    [signatureParams setObject:[[NSMutableString stringWithString:path] URLEncodedString] forKey:@"path"];
    [signatureParams setObject:[[NSMutableString stringWithString:notebook] URLEncodedString] forKey:@"notebook"];
    NSString *signature = [self signatureWithURL:apiURL method:@"POST" params:signatureParams];
    // header
    NSString *authorizationHeader = [self makeAuthorizationHeaderWithParams:params signature:signature];
    NSDictionary *header = [NSDictionary dictionaryWithObjectsAndKeys:
                            authorizationHeader, @"Authorization",
                            nil];
    // request api
    OpenNoteConnection *onc = [OpenNoteConnection connectionWithURL:apiURL delegate:self];
    [onc postWithHeader:header content:[NSDictionary dictionaryWithObjectsAndKeys:
                                        path, @"path",
                                        notebook, @"notebook",
                                        nil]];
    
}
// 删除笔记
- (void)noteDeleteWithPath:(NSString *)path
{
    // api url
    NSURL *apiURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", OpenNoteBaseURL, OpenNoteAPINoteDelete]];
    // params
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
                            consumerKey, @"oauth_consumer_key",
                            accessToken, @"oauth_token",
                            OpenNoteOauthSignatureMethod, @"oauth_signature_method",
                            OpenNoteOAuthVersion, @"oauth_version",
                            [NSMutableString nonce], @"oauth_nonce",
                            [NSMutableString timestamp], @"oauth_timestamp",
                            nil];
    // signature
    NSMutableDictionary *signatureParams = [NSMutableDictionary dictionaryWithDictionary:params];
    [signatureParams setObject:path forKey:@"path"];
    NSString *signature = [self signatureWithURL:apiURL method:@"POST" params:signatureParams];
    // header
    NSString *authorizationHeader = [self makeAuthorizationHeaderWithParams:params signature:signature];
    NSDictionary *header = [NSDictionary dictionaryWithObjectsAndKeys:
                            authorizationHeader, @"Authorization",
                            nil];
    // request api
    OpenNoteConnection *onc = [OpenNoteConnection connectionWithURL:apiURL delegate:self];
    [onc postWithHeader:header content:[NSDictionary dictionaryWithObjectsAndKeys:
                                        path, @"path",
                                        nil]];
}

// 附件
// 上传附件
- (void)resouceUploadWithFile:(id)file
{
    // api url
    NSURL *apiURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", OpenNoteBaseURL, OpenNoteAPIResourceUpload]];
    // params
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
                            consumerKey, @"oauth_consumer_key",
                            accessToken, @"oauth_token",
                            OpenNoteOauthSignatureMethod, @"oauth_signature_method",
                            OpenNoteOAuthVersion, @"oauth_version",
                            [NSMutableString nonce], @"oauth_nonce",
                            [NSMutableString timestamp], @"oauth_timestamp",
                            nil];
    // signature
    NSString *signature = [self signatureWithURL:apiURL method:@"POST" params:params];
    // header
    NSString *authorizationHeader = [self makeAuthorizationHeaderWithParams:params signature:signature];
    NSDictionary *header = [NSDictionary dictionaryWithObjectsAndKeys:
                            authorizationHeader, @"Authorization",
                            nil];
    // request api
    OpenNoteConnection *onc = [OpenNoteConnection connectionWithURL:apiURL delegate:self];
    [onc postWithHeader:header content:[NSDictionary dictionaryWithObjectsAndKeys:
                                        file, @"file",
                                        nil] type:@"multipart"];
}
// 下载附件
- (void)resouceDownloadWithURL:(NSString *)url
{
    
}

#pragma mark - OpenNoteConnectionDelegate
- (void)opennoteConnection:(OpenNoteConnection *)connection didRecieveResponse:(NSURLResponse *)response{
    NSHTTPURLResponse *resp = (NSHTTPURLResponse *)response;
    statusCode = resp.statusCode;
	if (resp) {
		//NSLog(@"得到响应，status code：%d", statusCode);
	}
}
- (void)opennoteConnection:(OpenNoteConnection *)connection didRecieveData:(NSData *)data userinfo:(NSDictionary *)userinfo {
    NSString *dataString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    if (statusCode != 200) {
        NSLog(@"请求错误：%@", dataString);
        return;
    }
    NSString *path = [userinfo objectForKey:@"url-path"];
    NSLog(@"%@ 数据完成接收", path);
    if ([path isEqualToString:OpenNoteRequestTokenPath]) {// request token返回数据
        NSDictionary *token = [[NSMutableString stringWithString:dataString] queryToDictionary];
        NSString *requestToken = [token objectForKey:@"oauth_token"];
        // 清空 access token
        self.accessToken = nil;
        // 暂存 token secret
        self.accessTokenSecret = [token objectForKey:@"oauth_token_secret"];
        // 组装url
        NSString *url = [NSString stringWithFormat:@"%@%@?oauth_token=%@&oauth_callback=%@",
                         OpenNoteBaseURL,
                         OpenNoteAuthorizePath,
                         requestToken,
                         //authorizedURLScheme];
						 @"http://note.youdao.com/"];
        //NSLog(@"得到request token: %@，组装url: %@，打开safari，用户授权", token, url);
        //[[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
        NSLog(@"得到request token: %@，组装url: %@，打开web view，用户授权", token, url);
		OpenNoteAuthorizeView *authorizeView = [[OpenNoteAuthorizeView alloc] initWithURL:[NSURL URLWithString:url] delegate:self];
		[authorizeView show];
        
        return;
    } else if ([path isEqualToString:OpenNoteAccessTokenPath]) {// access token返回数据
        NSDictionary *token = [[NSMutableString stringWithString:dataString] queryToDictionary];
        // 得到access token 及 secret
        self.accessToken = [token objectForKey:@"oauth_token"];
        self.accessTokenSecret = [token objectForKey:@"oauth_token_secret"];
        // 保存到user default
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        [userDefaults setObject:self.accessToken forKey:accessTokenUDKey];
        [userDefaults setObject:self.accessTokenSecret forKey:accessTokenSecretUDKey];
        //NSLog(@"保存的secret：%@", [userDefaults objectForKey:accessTokenSecretUDKey]);
        //NSLog(@"得到access token: %@\naccess token secret: %@", self.accessToken, self.accessTokenSecret);
        if ([delegate respondsToSelector:@selector(opennote:didLoggedIn:)]) {
            [delegate opennote:self didLoggedIn:YES];
        }
        
        return;
    } else {
        NSError *err = nil;
        id dataJSON = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&err];
        if (dataJSON != nil && err == nil) {
            if ([dataJSON isKindOfClass:[NSDictionary class]] || [dataJSON isKindOfClass:[NSArray class]]) {
                //NSLog(@"deserialized data:%@", dataJSON);
                //char pathChar = (char) path;
                //switch (pathChar) {
                
                if ([path isEqualToString:OpenNoteAPIUserGet] && [delegate respondsToSelector:@selector(opennote:didUserGet:)]) {
                    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
                    [userDefaults setObject:dataJSON forKey:userinfoUDKey];// 保存用户信息
					NSLog(@"已保存用户信息: %@", [userDefaults objectForKey:userinfoUDKey]);
					
                    [delegate opennote:self didUserGet:dataJSON];
                    
                    return;
                }
                if ([path isEqualToString:OpenNoteAPINotebookAll] && [delegate respondsToSelector:@selector(opennote:didNotebookAll:)]) {
                    [delegate opennote:self didNotebookAll:dataJSON];
                    
                    return;
                }
                if ([path isEqualToString:OpenNoteAPINotebookList] && [delegate respondsToSelector:@selector(opennote:didNotebookList:)]) {
                    [delegate opennote:self didNotebookList:dataJSON];
                    
                    return;
                }
                if ([path isEqualToString:OpenNoteAPINotebookCreate] && [delegate respondsToSelector:@selector(opennote:didNotebookCreate:)]) {
                    [delegate opennote:self didNotebookCreate:dataJSON];
                    
                    return;
                }
                if ([path isEqualToString:OpenNoteAPINoteCreate] && [delegate respondsToSelector:@selector(opennote:didNoteCreate:)]) {
                    [delegate opennote:self didNoteCreate:dataJSON];
                    
                    return;
                }
                if ([path isEqualToString:OpenNoteAPINoteGet] && [delegate respondsToSelector:@selector(opennote:didNoteGet:)]) {
                    [delegate opennote:self didNoteGet:dataJSON];
                    
                    return;
                }
                if ([path isEqualToString:OpenNoteAPINoteMove] && [delegate respondsToSelector:@selector(opennote:didNoteMove:)]) {
                    [delegate opennote:self didNoteMove:dataJSON];
                    
                    return;
                }
                if ([path isEqualToString:OpenNoteAPIResourceUpload] && [delegate respondsToSelector:@selector(opennote:didResourceUpload:)]) {
                    [delegate opennote:self didResourceUpload:dataJSON];
                    
                    return;
                }
                
            } else {
                NSLog(@"An error happened while deserializing the JSON data: %@", dataString);
            }
        } else if (dataJSON == nil) {// 返回为空的接口
            if ([path isEqualToString:OpenNoteAPINotebookDelete] && [delegate respondsToSelector:@selector(opennote:didNotebookDelete:)]) {
                [delegate opennote:self didNotebookDelete:YES];
                
                return;
            }
            if ([path isEqualToString:OpenNoteAPINoteUpdate] && [delegate respondsToSelector:@selector(opennote:didNoteUpdate:)]) {
                [delegate opennote:self didNoteUpdate:YES];
                
                return;
            }
            if ([path isEqualToString:OpenNoteAPINoteDelete] && [delegate respondsToSelector:@selector(opennote:didNoteDelete:)]) {
                [delegate opennote:self didNoteDelete:YES];
                
                return;
            }
        } else {
            NSLog(@"An error happened while deserializing the JSON data:%@", dataString);
            // todo: 附件下载处理
        }
    }
}

#pragma mark - OpenNoteAuthorizeWebViewDelegate
- (void)authorizeView:(OpenNoteAuthorizeView *)authorizeViw authorizedWithToken:(NSString *)token verifier:(NSString *)verifier {
	[self accessTokenWithToken:token verifier:verifier];
}

#pragma mark - private method
// 秘钥
- (NSString *)secret
{
    return [NSString stringWithFormat:@"%@&%@", self.consumerSecret, self.accessTokenSecret?:@""];
}
// 签名，签名等过程应该放在connection去做，因为很多params时重复的
- (NSString *)signatureWithURL:(NSURL *)url method:(NSString *)method params:(NSDictionary *)params
{
    
    // 排序
    NSArray *keys = [[params allKeys] sortedArrayUsingSelector:@selector(compare:)];
    // 整理待签名参数
    NSMutableString *params2string = [NSMutableString stringWithCapacity:512];
    for (NSMutableString *key in keys) {
        [[[[params2string add:key.URLEncodedString] add:@"="] add:[params objectForKey:key]] add:@"&"];
    }
    [params2string substringFromLast];
    // 待签名内容
    NSString *clearText = [NSString stringWithFormat:@"%@&%@%%3A%%2F%%2F%@%@&%@",
						   method,
						   url.scheme.lowercaseString,
						   [[NSMutableString stringWithString:url.host.lowercaseString] URLEncodedString],
						   [[NSMutableString stringWithString:url.path] URLEncodedString],
						   params2string.URLEncodedString];
    // 签名
    OAHMAC_SHA1SignatureProvider *signatureProvider = [[OAHMAC_SHA1SignatureProvider alloc] init];
    NSString *signature = [signatureProvider signClearText:clearText withSecret:[self secret]];
    //NSLog(@"签名内容：%@\nsignature: %@", clearText, signature);
    return signature;
}
// 请求授权的头信息
- (NSString *)makeAuthorizationHeaderWithParams:(NSDictionary *)params
									  signature:(NSString *)signature
{
    NSMutableString *header = [NSMutableString stringWithCapacity:512];
    [header add:@"OAuth "];
    for (NSString *key in [params allKeys]) {
        [[[[header add:key] add:@"=\""] add:[params objectForKey:key]] add:@"\", "];
    }
    [[[header add:@"oauth_signature=\""] add:[[NSMutableString stringWithString:signature] URLEncodedString]] add:@"\""];
    //NSLog(@"oauth header: %@", header);
    return header;
}
@end
