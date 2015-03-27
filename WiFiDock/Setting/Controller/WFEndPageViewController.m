//
//  WFEndPageViewController.m
//  WiFiDock
//
//  Created by hualu on 15-2-4.
//  Copyright (c) 2015年 cn.hualu.WiFiDock. All rights reserved.
//

#import "WFEndPageViewController.h"
#import "UserEntity.h"
#import "iToast.h"
@interface WFEndPageViewController ()
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

@implementation WFEndPageViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = NSLocalizedString(@"Setup Wizard",nil);
    [self setupSubview];
}

-(void)setupSubview
{
    UILabel *endpageline = [[UILabel alloc] initWithFrame:CGRectMake(10,0,300,180)];
    endpageline.backgroundColor = [UIColor clearColor];
    endpageline.text = NSLocalizedString(@"LastPageLine", @"");
    [endpageline setNumberOfLines:0];
    endpageline.font = [UIFont fontWithName:@"Helvetica" size:16];
    [endpageline setLineBreakMode:NSLineBreakByWordWrapping];
    [self.view addSubview:endpageline];
    
    UIButton *savebutton = [[UIButton alloc]init];
    savebutton.frame = CGRectMake(30,200, 60, 35);
    [savebutton setBackgroundColor:[UIColor darkGrayColor]];
    [savebutton setTitle:NSLocalizedString(@"back",nil) forState:UIControlStateNormal];
    savebutton.layer.borderWidth = 1.0;
    savebutton.layer.cornerRadius = 5.0;
    [savebutton addTarget:self action:@selector(ebtnClick:) forControlEvents: UIControlEventTouchUpInside];
    savebutton.showsTouchWhenHighlighted = YES;
    savebutton.tag = 15;
    self.savebutton = savebutton;
    
    UIButton *restorebutton = [[UIButton alloc]init];
    restorebutton.frame = CGRectMake(240,200, 60, 35);
    [restorebutton setBackgroundColor:[UIColor darkGrayColor]];
    [restorebutton setTitle:NSLocalizedString(@"Save",nil) forState:UIControlStateNormal];
    restorebutton.layer.borderWidth = 1.0;
    restorebutton.layer.cornerRadius = 5.0;
    [restorebutton addTarget:self action:@selector(ebtnClick:) forControlEvents: UIControlEventTouchUpInside];
    restorebutton.showsTouchWhenHighlighted = YES;
    restorebutton.tag = 20;
    self.restorebutton = restorebutton;
    
    [self.view addSubview:self.savebutton];
    [self.view addSubview:self.restorebutton];
}
- (void)ebtnClick:(UIButton *)button
{
    UserEntity *userEntity = [[UserEntity alloc] init];
    userEntity.getlast = self.message;
    if(15==button.tag){
        if([self.message isEqualToString:@"DHCP"]){
            [self.navigationController popViewControllerAnimated:YES];
        }
        if([self.message isEqualToString:@"ISP"]){
            [self.navigationController popViewControllerAnimated:YES];
        }
        if([self.message isEqualToString:@"Static"]){
            [self.navigationController popViewControllerAnimated:YES];
        }
        if([self.message isEqualToString:@"PPPoE"]){
            [self.navigationController popViewControllerAnimated:YES];
        }
    }
    if(20==button.tag){
        if([self.message isEqualToString:@"DHCP"]){
            [[[[iToast makeText:NSLocalizedString(@"Save success", @"")] setGravity:iToastGravityBottom] setDuration:iToastDurationNormal] show];
            return;
        }
        if([self.message isEqualToString:@"ISP"]){
            [[[[iToast makeText:NSLocalizedString(@"Save success", @"")] setGravity:iToastGravityBottom] setDuration:iToastDurationNormal] show];
            return;
        }
        if([self.message isEqualToString:@"Static"]){
            [[[[iToast makeText:NSLocalizedString(@"Save success", @"")] setGravity:iToastGravityBottom] setDuration:iToastDurationNormal] show];
            return;
        }
        if([self.message isEqualToString:@"PPPoE"]){
            [[[[iToast makeText:NSLocalizedString(@"Save success", @"")] setGravity:iToastGravityBottom] setDuration:iToastDurationNormal] show];
            return;
        }
    }
}

@end