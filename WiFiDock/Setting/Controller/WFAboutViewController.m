//
//  WFAboutViewController.m
//  WiFiDock
//
//  Created by apple on 14-12-2.
//  Copyright (c) 2014年 cn.hualu.WiFiDock. All rights reserved.
//

#import "WFAboutViewController.h"
#import "WFSettingGroup.h"
#import "WFSettingArrowItem.h"


@interface WFAboutViewController ()

@end

@implementation WFAboutViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIWebView *webView = [[UIWebView alloc]init];
    webView.frame = CGRectZero;
    
    [self.view addSubview:webView];
    
    self.navigationItem.rightBarButtonItem = [UIBarButtonItem itemWithImage:@"btn_home" higlightedImage:@"nil" target:self action:@selector(mainView)];
    
    WFSettingItem *mark = [WFSettingArrowItem itemWithTitle:NSLocalizedString(@"Score support",nil)destVcClass:nil];
    mark.option = ^{
        
        NSString *appid = @"893862423";
        NSString *str = [NSString stringWithFormat:@"itms-apps://itunes.apple.com/cn/app/id%@?mt=8", appid];
        NSURL *url = [NSURL URLWithString:str];
        [[UIApplication sharedApplication] openURL:url];

    };
    
     WFSettingItem *call = [WFSettingArrowItem itemWithTitle:NSLocalizedString(@"Customer Service Phone",nil) destVcClass:nil];
    
    call.subtitle = @"0755-33636685";
    call.option = ^{
        NSURL *url = [NSURL URLWithString:@"tel://075533636685"];
        
        
        [webView loadRequest:[NSURLRequest requestWithURL:url]];
    };
    
    WFSettingGroup *group = [[WFSettingGroup alloc] init];
    group.items = @[mark, call];
    [self.data addObject:group];
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 180.0f;
}

- (UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView* mView=[[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 160.0f)];
    UIImage *image = [UIImage imageNamed:@"setting_about_pic"];
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake((self.view.frame.size.width-image.size.width)*0.5,44,image.size.width,image.size.height)];
    imageView.image = image;
    
    UILabel *version = [[UILabel alloc]init];
    version.frame = CGRectMake(0, CGRectGetMaxY(imageView.frame), self.view.frame.size.width, 15);
    version.font = [UIFont systemFontOfSize:14];
    version.textColor = [UIColor blackColor];
    version.textAlignment = NSTextAlignmentCenter;
    NSString *versionN = [[[NSBundle mainBundle] infoDictionary] objectForKey:(NSString*)kCFBundleVersionKey];
    version.text = [NSString stringWithFormat:@"Version: %@",versionN];
    [mView addSubview:version];
    [mView addSubview:imageView];
    return mView;
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
