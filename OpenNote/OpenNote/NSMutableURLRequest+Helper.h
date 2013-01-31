//
//  NSMutableURLRequest+Helper.h
//  OpenNote
//
//  Created by Zin ZH on 12-11-21.
//  Copyright (c) 2012年 NOTEON.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NSMutableString+Helper.h"

@interface NSMutableURLRequest (Helper)

+ (NSMutableURLRequest *)requestWithURL:(NSURL *)url
                                 method:(NSString *)method
                            contentType:(NSString *)contentType
                                 header:(NSDictionary *)header
                                content:(NSDictionary *)content;
@end
