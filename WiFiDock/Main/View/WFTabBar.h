//
//  WFTitleBar.h
//  WiFiDock
//
//  Created by apple on 14-12-3.
//  Copyright (c) 2014年 cn.hualu.WiFiDock. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WFTabBarButton.h"
@class WFTabBar;

@protocol WFTabBarDelegate <NSObject>

@optional
- (void)tabBar:(WFTabBar *)tabBar didSelectedButtonFrom:(WFTabBarButton*)from to:(WFTabBarButton*)to;

@end

@interface WFTabBar : UIView
- (void)addTabBarButtonWithItem:(UITabBarItem *)item;
@property (weak, nonatomic) WFTabBarButton *selectedButton;
@property(nonatomic,weak) id<WFTabBarDelegate> delegate;
@end
