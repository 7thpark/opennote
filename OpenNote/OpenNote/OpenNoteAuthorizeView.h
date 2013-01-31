//
//  OpenNoteAuthorizeView.h
//  MrTime
//
//  Created by Zin ZH on 12-12-23.
//  Copyright (c) 2012年 NOTEON.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NSMutableString+Helper.h"

@class OpenNoteAuthorizeView;

@protocol OpenNoteAuthorizeViewDelegate <NSObject>

@optional
- (void)authorizeView:(OpenNoteAuthorizeView *)authorizeView authorizedWithToken:(NSString *)token verifier:(NSString *)verifier;

@end

@interface OpenNoteAuthorizeView : UIView <OpenNoteAuthorizeViewDelegate, UIWebViewDelegate> {
	UIWebView *webview;
	UIButton *closeBtn;
	UIView *topBorderView;
	
	UIActivityIndicatorView  *activityIndicatorView;
}

@property (strong, nonatomic) id<OpenNoteAuthorizeViewDelegate> delegate;
@property (strong, nonatomic) NSURL *authorizeURL;

- (id)initWithURL:(NSURL *)url
		 delegate:(id<OpenNoteAuthorizeViewDelegate>)delegate;

- (void)show;


@end
