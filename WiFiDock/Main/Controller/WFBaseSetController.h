//
//  WFTabBarController.h
//  WiFiDock
//
//  Created by apple on 14-12-2.
//  Copyright (c) 2014年 cn.hualu.WiFiDock. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WFTabBar.h"
#import "UIBarButtonItem+IW.h"
#import "MBProgressHUD+WF.h"


@interface WFBaseSetController : UITableViewController<WFTabBarDelegate>

@property (nonatomic,strong) NSMutableArray *data;


- (void)mainView;

- (void)back;

@end
