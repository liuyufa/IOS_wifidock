//
//  WFWizardViewController1.m
//  WiFiDock
//
//  Created by hualu on 15-1-27.
//  Copyright (c) 2015年 cn.hualu.WiFiDock. All rights reserved.
//

//
//  WFWizardViewController.m
//  WiFiDock
//
//  Created by hualu on 15-1-19.
//  Copyright (c) 2015年 cn.hualu.WiFiDock. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Reachability.h"
#import "Reachability+WF.h"
#import "iToast.h"
#import "WFWizardViewController.h"
#import "WPPPoEViewController.h"
#import "WFEndPageViewController.h"
#import "WFStaticViewController.h"
#import "WFIspViewController.h"
#import "RadioButton.h"
#import "Httphelper.h"
#import "PassValueDelegate.h"
#import "UserEntity.h"
@interface WFWizardViewController()<RadioButtonDelegate,PassValueDelegate>
@property(nonatomic,assign)NSUInteger groupid;
@property(nonatomic,copy)NSString *getlast;
@property(nonatomic,strong)RadioButton *rb1;
@property(nonatomic,strong)RadioButton *rb2;
@property(nonatomic,strong)RadioButton *rb3;
@property(nonatomic,strong)RadioButton *rb4;
@property (assign,nonatomic) NSInteger over;
@end

@implementation WFWizardViewController
-(void)passValue:(UserEntity *)value
{
    self.getlast = value.getlast;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.over =1;
    self.navigationItem.title = NSLocalizedString(@"Setup Wizard",nil);
    if([self checkNetWorkInfo])
    {
        [self setupSubview];
    }
    else
    {
        [self exitNow];
    }
}

