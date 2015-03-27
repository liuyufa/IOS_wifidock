//
//  WFSettingItem.h
//  WiFiDock
//
//  Created by apple on 14-12-2.
//  Copyright (c) 2014年 cn.hualu.WiFiDock. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^WFSettingItemOption)();


@interface WFSettingItem : NSObject

@property(nonatomic,copy)NSString *icon;
@property(nonatomic,copy)NSString *subtitle;
@property (nonatomic, copy) NSString *title;

@property (nonatomic, copy) WFSettingItemOption option;

+ (instancetype)itemWithIcon:(NSString *)icon title:(NSString *)title;
+ (instancetype)itemWithTitle:(NSString *)title;
@end
