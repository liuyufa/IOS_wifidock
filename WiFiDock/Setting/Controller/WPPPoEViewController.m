//
//  WPPPoEViewController.m
//  WiFiDock
//
//  Created by hualu on 15-1-28.
//  Copyright (c) 2015年 cn.hualu.WiFiDock. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WPPPoEViewController.h"
#import "WFWizardViewController.h"
#import "WFEndPageViewController.h"
#import "Httphelper.h"
#import "iToast.h"
@interface WPPPoEViewController()
@property(nonatomic,weak)UITextField *vaccount;
@property(nonatomic,weak)UITextField *vpwd;
@property(nonatomic,weak)UIButton *bbutton;
@property(nonatomic,weak)UIButton *nbutton;
@property(nonatomic,assign)NSInteger over;
@end

@implementation WPPPoEViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    [self tapBackground];
    self.over = 1;
    self.navigationItem.title = NSLocalizedString(@"Setup Wizard",nil);
    NSLog(@"send to %@ in %@",@"WPPPoEViewController",self.message);
    [self setupSubview];
}

-(void)setupSubview
{
    UILabel *pppoeline = [[UILabel alloc] initWithFrame:CGRectMake(10,0,300,140)];
    pppoeline.backgroundColor = [UIColor clearColor];
    pppoeline.text = NSLocalizedString(@"PPPoELine", @"");
    [pppoeline setNumberOfLines:0];
    [pppoeline setLineBreakMode:NSLineBreakByWordWrapping];
    [self.view addSubview:pppoeline];
    
    UILabel *account = [[UILabel alloc]init];
    account.frame = CGRectMake(10, 160, 95, 20);
    account.text = NSLocalizedString(@"Account", @"");
    [self.view addSubview:account];
    
    UITextField *vaccount =[[UITextField alloc]init];
    vaccount.frame = CGRectMake(100, 150, 200, 40);
    vaccount.borderStyle=UITextBorderStyleRoundedRect;
    vaccount.font=[UIFont fontWithName:@"Times New Roman" size:20];
    vaccount.placeholder=NSLocalizedString(@"Please input account",nil);
    vaccount.tag = 5;
    vaccount.clearButtonMode=UITextFieldViewModeAlways;
    vaccount.clearsOnBeginEditing=NO;
    vaccount.layer.borderWidth =1.0;
    vaccount.layer.cornerRadius =5.0;
    self.vaccount = vaccount;
    [self.view addSubview:self.vaccount];
    
    UILabel *pwd = [[UILabel alloc]init];
    pwd.frame = CGRectMake(10, 220, 95, 20);
    pwd.text =  NSLocalizedString(@"Password", @"");
    [self.view addSubview:pwd];
    
    UITextField *vpwd =[[UITextField alloc]init];
    vpwd.frame = CGRectMake(100, 210, 200, 40);
    vpwd.borderStyle=UITextBorderStyleRoundedRect;
    vpwd.font=[UIFont fontWithName:@"Times New Roman" size:20];
    vpwd.placeholder=NSLocalizedString(@"Please input password",nil);
    vpwd.tag = 5;
    vpwd.clearButtonMode=UITextFieldViewModeAlways;
    vpwd.clearsOnBeginEditing=NO;
    vpwd.layer.borderWidth =1.0;
    vpwd.layer.cornerRadius =5.0;
    self.vpwd = vpwd;
    [self.view addSubview:self.vpwd];
    
    UIButton *bbutton = [[UIButton alloc]init];
    bbutton.frame = CGRectMake(20,270, 60, 35);
    [bbutton setBackgroundColor:[UIColor darkGrayColor]];
    [bbutton setTitle:NSLocalizedString(@"back",nil) forState:UIControlStateNormal];
    bbutton.layer.borderWidth = 1.0;
    bbutton.layer.cornerRadius = 5.0;
    [bbutton addTarget:self action:@selector(pbtnClick:) forControlEvents: UIControlEventTouchUpInside];
    bbutton.showsTouchWhenHighlighted = YES;
    bbutton.tag = 5;
    self.bbutton = bbutton;
    [self.view addSubview:self.bbutton];
    
    UIButton *nbutton = [[UIButton alloc]init];
    nbutton.frame = CGRectMake(240,270, 60, 35);
    [nbutton setBackgroundColor:[UIColor darkGrayColor]];
    [nbutton setTitle:NSLocalizedString(@"next",nil) forState:UIControlStateNormal];
    nbutton.layer.borderWidth = 1.0;
    nbutton.layer.cornerRadius = 5.0;
    [nbutton addTarget:self action:@selector(pbtnClick:) forControlEvents: UIControlEventTouchUpInside];
    nbutton.showsTouchWhenHighlighted = YES;
    nbutton.tag = 10;
    self.nbutton = nbutton;
    [self.view addSubview:self.nbutton];
}
- (void)pbtnClick:(UIButton *)button
{
    if(!self.over){
        return;
    }
    if(button.tag==5){
        [self.navigationController popViewControllerAnimated:YES];
        return;
    }
    if(button.tag==10){
        if(0==[self.vpwd.text length]||0==[self.vaccount.text length]){
            [[[[iToast makeText:NSLocalizedString(@"Password account is Empty", @"")] setGravity:iToastGravityBottom] setDuration:iToastDurationNormal] show];
            return;
        }else{
            self.over =0;
            [self setPPPoE];
        }
    }
}
-(void)tapBackground //在ViewDidLoad中调用
{
    UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapOnce)];//定义一个手势
    [tap setNumberOfTouchesRequired:1];//触击次数这里设为1
    [self.view addGestureRecognizer:tap];//添加手势到View中
}
-(void)tapOnce//手势方法
{
    [self.vaccount resignFirstResponder];
    [self.vpwd resignFirstResponder];
}
-(void)setPPPoE{
    NSString *url = @"http://10.10.1.1/:.wop:srouter:pppoe:";
    url = [[[url stringByAppendingString:self.vaccount.text]stringByAppendingString:@":"]stringByAppendingString:self.vpwd.text];
    if([Httphelper setURLRequest:url]){
        [self performSelectorOnMainThread:@selector(penterEndpage) withObject:nil waitUntilDone:NO];
    }
    else{
        [self exitNow];
    }
}
-(void)penterEndpage
{
    self.over =1;
    WFEndPageViewController *endpage = [[WFEndPageViewController alloc]init];
    endpage.message = @"PPPoE";
    [self.navigationController pushViewController:endpage animated:YES];
}
-(void)exitNow{
    [[[[iToast makeText:NSLocalizedString(@"No device connected", @"")] setGravity:iToastGravityBottom] setDuration:iToastDurationNormal] show];
    [self.navigationController popViewControllerAnimated:YES];
}
- (void)back
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

@end