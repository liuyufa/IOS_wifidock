//
//  WPPPoEViewController.m
//  WiFiDock
//
//  Created by hualu on 15-1-28.
//  Copyright (c) 2015年 cn.hualu.WiFiDock. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WFNPPPoEViewController.h"
#import "WFWizardViewController.h"
#import "WFEndPageViewController.h"
#import "WFNDhcpViewController.h"
#import "WFNIspViewController.h"
#import "WFNStaticViewController.h"
#import "Httphelper.h"
#import "iToast.h"
@interface WFNPPPoEViewController()
@property(nonatomic,weak)UITextField *vaccount;
@property(nonatomic,weak)UITextField *vpwd;
@property(nonatomic,weak)UILabel *type;
@property(nonatomic,weak)UIButton *badrtype;
@property(nonatomic,weak)UIButton *bbutton;
@property(nonatomic,weak)UIButton *nbutton;
@property(nonatomic,assign)NSInteger over;

@property(nonatomic,copy)NSString *tmpaccount;
@property(nonatomic,copy)NSString *tmppwd;

@end

@implementation WFNPPPoEViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    [self tapBackground];
    self.over = 1;
    self.navigationItem.title = NSLocalizedString(@"NetWork Parameter",nil);
    NSLog(@"send to %@ in %@",@"WPPPoEViewController",self.message);
    [self setupSubview];
}

-(void)setupSubview
{
    UILabel *type = [[UILabel alloc]init];
    type.frame = CGRectMake(20, 80, 110, 30);
    type.text = NSLocalizedString(@"adr type", @"");
    self.type = type;
    [self.view addSubview:self.type];
    
    UIButton *badrtype = [[UIButton alloc]init];
    badrtype.frame = CGRectMake(100,80, 180, 35);
    [badrtype setBackgroundColor:[UIColor darkGrayColor]];
    [badrtype setTitle:NSLocalizedString(@"NPPPoE",nil) forState:UIControlStateNormal];
    badrtype.layer.borderWidth = 1.0;
    badrtype.layer.cornerRadius = 5.0;
    [badrtype addTarget:self action:@selector(npbtnClick:) forControlEvents: UIControlEventTouchUpInside];
    badrtype.showsTouchWhenHighlighted = YES;
    badrtype.tag = 1;
    self.badrtype = badrtype;
    [self.view addSubview:self.badrtype];
    
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
    [bbutton setTitle:NSLocalizedString(@"Save",nil) forState:UIControlStateNormal];
    bbutton.layer.borderWidth = 1.0;
    bbutton.layer.cornerRadius = 5.0;
    [bbutton addTarget:self action:@selector(npbtnClick:) forControlEvents: UIControlEventTouchUpInside];
    bbutton.showsTouchWhenHighlighted = YES;
    bbutton.tag = 5;
    self.bbutton = bbutton;
    [self.view addSubview:self.bbutton];
    
    UIButton *nbutton = [[UIButton alloc]init];
    nbutton.frame = CGRectMake(240,270, 60, 35);
    [nbutton setBackgroundColor:[UIColor darkGrayColor]];
    [nbutton setTitle:NSLocalizedString(@"Restore",nil) forState:UIControlStateNormal];
    nbutton.layer.borderWidth = 1.0;
    nbutton.layer.cornerRadius = 5.0;
    [nbutton addTarget:self action:@selector(npbtnClick:) forControlEvents: UIControlEventTouchUpInside];
    nbutton.showsTouchWhenHighlighted = YES;
    nbutton.tag = 10;
    self.nbutton = nbutton;
    self.tmpaccount=self.vaccount.text;
    self.tmppwd=self.vpwd.text;
    [self.view addSubview:self.nbutton];
    
}
- (void)npbtnClick:(UIButton *)button
{
    if(!self.over){
        return;
    }
    if(button.tag==1){
        [self actionSheetforParameter];
    }
    if(button.tag==5){
        if(0==[self.vpwd.text length]||0==[self.vaccount.text length]){
            [[[[iToast makeText:NSLocalizedString(@"Password account is Empty", @"")] setGravity:iToastGravityBottom] setDuration:iToastDurationNormal] show];
            return;
        }else{
            self.over =0;
            [self setnPPPoE];
        }
        
    }
    if(button.tag==10){
        self.vaccount.text=self.tmpaccount;
        self.vpwd.text=self.tmppwd;
    }
}
- (void)actionSheetforParameter {
    // 创建时不指定按钮
    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"NetWork Parameter", @"")   delegate:self
                                              cancelButtonTitle:nil
                                         destructiveButtonTitle:nil
                                              otherButtonTitles:nil];
    // 逐个添加按钮（比如可以是数组循环）
    [sheet addButtonWithTitle:NSLocalizedString(@"NDynamic",nil)];
    [sheet addButtonWithTitle:NSLocalizedString(@"NStatic",nil)];
    [sheet addButtonWithTitle:NSLocalizedString(@"NPPPoE",nil)];
    [sheet addButtonWithTitle:NSLocalizedString(@"3G",nil)];
    // 同时添加一个取消按钮
    [sheet addButtonWithTitle:NSLocalizedString(@"Cancel",nil)];
    // 将取消按钮的index设置成我们刚添加的那个按钮，这样在delegate中就可以知道是那个按钮
    // NB - 这会导致该按钮显示时有黑色背景
    sheet.cancelButtonIndex = sheet.numberOfButtons-1;
    [sheet showFromRect:self.view.bounds inView:self.view animated:YES];
}
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == actionSheet.cancelButtonIndex)
    { return; }
    switch (buttonIndex)
    {
        case 0: {
            WFNDhcpViewController *Dhcppage = [[WFNDhcpViewController alloc]init];
            [self.navigationController pushViewController:Dhcppage animated:YES];
            break;
        }
        case 1: {
            WFNStaticViewController *pppage = [[WFNStaticViewController alloc]init];
            [self.navigationController pushViewController:pppage animated:YES];
            break;
        }
        case 2: {
            break;
        }
        case 3: {
            WFNIspViewController *Isppage = [[WFNIspViewController alloc]init];
            [self.navigationController pushViewController:Isppage animated:YES];
            break;
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
-(void)setnPPPoE{
    NSString *url = @"http://10.10.1.1/:.wop:srouter:pppoe:";
    url = [[[url stringByAppendingString:self.vaccount.text]stringByAppendingString:@":"]stringByAppendingString:self.vpwd.text];
    if([Httphelper setURLRequest:url]){
        [self performSelectorOnMainThread:@selector(npenterEndpage) withObject:nil waitUntilDone:NO];
    }
    else{
        [self exitNow];
    }
}
-(void)npenterEndpage
{
    self.over =1;
    self.tmpaccount=self.vaccount.text;
    self.tmppwd=self.vpwd.text;
    [[[[iToast makeText:NSLocalizedString(@"Save success", @"")] setGravity:iToastGravityBottom] setDuration:iToastDurationNormal] show];
}
-(void)exitNow{
    [[[[iToast makeText:NSLocalizedString(@"No device connected", @"")] setGravity:iToastGravityBottom] setDuration:iToastDurationNormal] show];
    //[self.navigationController popViewControllerAnimated:YES];
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