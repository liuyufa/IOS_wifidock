//
//  WFBaseSettingViewController.m
//  WiFiDock
//
//  Created by hualu on 15-1-19.
//  Copyright (c) 2015年 cn.hualu.WiFiDock. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Foundation/NSObject.h>
#import <QuartzCore/QuartzCore.h>
#import <Availability.h>
#import "Reachability+WF.h"
#import <SystemConfiguration/CaptiveNetwork.h>
#import "WFBaseSettingViewController.h"
#import "AFHTTPRequestOperation.h"
#import "AFXMLRequestOperation.h"
#import "Reachability.h"
#import "iToast.h"
#import "Httphelper.h"
@interface WFBaseSettingViewController ()
@property(nonatomic,weak)UILabel *ssid;
@property(nonatomic,weak)UILabel *key;
@property(nonatomic,weak)UITextField *vssid;
@property(nonatomic,weak)UITextField *vkey;
@property(nonatomic,weak)UIButton *savebutton;
@property(nonatomic,weak)UIButton *restorebutton;
@property(nonatomic,weak)NSString *result;
@property(nonatomic,strong)NSString *tmpssid;
@property(nonatomic,strong)NSString *tmpkey;
@end
static MSNetworksManager *NetworksManager;
@implementation WFBaseSettingViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = NSLocalizedString(@"Base Setting",nil);
    if([self checkNetWorkInfo])
    {
        [self tapBackground];
        [self setupSubview];
        //获取SSID
        self.tmpssid=[self currentWifiSSID];
        self.vssid.text = self.tmpssid;
    }
}
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    //    [MBProgressHUD showMessage:NSLocalizedString(@"Loading ......",nil)];
}
- (void)getMore
{
    [self dismissViewControllerAnimated:YES completion:^{
        NSLog(@"go home");
    }];
}

- (void)back
{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)tapBackground //在ViewDidLoad中调用
{
    UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapOnce)];//定义一个手势
    [tap setNumberOfTouchesRequired:1];//触击次数这里设为1
    [self.view addGestureRecognizer:tap];//添加手势到View中
}
-(void)tapOnce//手势方法
{
    [self.vssid resignFirstResponder];
    [self.vkey resignFirstResponder];
}

-(void)checkInfo
{
    NSString *ssidtext = self.vssid.text;
    NSString *keytext = self.vkey.text;
    NSLog(@"checkInfo key %d",keytext.length);
    NSLog(@"checkInfo ssid %d",ssidtext.length);
    if (keytext.length==0||ssidtext.length==0) {
        [[[[iToast makeText:NSLocalizedString(@"SSID or KEY is Empty", @"")] setGravity:iToastGravityBottom] setDuration:iToastDurationNormal] show];
        return;
    }
    if(keytext.length < 8){
        [[[[iToast makeText:NSLocalizedString(@"Password length is 8 to 63,Please re-enter", @"")] setGravity:iToastGravityBottom] setDuration:iToastDurationNormal] show];
        return;
    }
}

-(void)setupSubview
{
    
    UILabel *ssid = [[UILabel alloc]init];
    ssid.frame = CGRectMake(30, 80, 50, 20);
    ssid.text = @"SSID:";
    self.ssid = ssid;
    
    UITextField *vssid =[[UITextField alloc]init];
    vssid.frame = CGRectMake(100, 70, 200, 40);
    vssid.borderStyle=UITextBorderStyleRoundedRect;
    vssid.font=[UIFont fontWithName:@"Times New Roman" size:20];
    vssid.placeholder=NSLocalizedString(@"Please input ssid",nil);
    vssid.tag = 5;
    vssid.clearButtonMode=UITextFieldViewModeAlways;
    vssid.clearsOnBeginEditing=NO;
    vssid.layer.borderWidth =1.0;
    vssid.layer.cornerRadius =5.0;
    self.vssid = vssid;
    
    UILabel *key = [[UILabel alloc]init];
    key.frame = CGRectMake(30, 140, 50, 20);
    key.text = @"KEY:";
    self.key = key;
    
    UITextField *vkey =[[UITextField alloc]init];
    vkey.frame = CGRectMake(100, 130, 200, 40);
    vkey.borderStyle=UITextBorderStyleRoundedRect;
    vkey.font=[UIFont fontWithName:@"Times New Roman" size:20];
    vkey.placeholder=NSLocalizedString(@"Please input key",nil);
    vkey.tag = 10;
    vkey.clearButtonMode=UITextFieldViewModeAlways;
    vkey.clearsOnBeginEditing=YES;
    vkey.layer.borderWidth =1.0;
    vkey.layer.cornerRadius =5.0;
    self.vkey = vkey;
    
    UIButton *savebutton = [[UIButton alloc]init];
    savebutton.frame = CGRectMake(30,200, 60, 35);
    [savebutton setBackgroundColor:[UIColor darkGrayColor]];
    [savebutton setTitle:NSLocalizedString(@"Save",nil) forState:UIControlStateNormal];
    savebutton.layer.borderWidth = 1.0;
    savebutton.layer.cornerRadius = 5.0;
    [savebutton addTarget:self action:@selector(bbtnClick:) forControlEvents: UIControlEventTouchUpInside];
    savebutton.showsTouchWhenHighlighted = YES;
    savebutton.tag = 15;
    self.savebutton = savebutton;
    
    UIButton *restorebutton = [[UIButton alloc]init];
    restorebutton.frame = CGRectMake(240,200, 60, 35);
    [restorebutton setBackgroundColor:[UIColor darkGrayColor]];
    [restorebutton setTitle:NSLocalizedString(@"Restore",nil) forState:UIControlStateNormal];
    restorebutton.layer.borderWidth = 1.0;
    restorebutton.layer.cornerRadius = 5.0;
    [restorebutton addTarget:self action:@selector(bbtnClick:) forControlEvents: UIControlEventTouchUpInside];
    restorebutton.showsTouchWhenHighlighted = YES;
    restorebutton.tag = 20;
    self.restorebutton = restorebutton;
    
    [self.view addSubview:self.ssid];
    [self.view addSubview:self.vssid];
    [self.view addSubview:self.key];
    [self.view addSubview:self.vkey];
    [self.view addSubview:self.savebutton];
    [self.view addSubview:self.restorebutton];
}

