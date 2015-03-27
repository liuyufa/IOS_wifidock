//
//  ApScanItem.h
//  WiFiDock
//
//  Created by hualu on 15-1-29.
//  Copyright (c) 2015年 cn.hualu.WiFiDock. All rights reserved.
//
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
//建立热点数据模型
@interface ApScanItem : NSObject
@property (nonatomic,copy) NSString *essid;//ssid
@property (nonatomic,copy) NSString *encry;//加密图片
@property (nonatomic,copy) NSString *signal;//信号强度图片
- (instancetype) initWithDict: (NSDictionary *)dict;//对象方法
+ (instancetype) apWithDict: (NSDictionary *)dict;//类方法
@end
