//
//  OpenNoteAuthorizeView.m
//  MrTime
//
//  Created by Zin ZH on 12-12-23.
//  Copyright (c) 2012年 NOTEON.com. All rights reserved.
//

#import "OpenNoteAuthorizeView.h"
#import <QuartzCore/QuartzCore.h>

@implementation OpenNoteAuthorizeView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

- (id)init {
	if (self = [super init]) {
		self.autoresizesSubviews = YES;
		self.backgroundColor = [UIColor colorWithRed:0.95 green:0.95 blue:0.95 alpha:1];
		self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
		
		webview = [[UIWebView alloc] init];
		webview.scalesPageToFit = YES;
		webview.delegate = self;
		webview.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
		[self addSubview:webview];
		
		topBorderView = [[UIView alloc] init];
		topBorderView.backgroundColor = [UIColor colorWithRed:0.87 green:0.87 blue:0.87 alpha:1];
		[self addSubview:topBorderView];
		
		UIView *btnRightBorder = [[UIView alloc] initWithFrame:CGRectMake(60, 0, 1, 44)];
		btnRightBorder.backgroundColor = [UIColor colorWithRed:0.87 green:0.87 blue:0.87 alpha:1];
		[self addSubview:btnRightBorder];
		
		closeBtn = [[UIButton alloc] init];
		closeBtn.backgroundColor = [UIColor clearColor];
		closeBtn.frame = CGRectMake(0, 0, 60, 44);
		closeBtn.titleLabel.font = [UIFont fontWithName:@"Helvetica" size:14];
		[closeBtn setTitle:@"取消" forState:UIControlStateNormal];
		[closeBtn setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
		[closeBtn addTarget:self action:@selector(close) forControlEvents:UIControlEventTouchUpInside];
		[self addSubview:closeBtn];
		
		activityIndicatorView = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, 32, 32)];
		[activityIndicatorView setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleGray];
		[self addSubview:activityIndicatorView];
	}
	return self;
}

- (id)initWithURL:(NSURL *)url delegate:(id<OpenNoteAuthorizeViewDelegate>)delegate {
	if (self = [self init]) {
		NSLog(@"url %@", [url absoluteString]);
		self.authorizeURL = url;
		self.delegate = delegate;
	}
	return self;
}

- (void)show {
	NSLog(@"show authorize web view");
	[self load];
	
	UIWindow *window = [UIApplication sharedApplication].keyWindow;
	if (!window) {
		window = [[UIApplication sharedApplication].windows objectAtIndex:0];
	}
	
	self.frame = CGRectMake(0, window.frame.size.height, window.frame.size.width, window.frame.size.height - 20);
	
	webview.frame = CGRectMake(0, 44, window.frame.size.width, window.frame.size.height - 44);
	
	topBorderView.frame = CGRectMake(0, 43, window.frame.size.width, 1);
	topBorderView.layer.shadowColor = [UIColor blackColor].CGColor;
	topBorderView.layer.shadowOffset = CGSizeMake(window.frame.size.width, 2);
	topBorderView.layer.shadowOpacity = 0.5;
	
	[activityIndicatorView setCenter:self.center];
	
	[window addSubview:self];
	
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.3];
	self.frame = CGRectMake(0, 20, window.frame.size.width, window.frame.size.height - 20);
    [UIView commitAnimations];
	
}

- (void)load {
	[webview loadRequest:[NSURLRequest requestWithURL:self.authorizeURL]];
}

- (void)close {
	UIWindow *window = [UIApplication sharedApplication].keyWindow;
	if (!window) {
		window = [[UIApplication sharedApplication].windows objectAtIndex:0];
	}
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationDuration:0.2];
	[UIView setAnimationDidStopSelector:@selector(closed)];
	self.frame = CGRectMake(0, window.frame.size.height, window.frame.size.width, window.frame.size.height - 20);
	[UIView commitAnimations];
	// 清理cookie
	NSHTTPCookieStorage *cookieJar = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    NSLog(@"cookies to delete: %@", cookieJar);
	for (id cookie in [cookieJar cookies]) {
		[cookieJar deleteCookie: cookie];
        NSLog(@"delete cookie: %@", cookie);
	}
}

- (void)closed {
	[self removeFromSuperview];
}

#pragma mark - UIWebViewDelegate
- (void)webViewDidStartLoad:(UIWebView *)webView {
	[activityIndicatorView startAnimating];
	NSLog(@"to load url string: %@", webview.request.URL.absoluteString);
}
- (void)webViewDidFinishLoad:(UIWebView *)webView {
	[activityIndicatorView stopAnimating];
	
	NSString *urlString = webview.request.URL.absoluteString;
	NSLog(@"loaded url string: %@", urlString);
	//NSLog(@"verifier? %d", [urlString rangeOfString:@"oauth_verifier"].location != NSNotFound);
	if ([urlString hasPrefix:@"http://m.youdao.com"]) {
		if ([self.delegate respondsToSelector:@selector(authorizeView:authorizedWithToken:verifier:)]) {
			NSString *query = webview.request.URL.query;
			NSDictionary *queryPair = [[NSMutableString stringWithString:query] queryToDictionary];
			[self.delegate authorizeView:self authorizedWithToken:[queryPair objectForKey:@"oauth_token"] verifier:[queryPair objectForKey:@"oauth_verifier"]];
		}
		[self close];
	}
	
}
@end
