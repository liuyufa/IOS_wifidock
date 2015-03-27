//
//  WFViewController.m
//  WiFiDock
//
//  Created by apple on 14-12-1.
//  Copyright (c) 2014年 cn.hualu.WiFiDock. All rights reserved.
//

#import "WFViewController.h"
#import "WFMusicViewController.h"
#import "WFVideoViewController.h"
#import "WFImageViewController.h"
#import "WFFileViewController.h"
#import "WFManageViewController.h"
#import "WFSettingViewController.h"
#import "WFBackupViewController.h"
#import "WFStatusViewController.h"
#import "WFBaseController.h"
#import "WFNavigationController.h"

#import "WFFileUtil.h"
#import "UIImage+IW.h"
#import "WFButton.h"


@interface WFViewController ()
@property(nonatomic, strong)UIImageView *bgImageView;
@property(nonatomic, strong)UIImageView *logo;
@property(nonatomic, strong)UIImageView *titlelogo;
@property(nonatomic, weak)UIButton *musicbtn;
@property(nonatomic, weak)UIButton *videobtn;
@property(nonatomic, weak)UIButton *picturebtn;
@property(nonatomic, weak)UIButton *documentbtn;
@property(nonatomic, weak)UIButton *managerbtn;
@property(nonatomic, weak)UIButton *systembtn;
@property(nonatomic, weak)UIButton *backupsbtn;
@property(nonatomic, weak)UIButton *statusbtn;
@end

