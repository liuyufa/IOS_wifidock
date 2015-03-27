//
//  Httphelper.h
//  WiFiDock
//
//  Created by hualu on 15-1-28.
//  Copyright (c) 2015年 cn.hualu.WiFiDock. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "Reachability.h"

@interface Httphelper : NSObject
+ (BOOL)NetWorkIsOK;//检查网络是否可用
+ (BOOL)setURLRequest:(NSString *)info;
+(NSData*)httpPostSyn:(NSString *)str;
+ (void)post:(NSString *)Url FinishBlock:(void (^)(NSURLResponse *response, NSData *data, NSError *connectionError)) block;//post请求封装
+(BOOL)ifIPInfoValidity:(NSString *)ipinfo :(int)index;
@end