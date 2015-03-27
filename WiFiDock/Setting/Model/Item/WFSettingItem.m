//
//  WFSettingItem.m
//  WiFiDock
//
//  Created by apple on 14-12-2.
//  Copyright (c) 2014年 cn.hualu.WiFiDock. All rights reserved.
//

#import "WFSettingItem.h"

@implementation WFSettingItem

+ (instancetype)itemWithIcon:(NSString *)icon title:(NSString *)title
{
    WFSettingItem *item = [[self alloc] init];
    item.icon = icon;
    item.title = title;
    return item;
}


+ (instancetype)itemWithTitle:(NSString *)title
{
    return [self itemWithIcon:nil title:title];
}

@end