@implementation WFViewController

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.bgImageView = [[UIImageView alloc]init];
    self.bgImageView.frame = self.view.frame;
    self.bgImageView.userInteractionEnabled = YES;
    self.bgImageView.backgroundColor = [UIColor clearColor];
    self.bgImageView.autoresizesSubviews = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    self.bgImageView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    self.bgImageView.contentMode = UIViewContentModeScaleToFill;
    
    [self.bgImageView setImage:[UIImage imageWithName:@"main_bg" ]];
    [self.view addSubview:self.bgImageView];
    
    self.logo = [[UIImageView alloc] initWithImage:[UIImage imageWithName:@"hualu_logo.png"]];
    self.titlelogo = [[UIImageView alloc] initWithImage:[UIImage imageWithName:@"title_logo.png"]];
    
    self.titlelogo.frame = CGRectMake(self.view.frame.size.width-self.titlelogo.image.size.width, 0, self.titlelogo.image.size.width, self.titlelogo.image.size.height);
    
    self.logo.frame = CGRectMake(10, self.titlelogo.image.size.height-self.logo.image.size.height, self.logo.image.size.width, self.logo.image.size.height);
    
    
    self.musicbtn = [WFButton buttonWithType:UIButtonTypeCustom];

    self.musicbtn.backgroundColor = [UIColor colorWithRed:55 green:87 blue:41 alpha:0.3];
    [self.musicbtn setImage:[UIImage imageWithName:@"icon_main_music"] forState:UIControlStateNormal];
    
    
    [self.musicbtn setTitle:NSLocalizedString(@"Music",nil) forState:UIControlStateNormal];
    self.musicbtn.titleLabel.textAlignment = NSTextAlignmentCenter;
    self.musicbtn.contentVerticalAlignment =UIControlContentVerticalAlignmentCenter ;

    self.musicbtn.contentEdgeInsets = UIEdgeInsetsMake(0,0, 20, 0);
   
    self.musicbtn.tag = 5;
    [self.musicbtn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
    
    self.videobtn = [WFButton buttonWithType:UIButtonTypeCustom];
    [self.videobtn setImage:[UIImage imageWithName:@"icon_main_video"] forState:UIControlStateNormal];
    self.videobtn.backgroundColor = [UIColor colorWithRed:55 green:87 blue:41 alpha:0.3];
    [self.videobtn setTitle:NSLocalizedString(@"Video",nil) forState:UIControlStateNormal];
    self.videobtn.contentVerticalAlignment =UIControlContentVerticalAlignmentBottom;
    
    self.videobtn.contentEdgeInsets = UIEdgeInsetsMake(0,0, 20, 0);
    self.videobtn.tag = 10;
    [self.videobtn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
    
    
    
    self.picturebtn = [WFButton buttonWithType:UIButtonTypeCustom];
    [self.picturebtn setImage:[UIImage imageWithName:@"icon_main_image"] forState:UIControlStateNormal];
    [self.picturebtn setTitle:NSLocalizedString(@"Image",nil) forState:UIControlStateNormal];
    self.picturebtn.contentVerticalAlignment =UIControlContentVerticalAlignmentBottom;
    self.picturebtn.backgroundColor = [UIColor colorWithRed:55 green:87 blue:41 alpha:0.3];
    self.picturebtn.contentEdgeInsets = UIEdgeInsetsMake(0,0, 30, 0);
    self.picturebtn.tag = 20;
    [self.picturebtn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
    
    
    self.documentbtn = [WFButton buttonWithType:UIButtonTypeCustom];
    [self.documentbtn setImage:[UIImage imageWithName:@"icon_main_file"] forState:UIControlStateNormal];
    [self.documentbtn setTitle:NSLocalizedString(@"Document",nil) forState:UIControlStateNormal];
    self.documentbtn.backgroundColor = [UIColor colorWithRed:55 green:87 blue:41 alpha:0.3];
    self.documentbtn.contentVerticalAlignment =UIControlContentVerticalAlignmentBottom;
    
    self.documentbtn.contentEdgeInsets = UIEdgeInsetsMake(0,0, 30, 0);
    self.documentbtn.tag = 30;
    [self.documentbtn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
    
    self.managerbtn = [WFButton buttonWithType:UIButtonTypeCustom];
    [self.managerbtn setImage:[UIImage imageWithName:@"icon_main_manage"] forState:UIControlStateNormal];
    self.managerbtn.backgroundColor = [UIColor colorWithRed:55 green:87 blue:41 alpha:0.3];
    [self.managerbtn setTitle:NSLocalizedString(@"Manage",nil) forState:UIControlStateNormal];
    self.managerbtn.contentVerticalAlignment =UIControlContentVerticalAlignmentBottom;
    
    self.managerbtn.contentEdgeInsets = UIEdgeInsetsMake(0,0, 30, 0);
    self.managerbtn.tag = 40;
    [self.managerbtn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
    
    
    self.systembtn = [WFButton buttonWithType:UIButtonTypeCustom];
    [self.systembtn setImage:[UIImage imageWithName:@"icon_main_setting"] forState:UIControlStateNormal];
    self.systembtn.backgroundColor = [UIColor colorWithRed:55 green:87 blue:41 alpha:0.3];
    [self.systembtn setTitle:NSLocalizedString(@"Setting",nil)forState:UIControlStateNormal];
    self.systembtn.contentVerticalAlignment =UIControlContentVerticalAlignmentBottom;
    self.systembtn.contentEdgeInsets = UIEdgeInsetsMake(0,0, 40, 0);
    self.systembtn.tag = 50;
    [self.systembtn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
    
    
    self.backupsbtn = [WFButton buttonWithType:UIButtonTypeCustom];
    [self.backupsbtn setImage:[UIImage imageWithName:@"icon_main_copy"] forState:UIControlStateNormal];
    [self.backupsbtn setTitle:NSLocalizedString(@"Backups",nil) forState:UIControlStateNormal];
    self.backupsbtn.backgroundColor = [UIColor colorWithRed:55 green:87 blue:41 alpha:0.3];
    self.backupsbtn.contentVerticalAlignment =UIControlContentVerticalAlignmentBottom;
    self.backupsbtn.contentEdgeInsets = UIEdgeInsetsMake(0,0, 40, 0);
    self.backupsbtn.tag = 60;
    [self.backupsbtn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
    
    
    self.statusbtn = [WFButton buttonWithType:UIButtonTypeCustom];
    [self.statusbtn setImage:[UIImage imageWithName:@"icon_main_status"] forState:UIControlStateNormal];
    self.statusbtn.backgroundColor = [UIColor colorWithRed:55 green:87 blue:41 alpha:0.3];
    [self.statusbtn setTitle:NSLocalizedString(@"Status",nil) forState:UIControlStateNormal];
    self.statusbtn.contentVerticalAlignment =UIControlContentVerticalAlignmentBottom;
    self.statusbtn.contentEdgeInsets = UIEdgeInsetsMake(0,0, 40, 0);
    self.statusbtn.tag = 70;
    [self.statusbtn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
    
    
    CGFloat height = self.view.frame.size.height - CGRectGetMaxY(self.titlelogo.frame);
    CGFloat viewW  = self.view.frame.size.width;

    self.musicbtn.frame = CGRectMake(0, CGRectGetMaxY(self.logo.frame)+20, viewW/2-1, height/3 );
    self.videobtn.frame = CGRectMake(CGRectGetMaxX(self.musicbtn.frame)+2, CGRectGetMaxY(self.logo.frame)+20, viewW/2-1, height/3 );

    self.picturebtn.frame =CGRectMake(0, CGRectGetMaxY(self.musicbtn.frame)+1, (viewW-4)/3, height/3);
    self.documentbtn.frame =CGRectMake(CGRectGetMaxX(self.picturebtn.frame)+2, CGRectGetMaxY(self.musicbtn.frame)+1, (viewW-4)/3, height/3);
    self.managerbtn.frame =CGRectMake(CGRectGetMaxX(self.documentbtn.frame)+2, CGRectGetMaxY(self.musicbtn.frame)+1, (viewW-4)/3, height/3);
    self.systembtn.frame =CGRectMake(0, CGRectGetMaxY(self.picturebtn.frame)+1, (viewW-4)/3, height/3);
    self.backupsbtn.frame =CGRectMake(CGRectGetMaxX(self.systembtn.frame)+2, CGRectGetMaxY(self.picturebtn.frame)+1, (viewW-4)/3, height/3);
    self.statusbtn.frame =CGRectMake(CGRectGetMaxX(self.backupsbtn.frame)+2, CGRectGetMaxY(self.picturebtn.frame)+1, (viewW-4)/3, height/3);

    
    [self.bgImageView addSubview:self.logo];
    [self.bgImageView addSubview:self.titlelogo];
    [self.bgImageView addSubview:self.musicbtn];
    [self.bgImageView addSubview:self.videobtn];
    [self.bgImageView addSubview:self.picturebtn];
    [self.bgImageView addSubview:self.documentbtn];
    [self.bgImageView addSubview:self.managerbtn];
    [self.bgImageView addSubview:self.systembtn];
    [self.bgImageView addSubview:self.backupsbtn];
    [self.bgImageView addSubview:self.statusbtn];
    
}

- (void)btnClick:(UIButton *)button
{
    if (button.tag == 5) {
        
        WFMusicViewController *music = [[WFMusicViewController alloc]init];
        
        [self.navigationController pushViewController:music animated:YES];
       
    }else if(button.tag == 10){
    
        WFVideoViewController *video = [[WFVideoViewController alloc]init];

        [self.navigationController pushViewController:video animated:YES];
        

    }else if (button.tag == 20){
       
        WFImageViewController *image = [[WFImageViewController alloc]init];
        [self.navigationController pushViewController:image animated:YES];

    }else if (button.tag == 30){
        WFFileViewController *file = [[WFFileViewController alloc]init];
        [self.navigationController pushViewController:file animated:YES];

        
    }else if (button.tag == 40){
         WFManageViewController *manage = [[WFManageViewController alloc]init];
        [self.navigationController pushViewController:manage animated:YES];

    }else if (button.tag == 50){
        WFSettingViewController *setting = [[WFSettingViewController alloc]init];
        [self.navigationController pushViewController:setting animated:YES];

    }else if (button.tag == 60){
        WFBackupViewController *backup = [[WFBackupViewController alloc]init];
        [self.navigationController pushViewController:backup animated:YES];

    }else if (button.tag == 70){
        WFStatusViewController *status = [[WFStatusViewController alloc]init];
        [self.navigationController pushViewController:status animated:YES];

    }
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (self.navigationController.navigationBar.hidden==NO) {
        self.navigationController.navigationBar.hidden = YES;
    }
    
    [self didRotateFromInterfaceOrientation:0];
    
}


-(void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    if (UIInterfaceOrientationIsPortrait(self.interfaceOrientation)) {
        
        self.titlelogo.frame = CGRectMake(self.view.frame.size.width-self.titlelogo.image.size.width, 0, self.titlelogo.image.size.width, self.titlelogo.image.size.height);
        self.logo.frame = CGRectMake(10, self.titlelogo.image.size.height-self.logo.image.size.height, self.logo.image.size.width, self.logo.image.size.height);
        
        float height = self.view.frame.size.height - CGRectGetMaxY(self.titlelogo.frame);
        
        CGFloat viewW = self.view.frame.size.width - 4;
        
        
        self.musicbtn.frame = CGRectMake(0, CGRectGetMaxY(self.logo.frame)+20, viewW/2, height/3 );
        self.videobtn.frame = CGRectMake(viewW/2+3, CGRectGetMaxY(self.logo.frame)+20, viewW/2, height/3 );
        
        self.picturebtn.frame =CGRectMake(0, CGRectGetMaxY(self.musicbtn.frame)+1, viewW/3, height/3);
        self.documentbtn.frame =CGRectMake(CGRectGetMaxX(self.picturebtn.frame)+2, CGRectGetMaxY(self.musicbtn.frame)+1, viewW/3, height/3);
        self.managerbtn.frame =CGRectMake(CGRectGetMaxX(self.documentbtn.frame)+2, CGRectGetMaxY(self.musicbtn.frame)+1, viewW/3, height/3);
        self.systembtn.frame =CGRectMake(0, CGRectGetMaxY(self.picturebtn.frame)+1, viewW/3, height/3);
        self.backupsbtn.frame =CGRectMake(CGRectGetMaxX(self.systembtn.frame)+2, CGRectGetMaxY(self.picturebtn.frame)+1, viewW/3, height/3);
        self.statusbtn.frame =CGRectMake(CGRectGetMaxX(self.backupsbtn.frame)+2, CGRectGetMaxY(self.picturebtn.frame)+1, viewW/3, height/3);
        
    }else{
    
        self.titlelogo.frame = CGRectMake(self.view.frame.size.width-self.titlelogo.image.size.width, 0, self.titlelogo.image.size.width, self.titlelogo.image.size.height);
        self.logo.frame = CGRectMake(10, self.titlelogo.image.size.height-self.logo.image.size.height, self.logo.image.size.width, self.logo.image.size.height);
        
        float height = self.view.frame.size.height - CGRectGetMaxY(self.titlelogo.frame);
        
        CGFloat musicY = CGRectGetMaxY(self.logo.frame)+10;
        CGFloat screenW = self.view.frame.size.width;
        
        self.musicbtn.frame = CGRectMake(0, musicY, screenW/4, height/2 );
        self.videobtn.frame = CGRectMake(CGRectGetMaxX(self.musicbtn.frame)+2, musicY, screenW/4, height/2);
        
        self.picturebtn.frame =CGRectMake(CGRectGetMaxX(self.videobtn.frame)+2, musicY, screenW/4, height/2);
        self.documentbtn.frame =CGRectMake(CGRectGetMaxX(self.picturebtn.frame)+2, musicY, screenW/4, height/2);
        
        CGFloat managerbtnY = CGRectGetMaxY(self.musicbtn.frame)+2;
        self.managerbtn.frame =CGRectMake(0, managerbtnY, screenW/4, height/2);
        self.systembtn.frame =CGRectMake(CGRectGetMaxX(self.managerbtn.frame)+2, managerbtnY, screenW/4, height/2);
        self.backupsbtn.frame =CGRectMake(CGRectGetMaxX(self.systembtn.frame)+2,managerbtnY, screenW/4, height/2);
        self.statusbtn.frame =CGRectMake(CGRectGetMaxX(self.backupsbtn.frame)+2, managerbtnY, screenW/4, height/2);
 
    }
}

@end
