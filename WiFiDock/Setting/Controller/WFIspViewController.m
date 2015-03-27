//
//  WFIspViewController.m
//  WiFiDock
//
//  Created by hualu on 15-2-4.
//  Copyright (c) 2015年 cn.hualu.WiFiDock. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WFIspViewController.h"
#import "WFEndPageViewController.h"
#import "Reachability+WF.h"
#import "Reachability.h"
#import "Httphelper.h"
#import "iToast.h"
@interface WFIspViewController ()
@property(nonatomic,weak)UILabel *area;
@property(nonatomic,weak)UILabel *isp;
@property(nonatomic,strong)UIButton *barea;
@property(nonatomic,strong)UIButton *bisp;

@property(nonatomic,strong)UIButton *backbutton;
@property(nonatomic,strong)UIButton *nextbutton;
@property(nonatomic,assign)NSInteger over;

@end

@implementation WFIspViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    self.over=1;
    self.navigationItem.title = NSLocalizedString(@"Setup Wizard",nil);
    [self setupSubview];
}
-(void)setupSubview
{
    UILabel *ispline = [[UILabel alloc] initWithFrame:CGRectMake(10,0,300,120)];
    ispline.backgroundColor = [UIColor clearColor];
    ispline.text = NSLocalizedString(@"IspLine", @"");
    [ispline setNumberOfLines:0];
    ispline.font = [UIFont fontWithName:@"Helvetica" size:16];
    [ispline setLineBreakMode:NSLineBreakByWordWrapping];
    [self.view addSubview:ispline];
    
    //    UILabel *type = [[UILabel alloc]init];
    //    type.frame = CGRectMake(20, 160, 110, 30);
    //    type.text = NSLocalizedString(@"adr type", @"");
    //    self.type = type;
    //
    //    UIButton *btype = [[UIButton alloc]init];
    //    btype.frame = CGRectMake(100,160, 180, 35);
    //    [btype setBackgroundColor:[UIColor darkGrayColor]];
    //    [btype setTitle:NSLocalizedString(@"next",nil) forState:UIControlStateNormal];
    //    btype.layer.borderWidth = 1.0;
    //    btype.layer.cornerRadius = 5.0;
    //    [btype addTarget:self action:@selector(bbtnClick:) forControlEvents: UIControlEventTouchUpInside];
    //    btype.showsTouchWhenHighlighted = YES;
    //    btype.tag = 5;
    //    self.btype = btype;
    
    UILabel *area = [[UILabel alloc]init];
    area.frame = CGRectMake(20, 140, 110, 30);
    area.text = NSLocalizedString(@"area", @"");
    self.area = area;
    
    UIButton *barea = [[UIButton alloc]init];
    barea.frame = CGRectMake(100,140, 180, 35);
    [barea setBackgroundColor:[UIColor darkGrayColor]];
    [barea setTitle:NSLocalizedString(@"China",nil) forState:UIControlStateNormal];
    barea.layer.borderWidth = 1.0;
    barea.layer.cornerRadius = 5.0;
    [barea addTarget:self action:@selector(bbtnClick:) forControlEvents: UIControlEventTouchUpInside];
    barea.showsTouchWhenHighlighted = YES;
    barea.tag = 10;
    self.barea = barea;
    
    UILabel *isp = [[UILabel alloc]init];
    isp.frame = CGRectMake(20, 200, 110, 30);
    isp.text = NSLocalizedString(@"isp", @"");
    self.isp = isp;
    
    UIButton *bisp = [[UIButton alloc]init];
    bisp.frame = CGRectMake(100,200, 180, 35);
    [bisp setBackgroundColor:[UIColor darkGrayColor]];
    [bisp setTitle:NSLocalizedString(@"China mobile",nil) forState:UIControlStateNormal];
    bisp.layer.borderWidth = 1.0;
    bisp.layer.cornerRadius = 5.0;
    [bisp addTarget:self action:@selector(bbtnClick:) forControlEvents: UIControlEventTouchUpInside];
    bisp.showsTouchWhenHighlighted = YES;
    bisp.tag = 15;
    self.bisp = bisp;
    
    UIButton *backbutton = [[UIButton alloc]init];
    backbutton.frame = CGRectMake(30,300, 60, 35);
    [backbutton setBackgroundColor:[UIColor darkGrayColor]];
    [backbutton setTitle:NSLocalizedString(@"back",nil) forState:UIControlStateNormal];
    backbutton.layer.borderWidth = 1.0;
    backbutton.layer.cornerRadius = 5.0;
    [backbutton addTarget:self action:@selector(bbtnClick:) forControlEvents: UIControlEventTouchUpInside];
    backbutton.showsTouchWhenHighlighted = YES;
    backbutton.tag = 20;
    self.backbutton = backbutton;
    
    UIButton *nextbutton = [[UIButton alloc]init];
    nextbutton.frame = CGRectMake(240,300, 60, 35);
    [nextbutton setBackgroundColor:[UIColor darkGrayColor]];
    [nextbutton setTitle:NSLocalizedString(@"next",nil) forState:UIControlStateNormal];
    nextbutton.layer.borderWidth = 1.0;
    nextbutton.layer.cornerRadius = 5.0;
    [nextbutton addTarget:self action:@selector(bbtnClick:) forControlEvents: UIControlEventTouchUpInside];
    nextbutton.showsTouchWhenHighlighted = YES;
    nextbutton.tag = 25;
    self.nextbutton = nextbutton;
    
    //[self.view addSubview:self.type];
    [self.view addSubview:self.area];
    [self.view addSubview:self.isp];
    
    [self.view addSubview:self.barea];
    [self.view addSubview:self.bisp];
    [self.view addSubview:self.backbutton];
    [self.view addSubview:self.nextbutton];
}
- (void)testActionSheetDynamic {
    // 创建时不指定按钮
    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"isp", @"")   delegate:self
                                              cancelButtonTitle:nil
                                         destructiveButtonTitle:nil
                                              otherButtonTitles:nil];
    // 逐个添加按钮（比如可以是数组循环）
    [sheet addButtonWithTitle:NSLocalizedString(@"China mobile",nil)];
    [sheet addButtonWithTitle:NSLocalizedString(@"China unicom",nil)];
    [sheet addButtonWithTitle:NSLocalizedString(@"China telecom",nil)];
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
            NSLog(@"Item A Selected");
            [self.bisp setTitle:NSLocalizedString(@"China mobile",nil) forState:UIControlStateNormal];
            break;
        }
        case 1: {
            NSLog(@"Item B Selected");
            [self.bisp setTitle:NSLocalizedString(@"China unicom",nil) forState:UIControlStateNormal];
            break;
        }
        case 2: {
            NSLog(@"Item C Selected");
            [self.bisp setTitle:NSLocalizedString(@"China telecom",nil) forState:UIControlStateNormal];
            break;
        }
    }
}
- (void)bbtnClick:(UIButton *)button
{
    if(10==button.tag){
        return;
    }
    if(15==button.tag){
        [self testActionSheetDynamic];
    }
    if(20==button.tag){
        [self.navigationController popViewControllerAnimated:YES];
    }
    if(25==button.tag){
        if([self checkSmbOk]){
            if(1==self.over){
                [NSThread detachNewThreadSelector:@selector(setIsp) toTarget:self withObject:nil];
            }
        }
        else{
            [self exitNow];
        }
    }
}
-(void)setIsp
{
    self.over=0;
    [self setModefor3G];
    NSString *url = @"http://10.10.1.1/:.wop:3g-connect";
    if([Httphelper setURLRequest:url])
    {
        [self performSelectorOnMainThread:@selector(ienterEndpage) withObject:nil waitUntilDone:NO];
    }
    else{
        [self exitNow];
    }
}
-(BOOL)setModefor3G{
    NSString *cmdap = @"http://10.10.1.1/:.wop:smode:3g";
    if([Httphelper setURLRequest:cmdap])
    {
        NSString *getmod = @"http://10.10.1.1/:.wop:gmode";
        NSData *data =[Httphelper httpPostSyn:getmod];
        if(data==nil){
            NSLog(@"cmd did not send !");
            return NO;
        }
        else{
            NSString *str = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
            NSRange rang =[str rangeOfString:@"3g"];
            if(rang.length>0){
                return YES;
            }
        }
    }
    return NO;
}
-(void)ienterEndpage
{
    self.over =1;
    WFEndPageViewController *endpage = [[WFEndPageViewController alloc]init];
    endpage.message = @"Isp";
    [self.navigationController pushViewController:endpage animated:YES];
}
-(void)exitNow{
    [[[[iToast makeText:NSLocalizedString(@"No device connected", @"")] setGravity:iToastGravityBottom] setDuration:iToastDurationNormal] show];
    [self.navigationController popViewControllerAnimated:YES];
}
-(BOOL)checkSmbOk{
    Reachability *reachability = [Reachability reachabilityWithHostName:kSmbIp];
    [Reachability startCheckWithReachability:reachability];
    return [Reachability isReachableSamba];
}
@end