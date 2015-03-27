//
//  WFRouteViewController.m
//  WiFiDock
//
//  Created by apple on 14-12-2.
//  Copyright (c) 2014年 cn.hualu.WiFiDock. All rights reserved.
//

#import "WFRouteViewController.h"
#import "WFSettingItem.h"
#import "WFSettingArrowItem.h"
#import "WFWizardViewController.h"
#import "WFNDhcpViewController.h"
#import "WFNPPPoEViewController.h"
#import "WFNStaticViewController.h"
#import "WFNIspViewController.h"
#import "WFBaseSettingViewController.h"
#import "WFApScanViewController.h"
#import "WFSettingGroup.h"
@interface WFRouteViewController ()

@end

@implementation WFRouteViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationItem.title= NSLocalizedString(@"Router",nil);
    [self setupGroup];
}
- (void)setupGroup
{
    WFSettingItem *wizard = [WFSettingArrowItem itemWithIcon:@"MorePush" title:NSLocalizedString(@"Setup Wizard",nil) destVcClass:[WFWizardViewController class]];
    
    WFSettingItem *parameter = [WFSettingArrowItem itemWithIcon:@"MorePush" title:NSLocalizedString(@"NetWork Parameter",nil) destVcClass:[WFNIspViewController class]];
    
    WFSettingItem *bsetting = [WFSettingArrowItem itemWithIcon:@"MorePush" title:NSLocalizedString(@"Base Setting",nil) destVcClass:[WFBaseSettingViewController class]];
    
    WFSettingItem *apscan = [WFSettingArrowItem itemWithIcon:@"MorePush" title:NSLocalizedString(@"Ap Scan",nil) destVcClass:[WFApScanViewController class]];
    
    WFSettingGroup *groups = [[WFSettingGroup alloc] init];
    groups.items = @[wizard,parameter,bsetting,apscan];
    [self.data addObject:groups];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

-(void)back
{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)getMore
{
    [self dismissViewControllerAnimated:YES completion:^{
        NSLog(@"go home");
    }];
}

-(void)setupTabBar{
    
}
@end
