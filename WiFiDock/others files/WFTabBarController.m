//
//  WFTabBarController.m
//  WiFiDock
//
//  Created by apple on 14-12-4.
//  Copyright (c) 2014年 cn.hualu.WiFiDock. All rights reserved.
//

#import "WFTabBarController.h"

#import "WFTFTableViewController.h"
#import "WFLocalViewController.h"
#import "WFUSBViewController.h"
#import "WFNavigationController.h"
#import "UIImage+IW.h"

@interface WFTabBarController ()
@property(nonatomic,weak)WFTabBar *customTabBar;


@end

@implementation WFTabBarController

-(instancetype)initWithTag:(NSInteger)flag
{
    self = [super init];
    if (self) {
        self.flag = flag;
    }
    
    return self;
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setupTabBar];
    
    [self setupChildViewControllers];
    
}


- (void)setupTabBar
{
    WFTabBar *customTabBar = [[WFTabBar alloc] init];
    customTabBar.frame = self.tabBar.bounds;
    customTabBar.delegate = self;
    [self.tabBar addSubview:customTabBar];
    self.customTabBar = customTabBar;
}

- (void)setupChildViewController:(UIViewController *)vc title:(NSString *)title imageName:(NSString *)imageName selectedImageName:(NSString *)selectedImageName
{
    vc.title = title;
    vc.tabBarItem.image = [UIImage imageNamed:imageName];
    vc.tabBarItem.selectedImage = [UIImage originalImageWithName:selectedImageName];
    
    WFNavigationController *nav = [[WFNavigationController alloc] initWithRootViewController:vc];
    
    [self addChildViewController:nav];
    
    [self.customTabBar addTabBarButtonWithItem:vc.tabBarItem];
}


- (void)setupChildViewControllers
{
    WFLocalViewController *local = [[WFLocalViewController alloc]init];
    [self setupChildViewController:local title:@"本地" imageName:@"tabbar_home" selectedImageName:@"tabbar_home_selected"];
    
    WFTFTableViewController *tf = [[WFTFTableViewController alloc]init];
    [self setupChildViewController:tf title:@"TF卡" imageName:@"tabbar_home" selectedImageName:@"tabbar_home_selected"];
    
    WFUSBViewController *usb = [[WFUSBViewController alloc]init];
    
    [self setupChildViewController:usb title:@"U盘" imageName:@"tabbar_home" selectedImageName:@"tabbar_home_selected"];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    for (UIView *child in self.tabBar.subviews) {
        if ([child isKindOfClass:[UIControl class]]) {
            [child removeFromSuperview];
        }
    }
}

//- (void)tabBar:(WFTabBar *)tabBar didSelectedButtonFrom:(NSInteger)from to:(NSInteger)to
//{
//    self.selectedIndex = to;
//}


@end
