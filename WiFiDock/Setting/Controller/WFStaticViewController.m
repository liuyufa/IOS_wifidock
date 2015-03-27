//
//  WFStaticViewController.m
//  WiFiDock
//
//  Created by hualu on 15-2-4.
//  Copyright (c) 2015年 cn.hualu.WiFiDock. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WFStaticViewController.h"
#import "WFEndPageViewController.h"
#import "Reachability+WF.h"
#import "Reachability.h"
#import "Httphelper.h"
#import "iToast.h"
@interface WFStaticViewController ()<UITextFieldDelegate>

@property(nonatomic,weak)UILabel *ipdr;
@property(nonatomic,weak)UILabel *subnet;
@property(nonatomic,weak)UILabel *gateway;
@property(nonatomic,weak)UILabel *primary;
@property(nonatomic,weak)UILabel *backup;

@property(nonatomic,strong)UITextField *vipdr;
@property(nonatomic,strong)UITextField *vsubnet;
@property(nonatomic,strong)UITextField *vgateway;
@property(nonatomic,strong)UITextField *vprimary;
@property(nonatomic,strong)UITextField *vbackup;

@property(nonatomic,strong)UIButton *savebutton;
@property(nonatomic,strong)UIButton *restorebutton;
@property(nonatomic,assign)NSInteger over;
@end

