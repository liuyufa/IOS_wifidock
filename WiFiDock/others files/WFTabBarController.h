//
//  WFTabBarController.h
//  WiFiDock
//
//  Created by apple on 14-12-4.
//  Copyright (c) 2014年 cn.hualu.WiFiDock. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "WFTabBar.h"

@interface WFTabBarController : UITabBarController<WFTabBarDelegate>
@property(nonatomic,assign)NSInteger flag;
- (instancetype)initWithTag:(NSInteger)flag;
@end