- (void)setupSubview
{
    UILabel *wizardline = [[UILabel alloc] initWithFrame:CGRectMake(10,0,300,180)];
    wizardline.backgroundColor = [UIColor clearColor];
    wizardline.text = NSLocalizedString(@"Thank you for using WiFi Dock.", @"");
    [wizardline setNumberOfLines:0];
    wizardline.font = [UIFont fontWithName:@"Helvetica" size:16];
    [wizardline setLineBreakMode:NSLineBreakByWordWrapping];
    [self.view addSubview:wizardline];
    
    RadioButton *rb1 = [[RadioButton alloc] initWithGroupId:@"first group" index:0];
    RadioButton *rb2 = [[RadioButton alloc] initWithGroupId:@"first group" index:1];
    RadioButton *rb3 = [[RadioButton alloc] initWithGroupId:@"first group" index:2];
    RadioButton *rb4 = [[RadioButton alloc] initWithGroupId:@"first group" index:3];
    rb1.frame = CGRectMake(10,200,40,40);
    rb2.frame = CGRectMake(10,240,40,40);
    rb3.frame = CGRectMake(10,280,40,40);
    rb4.frame = CGRectMake(10,320,40,40);
    [self.view addSubview:rb1];
    [self.view addSubview:rb2];
    [self.view addSubview:rb3];
    [self.view addSubview:rb4];
    
    [RadioButton addObserverForGroupId:@"first group" observer:self];
    
    UILabel *label1 =[[UILabel alloc] initWithFrame:CGRectMake(40, 190, 300, 40)];
    label1.backgroundColor = [UIColor clearColor];
    label1.text = NSLocalizedString(@"PPPoE", @"");
    [label1 setNumberOfLines:0];
    [label1 setLineBreakMode:NSLineBreakByWordWrapping];
    [self.view addSubview:label1];
    
    UILabel *label2 =[[UILabel alloc] initWithFrame:CGRectMake(40, 230, 300, 40)];
    label2.backgroundColor = [UIColor clearColor];
    label2.text = NSLocalizedString(@"Dynamic", @"");
    [label2 setNumberOfLines:0];
    [label2 setLineBreakMode:NSLineBreakByWordWrapping];
    [self.view addSubview:label2];
    
    UILabel *label3 =[[UILabel alloc] initWithFrame:CGRectMake(40, 270, 300, 40)];
    label3.backgroundColor = [UIColor clearColor];
    label3.text = NSLocalizedString(@"Static", @"");
    [label3 setNumberOfLines:0];
    [label3 setLineBreakMode:NSLineBreakByWordWrapping];
    [self.view addSubview:label3];
    
    UILabel *label4 =[[UILabel alloc] initWithFrame:CGRectMake(40, 310, 300, 40)];
    label4.backgroundColor = [UIColor clearColor];
    label4.text = NSLocalizedString(@"3G", @"");
    [label4 setNumberOfLines:0];
    [label4 setLineBreakMode:NSLineBreakByWordWrapping];
    [self.view addSubview:label4];
    
    UIButton *netbutton = [[UIButton alloc]init];
    netbutton.frame = CGRectMake(200,350, 60, 35);
    [netbutton setBackgroundColor:[UIColor darkGrayColor]];
    [netbutton setTitle:NSLocalizedString(@"Next",nil) forState:UIControlStateNormal];
    netbutton.layer.borderWidth = 1.0;
    netbutton.layer.cornerRadius = 5.0;
    [netbutton addTarget:self action:@selector(nbtnClick:) forControlEvents: UIControlEventTouchUpInside];
    netbutton.showsTouchWhenHighlighted = YES;
    netbutton.tag = 5;
    [self.view addSubview:netbutton];
}
- (void)nbtnClick:(UIButton *)button
{
    
    if(!self.over){
        return;
    }
    switch (self.groupid) {
        case 0:
        {
            WPPPoEViewController *pppoe = [[WPPPoEViewController alloc]init];
            pppoe.message = @"PPPoE";
            [self.navigationController pushViewController:pppoe animated:YES];
            break;
        }
        case 1:
        {
            self.over = 0;
            if([self checkSmbOk]){
                [NSThread detachNewThreadSelector:@selector(setDhcp) toTarget:self withObject:nil];
            }
            break;
        }
        case 2:
        {
            WFStaticViewController *sta = [[WFStaticViewController alloc]init];
            sta.message = @"Static";
            [self.navigationController pushViewController:sta animated:YES];
            break;
        }
        case 3:
        {
            WFIspViewController *isp = [[WFIspViewController alloc]init];
            isp.message = @"ISP";
            [self.navigationController pushViewController:isp animated:YES];
            break;
        }
        default:
            break;
    }
}
-(void)setDhcp{
    NSString *url = @"http://10.10.1.1/:.wop:srouter:dhcp";
    if([Httphelper setURLRequest:url]){
        [self performSelectorOnMainThread:@selector(enterEndpage) withObject:nil waitUntilDone:NO];
    }
    else{
        [self exitNow];
    }
}
-(void)enterEndpage
{
    self.over =1;
    WFEndPageViewController *endpage = [[WFEndPageViewController alloc]init];
    endpage.message = @"DHCP";
    [self.navigationController pushViewController:endpage animated:YES];
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

-(void)radioButtonSelectedAtIndex:(NSUInteger)index inGroup:(NSString *)groupId{
    NSLog(@"changed to %d in %@",index,groupId);
    self.groupid = index;
}

- (void)back
{
    //[RadioButton dealloc];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

-(void)dealloc
{
    NSLog(@"WFWizardViewController");
}
-(BOOL)checkSmbOk{
    Reachability *reachability = [Reachability reachabilityWithHostName:kSmbIp];
    [Reachability startCheckWithReachability:reachability];
    return [Reachability isReachableSamba];
}
-(void)exitNow{
    [[[[iToast makeText:NSLocalizedString(@"No device connected", @"")] setGravity:iToastGravityBottom] setDuration:iToastDurationNormal] show];
    [self.navigationController popViewControllerAnimated:YES];
}
@end
