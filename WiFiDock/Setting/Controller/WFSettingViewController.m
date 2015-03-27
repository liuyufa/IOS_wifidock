//
//  WFSettingViewController.m
//  WiFiDock
//
//  Created by apple on 14-12-2.
//  Copyright (c) 2014年 cn.hualu.WiFiDock. All rights reserved.
//

#import "WFSettingViewController.h"
#import "WFSettingItem.h"
#import "WFSettingArrowItem.h"
#import "WFSettingLablltem.h"
#import "WFDevViewController.h"
#import "WFRouteViewController.h"
#import "MBProgressHUD+WF.h"
#import "WFAboutViewController.h"
#import "WFSettingGroup.h"
#import "UIBarButtonItem+IW.h"
#import "WFSettingSwitchItem.h"

@interface WFSettingViewController ()

@end

@implementation WFSettingViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
     self.navigationItem.title = NSLocalizedString(@"Setting",nil);

    [self setupGroup];

}


- (void)setupGroup
{
    WFSettingItem *devConfigure = [WFSettingArrowItem itemWithIcon:@"MorePush" title:NSLocalizedString(@"Device Configuration",nil) destVcClass:[WFDevViewController class]];
    
//     WFSettingItem *route = [WFSettingArrowItem itemWithIcon:@"MorePush" title:NSLocalizedString(@"Device Configuration",nil) destVcClass:[WFRouteViewController class]];
    
     WFSettingItem *route = [WFSettingArrowItem itemWithIcon:@"MorePush" title:NSLocalizedString(@"Router",nil) destVcClass:[WFRouteViewController class]];
    
    WFSettingItem *update = [WFSettingArrowItem itemWithIcon:@"MoreUpdate" title:NSLocalizedString(@"Upgrade",nil)];
    update.option = ^{
        [MBProgressHUD showMessage:NSLocalizedString(@"Checking on......",nil)];
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            // 移除HUD
            [MBProgressHUD hideHUD];
            
            // 提醒有没有新版本
            [MBProgressHUD showError:NSLocalizedString(@"No new Version",nil)];
        });
    };
     
    
    WFSettingItem *about = [WFSettingArrowItem itemWithIcon:@"MoreAbout" title:NSLocalizedString(@"About",nil) destVcClass:[WFAboutViewController class]];
    WFSettingGroup *group = [[WFSettingGroup alloc] init];
    
//   WFSettingItem *delet = [WFSettingSwitchItem itemWithIcon:@"handShake" title:@"清除私有数据"];
    
    group.items = @[devConfigure,route,update,about];
    [self.data addObject:group];
}

-(void)setupTabBar{

}
@end