-(void)setSSidInfo
{
    //同步GET请求
    //第一步，创建URL
    NSString *netpath =@"http://10.10.1.1:.wop:ssid:";
    NSString *sendinfo =[[[netpath stringByAppendingString:self.vssid.text]stringByAppendingString:@":"]stringByAppendingString:self.vkey.text];
    //[Httphelper setURLRequest:sendinfo];
    if([Httphelper setURLRequest:sendinfo]){
        NSLog(@"set ssid and key success !!!!");
        [[[[iToast makeText:NSLocalizedString(@"Save success", @"")] setGravity:iToastGravityBottom] setDuration:iToastDurationNormal] show];
    }
    else
    {
        NSLog(@"set ssid and key fail !!!!");
        [[[[iToast makeText:NSLocalizedString(@"Save failed,Please Check the equipment", @"")] setGravity:iToastGravityBottom] setDuration:iToastDurationNormal] show];
    }
}

-(void)getResult:(NSString *)res
{
    self.result = res;
    if([self.result isEqualToString:@"setsuccess"]){
        NSLog(@"setsuccess");
    }
}

-(BOOL)checkNetWorkInfo
{
    //[MBProgressHUD showMessage:NSLocalizedString(@"Loading data......", nil)];
    /*是否连接smb 10.10.1.1*/
    Reachability *reachability = [Reachability reachabilityWithHostName:kSmbIp];
    [Reachability startCheckWithReachability:reachability];
    if(![Reachability isReachableSamba]){
        [[[[iToast makeText:NSLocalizedString(@"No device connected", @"")] setGravity:iToastGravityBottom] setDuration:iToastDurationNormal] show];
        [self.navigationController popViewControllerAnimated:YES];
        return NO;
    }
    return YES;
}


- (NSString *)currentWifiSSID {
    // Does not work on the simulator.
    NSString *sid=nil;
    NSArray *ifs = (__bridge_transfer id)CNCopySupportedInterfaces();
    NSLog(@"ifs:%@",ifs);
    for (NSString *ifnam in ifs) {
        NSDictionary *info = (__bridge_transfer id)CNCopyCurrentNetworkInfo((__bridge CFStringRef)ifnam);
        NSLog(@"dici：%@",[info  allKeys]);
        if (info[@"SSID"]) {
            sid = info[@"SSID"];
        }
    }
    return sid;
}

- (void)bbtnClick:(UIButton *)button
{
    
    if(15==button.tag){
        [self.view endEditing:YES];
        [self checkInfo];
        [self setSSidInfo];
    }
    if(20==button.tag){
        NSLog(@"tmpssid %@",self.tmpssid);
        NSLog(@"tmpkey %@",self.tmpkey);
        self.vssid.text = self.tmpssid;
        self.vkey.text = self.tmpkey;
        NSLog(@"vssid %@",self.vssid.text);
        NSLog(@"vkey %@",self.vkey.text);
    }
}

-(void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    
}

//UI适配
-(void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    if (UIInterfaceOrientationIsPortrait(toInterfaceOrientation)) {
        
    }
    else {
        
    }
}
@end