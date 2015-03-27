//
//  WFEditBar.h
//  WiFiDock
//
//  Created by apple on 14-12-4.
//  Copyright (c) 2014年 cn.hualu.WiFiDock. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WFEditButton.h"
@class WFEditBar;
@protocol WFEditBarDelegate <NSObject>

@optional
- (void)editBar:(WFEditBar *)editBar didSelectedButtonFrom:(WFEditButton*)from to:(WFEditButton*)to;

@end

@interface WFEditBar : UIView
//- (void)addEditButtonWithItem:(UITabBarItem *)item;
@property (strong, nonatomic) NSMutableArray *tabBarButtons;

@property(nonatomic,weak) id<WFEditBarDelegate> delegate;

@end