@implementation WFStaticViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    [self tapBackground];
    self.over=1;
    self.navigationItem.title = NSLocalizedString(@"Setup Wizard",nil);
    [self setupSubview];
}
-(void)setupSubview
{
    UILabel *staticline = [[UILabel alloc] initWithFrame:CGRectMake(10,0,300,160)];
    staticline.backgroundColor = [UIColor clearColor];
    staticline.text = NSLocalizedString(@"StaticLine", @"");
    [staticline setNumberOfLines:0];
    staticline.font = [UIFont fontWithName:@"Helvetica" size:16];
    [staticline setLineBreakMode:NSLineBreakByWordWrapping];
    [self.view addSubview:staticline];
    
    UILabel *ipdr = [[UILabel alloc]init];
    ipdr.frame = CGRectMake(10, 180, 110, 30);
    ipdr.text = NSLocalizedString(@"ipadr", @"");
    self.ipdr = ipdr;
    
    UITextField *vipdr =[[UITextField alloc]init];
    vipdr.frame = CGRectMake(115, 170, 180, 40);
    vipdr.borderStyle=UITextBorderStyleRoundedRect;
    vipdr.font=[UIFont fontWithName:@"Times New Roman" size:20];
    //vipdr.placeholder=NSLocalizedString(@"Please input ipadr",nil);
    vipdr.tag = 5;
    vipdr.clearButtonMode=UITextFieldViewModeAlways;
    vipdr.clearsOnBeginEditing=NO;
    vipdr.layer.borderWidth =1.0;
    vipdr.layer.cornerRadius =5.0;
    vipdr.delegate =self;
    vipdr.text = @"10.10.2.2";
    self.vipdr = vipdr;
    
    UILabel *subnet = [[UILabel alloc]init];
    subnet.frame = CGRectMake(10, 230, 110, 30);
    subnet.text = NSLocalizedString(@"subnet", @"");
    self.subnet = subnet;
    
    UITextField *vsubnet =[[UITextField alloc]init];
    vsubnet.frame = CGRectMake(115, 220, 180, 40);
    vsubnet.borderStyle=UITextBorderStyleRoundedRect;
    vsubnet.font=[UIFont fontWithName:@"Times New Roman" size:20];
    //vsubnet.placeholder=NSLocalizedString(@"Please input subnet",nil);
    vsubnet.tag = 10;
    vsubnet.clearButtonMode=UITextFieldViewModeAlways;
    vsubnet.clearsOnBeginEditing=NO;
    vsubnet.layer.borderWidth =1.0;
    vsubnet.layer.cornerRadius =5.0;
    vsubnet.delegate =self;
    vsubnet.text = @"255.255.255.0";
    self.vsubnet = vsubnet;
    
    UILabel *gateway = [[UILabel alloc]init];
    gateway.frame = CGRectMake(10, 280, 110, 30);
    gateway.text = NSLocalizedString(@"gateway", @"");
    self.gateway = gateway;
    
    UITextField *vgateway =[[UITextField alloc]init];
    vgateway.frame = CGRectMake(115, 270, 180, 40);
    vgateway.borderStyle=UITextBorderStyleRoundedRect;
    vgateway.font=[UIFont fontWithName:@"Times New Roman" size:20];
    //vgateway.placeholder=NSLocalizedString(@"Please input gateway",nil);
    vgateway.tag = 15;
    vgateway.clearButtonMode=UITextFieldViewModeAlways;
    vgateway.clearsOnBeginEditing=NO;
    vgateway.layer.borderWidth =1.0;
    vgateway.layer.cornerRadius =5.0;
    vgateway.delegate =self;
    vgateway.text = @"192.168.1.1";
    self.vgateway = vgateway;
    
    UILabel *primary = [[UILabel alloc]init];
    primary.frame = CGRectMake(10, 330, 110, 30);
    primary.text = NSLocalizedString(@"primary", @"");
    self.primary = primary;
    
    UITextField *vprimary =[[UITextField alloc]init];
    vprimary.frame = CGRectMake(115, 320, 180, 40);
    vprimary.borderStyle=UITextBorderStyleRoundedRect;
    vprimary.font=[UIFont fontWithName:@"Times New Roman" size:20];
    //vprimary.placeholder=NSLocalizedString(@"Please input primary",nil);
    vprimary.tag = 20;
    vprimary.clearButtonMode=UITextFieldViewModeAlways;
    vprimary.clearsOnBeginEditing=NO;
    vprimary.layer.borderWidth =1.0;
    vprimary.layer.cornerRadius =5.0;
    vprimary.delegate =self;
    vprimary.text = @"6.6.6.6";
    self.vprimary = vprimary;
    
    UILabel *backup = [[UILabel alloc]init];
    backup.frame = CGRectMake(10, 380, 110, 30);
    backup.text =  NSLocalizedString(@"backup", @"");
    self.backup = backup;
    
    UITextField *vbackup =[[UITextField alloc]init];
    vbackup.frame = CGRectMake(115, 370, 180, 40);
    vbackup.borderStyle=UITextBorderStyleRoundedRect;
    vbackup.font=[UIFont fontWithName:@"Times New Roman" size:20];
    //vbackup.placeholder=NSLocalizedString(@"Please input backup",nil);
    vbackup.tag = 25;
    vbackup.clearButtonMode=UITextFieldViewModeAlways;
    vbackup.clearsOnBeginEditing=NO;
    vbackup.layer.borderWidth =1.0;
    vbackup.layer.cornerRadius =5.0;
    vbackup.delegate =self;
    vbackup.text = @"8.8.8.8";
    self.vbackup = vbackup;
    
    UIButton *savebutton = [[UIButton alloc]init];
    savebutton.frame = CGRectMake(30,440, 60, 35);
    [savebutton setBackgroundColor:[UIColor darkGrayColor]];
    [savebutton setTitle:NSLocalizedString(@"back",nil) forState:UIControlStateNormal];
    savebutton.layer.borderWidth = 1.0;
    savebutton.layer.cornerRadius = 5.0;
    [savebutton addTarget:self action:@selector(sbtnClick:) forControlEvents: UIControlEventTouchUpInside];
    savebutton.showsTouchWhenHighlighted = YES;
    savebutton.tag = 15;
    self.savebutton = savebutton;
    
    UIButton *restorebutton = [[UIButton alloc]init];
    restorebutton.frame = CGRectMake(240,440, 60, 35);
    [restorebutton setBackgroundColor:[UIColor darkGrayColor]];
    [restorebutton setTitle:NSLocalizedString(@"next",nil) forState:UIControlStateNormal];
    restorebutton.layer.borderWidth = 1.0;
    restorebutton.layer.cornerRadius = 5.0;
    [restorebutton addTarget:self action:@selector(sbtnClick:) forControlEvents: UIControlEventTouchUpInside];
    restorebutton.showsTouchWhenHighlighted = YES;
    restorebutton.tag = 20;
    self.restorebutton = restorebutton;
    
    [self.view addSubview:self.ipdr];
    [self.view addSubview:self.vipdr];
    
    [self.view addSubview:self.subnet];
    [self.view addSubview:self.vsubnet];
    
    [self.view addSubview:self.gateway];
    [self.view addSubview:self.vgateway];
    
    [self.view addSubview:self.primary];
    [self.view addSubview:self.vprimary];
    
    [self.view addSubview:self.backup];
    [self.view addSubview:self.vbackup];
    
    [self.view addSubview:self.savebutton];
    [self.view addSubview:self.restorebutton];
}
-(void)tapBackground //在ViewDidLoad中调用
{
    UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapOnce)];//定义一个手势
    [tap setNumberOfTouchesRequired:1];//触击次数这里设为1
    [self.view addGestureRecognizer:tap];//添加手势到View中
}
-(void)tapOnce//手势方法
{
    [self.vipdr resignFirstResponder];
    [self.vsubnet resignFirstResponder];
    [self.vgateway resignFirstResponder];
    [self.vprimary resignFirstResponder];
    [self.vbackup resignFirstResponder];
}
- (void)sbtnClick:(UIButton *)button
{
    
    if(15==button.tag){
        [self.navigationController popViewControllerAnimated:YES];
    }
    if(20==button.tag){
        if ([self checkEmpty]) {
            if ([self checkValidity]) {
                if([self checkSmbOk]){
                    if(1==self.over){
                        [NSThread detachNewThreadSelector:@selector(setStatic) toTarget:self withObject:nil];
                    }
                }
                else{
                    [self exitNow];
                }
            }
        }
    }
}
-(BOOL)checkSmbOk{
    Reachability *reachability = [Reachability reachabilityWithHostName:kSmbIp];
    [Reachability startCheckWithReachability:reachability];
    return [Reachability isReachableSamba];
}
-(void)setStatic{
    self.over=0;
    NSString *url = @"http://10.10.1.1/:.wop:srouter:static:";
    if(0==[self.vbackup.text length]){
        url = [[[[[[[url stringByAppendingString:self.vipdr.text]stringByAppendingString:@":"]
                   stringByAppendingString:self.vsubnet.text]
                  stringByAppendingString:@":"]
                 stringByAppendingString:self.vgateway.text]
                stringByAppendingString:@":"]
               stringByAppendingString:self.vprimary.text];
    }else{
        url = [[[[[[[[[url stringByAppendingString:self.vipdr.text]stringByAppendingString:@":"]
                     stringByAppendingString:self.vsubnet.text]
                    stringByAppendingString:@":"]
                   stringByAppendingString:self.vgateway.text]
                  stringByAppendingString:@":"]
                 stringByAppendingString:self.vprimary.text]stringByAppendingString:@","]
               stringByAppendingString:self.vbackup.text];
    }
    NSLog(@"url %@",url);
    if([Httphelper setURLRequest:url]){
        [self performSelectorOnMainThread:@selector(senterEndpage) withObject:nil waitUntilDone:NO];
    }
    else{
        [self exitNow];
    }
}
-(void)senterEndpage
{
    self.over =1;
    WFEndPageViewController *endpage = [[WFEndPageViewController alloc]init];
    endpage.message = @"Static";
    [self.navigationController pushViewController:endpage animated:YES];
}
-(void)exitNow{
    [[[[iToast makeText:NSLocalizedString(@"No device connected", @"")] setGravity:iToastGravityBottom] setDuration:iToastDurationNormal] show];
    [self.navigationController popViewControllerAnimated:YES];
}
-(BOOL)checkEmpty{
    if (![self.vipdr.text length]) {
        [[[[iToast makeText:NSLocalizedString(@"ip empty", @"")] setGravity:iToastGravityBottom] setDuration:iToastDurationNormal] show];
        return NO;
    }
    if(![self.vsubnet.text length]){
        [[[[iToast makeText:NSLocalizedString(@"subnet empty", @"")] setGravity:iToastGravityBottom] setDuration:iToastDurationNormal] show];
        return NO;
    }
    if(![self.vgateway.text length]){
        [[[[iToast makeText:NSLocalizedString(@"gateway empty", @"")] setGravity:iToastGravityBottom] setDuration:iToastDurationNormal] show];
        return NO;
    }
    if(![self.vprimary.text length]){
        [[[[iToast makeText:NSLocalizedString(@"primary empty", @"")] setGravity:iToastGravityBottom] setDuration:iToastDurationNormal] show];
        return NO;
    }
    return YES;
}
-(bool)checkValidity{
    if (![Httphelper ifIPInfoValidity: self.vipdr.text :0]) {
        [[[[iToast makeText:NSLocalizedString(@"ip error", @"")] setGravity:iToastGravityBottom] setDuration:iToastDurationNormal] show];
        return NO;
    }
    if (![Httphelper ifIPInfoValidity: self.vsubnet.text :1]) {
        [[[[iToast makeText:NSLocalizedString(@"subnet error", @"")] setGravity:iToastGravityBottom] setDuration:iToastDurationNormal] show];
        return NO;
    }
    if (![Httphelper ifIPInfoValidity: self.vgateway.text :2]) {
        [[[[iToast makeText:NSLocalizedString(@"gateway error", @"")] setGravity:iToastGravityBottom] setDuration:iToastDurationNormal] show];
        return NO;
    }
    if (![Httphelper ifIPInfoValidity: self.vprimary.text :3]) {
        [[[[iToast makeText:NSLocalizedString(@"primary error", @"")] setGravity:iToastGravityBottom] setDuration:iToastDurationNormal] show];
        return NO;
    }
    if (![Httphelper ifIPInfoValidity: self.vbackup.text :4]) {
        [[[[iToast makeText:NSLocalizedString(@"backup error", @"")] setGravity:iToastGravityBottom] setDuration:iToastDurationNormal] show];
        return NO;
    }
    NSRange range=[self.vipdr.text rangeOfString:@"10.10.1"];
    if(range.length>0){
        [[[[iToast makeText:NSLocalizedString(@"ip crash error", @"")] setGravity:iToastGravityBottom] setDuration:iToastDurationNormal] show];
        return NO;
    }
    return YES;
}
//开始编辑输入框的时候，软键盘出现，执行此事件
-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    NSLog(@"textFieldDid");
    CGRect frame = textField.frame;
    NSLog(@"textFieldDid frame.origin.y %f" ,frame.origin.y);
    NSLog(@"textFieldDid self.view.frame.size.height %f" ,self.view.frame.size.height);
    int offset = frame.origin.y + 152 - (self.view.frame.size.height - 216.0);//键盘高度216
    NSLog(@"textFieldDid %d" ,offset);
    NSTimeInterval animationDuration = 0.30f;
    [UIView beginAnimations:@"ResizeForKeyboard" context:nil];
    [UIView setAnimationDuration:animationDuration];
    
    //将视图的Y坐标向上移动offset个单位，以使下面腾出地方用于软键盘的显示
    if(offset > 0)
        self.view.frame = CGRectMake(0.0f, -offset, self.view.frame.size.width, self.view.frame.size.height);
    
    [UIView commitAnimations];
}

//当用户按下return键或者按回车键，keyboard消失
-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

//输入框编辑完成以后，将视图恢复到原始状态
-(void)textFieldDidEndEditing:(UITextField *)textField
{
    self.view.frame =CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
}
- (void)back
{
    //[RadioButton dealloc];
    [self.navigationController popViewControllerAnimated:YES];
}
@end