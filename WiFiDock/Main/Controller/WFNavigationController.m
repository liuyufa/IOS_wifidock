//
//  WFNavigationController.m
//  WiFiDock
//
//  Created by apple on 14-12-2.
//  Copyright (c) 2014年 cn.hualu.WiFiDock. All rights reserved.
//

#import "WFNavigationController.h"
#import "UIBarButtonItem+IW.h"
#import "UIImage+IW.h"


#define WFBarButtonTitleColor  WFColor(239, 113, 0)
#define WFBarButtonTitleFont  [UIFont systemFontOfSize:15]
#define WFBarButtonTitleDisabledColor WFColor(208, 208, 208)
#define WFNavigationBarTitleColor WFColor(65, 65, 65)
#define WFNavigationBarTitleFont [UIFont boldSystemFontOfSize:19]
#define WFGlobalBg WFColor(232, 233, 232)


@interface WFNavigationController ()

@end

@implementation WFNavigationController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = WFGlobalBg;
    self.interactivePopGestureRecognizer.delegate = nil;
    
}

 + (void)initialize
{
    
    UINavigationBar *navBar = [UINavigationBar appearance];

    if (KVersion >= 7.0) {
        [navBar setBarTintColor:WFColor(95, 138, 28)];
    }
    
    
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
    
    // 设置标题文字颜色
    NSMutableDictionary *attrs = [NSMutableDictionary dictionary];
    attrs[NSForegroundColorAttributeName] = [UIColor whiteColor];
    attrs[NSFontAttributeName] = [UIFont systemFontOfSize:16];
    [navBar setTitleTextAttributes:attrs];
    
    // 2.设置BarButtonItem的主题
    UIBarButtonItem *item = [UIBarButtonItem appearance];
    // 设置文字颜色
    NSMutableDictionary *itemAttrs = [NSMutableDictionary dictionary];
    itemAttrs[NSForegroundColorAttributeName] = [UIColor whiteColor];
    itemAttrs[NSFontAttributeName] = [UIFont systemFontOfSize:14];
    [item setTitleTextAttributes:itemAttrs forState:UIControlStateNormal];
 
}

-(void)back
{
    [self popViewControllerAnimated:YES];
}

- (void)getMore
{
    [self popToRootViewControllerAnimated:YES];
}
@end
