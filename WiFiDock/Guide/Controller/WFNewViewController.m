//
//  WFNewViewController.m
//  WiFiDock
//
//  Created by apple on 14-12-21.
//  Copyright (c) 2014年 cn.hualu.WiFiDock. All rights reserved.
//

#import "WFNewViewController.h"
#import "UIImage+IW.h"
#import "WFViewController.h"
#import "WFNavigationController.h"
#define WFImageCount 3


@interface WFNewViewController () <UIScrollViewDelegate>
@property (nonatomic,weak) UIPageControl *pageControl;

@end

@implementation WFNewViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    [self setupScrollView];
    
    [self setupPageControll];
}

- (void)setupScrollView
{
    UIScrollView *scrollView = [[UIScrollView alloc] init];
    scrollView.frame = self.view.bounds;
    scrollView.delegate = self;
    [self.view addSubview:scrollView];
    
    CGFloat imageW = scrollView.frame.size.width;
    CGFloat imageH = scrollView.frame.size.height;
    
    for (int index = 0; index<WFImageCount; index++) {
        
        UIImageView *imageView = [[UIImageView alloc] init];
        
        NSString *name =nil;
        name = [NSString stringWithFormat:@"intro_%02d", index + 1];
//        if ([device isEqualToString:@"iPhone"]||[device isEqualToString:@"iPod touch"]) {
//           
//            name = [NSString stringWithFormat:@"intro_%02d", index + 1];
//           
//        }else{
//            name = [NSString stringWithFormat:@"intro_%02d~ipad", index + 1];
//           
//        }
        imageView.image = [UIImage imageWithName:name];
        
        CGFloat imageX = index * imageW;
        imageView.frame = CGRectMake(imageX, 0, imageW, imageH);
        
        [scrollView addSubview:imageView];
        
        if (index == WFImageCount - 1) {
            [self setupLastImageView:imageView];
        }
    }
    
    scrollView.contentSize = CGSizeMake(imageW * WFImageCount, 0);
    scrollView.showsHorizontalScrollIndicator = NO;
    scrollView.pagingEnabled = YES;
    scrollView.bounces = NO;
}

- (void)setupLastImageView:(UIImageView *)imageView
{
    imageView.userInteractionEnabled = YES;
    UIButton *startButton = [[UIButton alloc] init];
    [startButton setBackgroundImage:[UIImage imageWithName:@"new_feature_finish_button"] forState:UIControlStateNormal];
    [startButton setBackgroundImage:[UIImage imageWithName:@"new_feature_finish_button_highlighted"] forState:UIControlStateHighlighted];
    CGFloat centerX = imageView.frame.size.width * 0.5;
    CGFloat centerY = imageView.frame.size.height * 0.8;
    
    startButton.center = CGPointMake(centerX, centerY);
    startButton.bounds = (CGRect){CGPointZero, startButton.currentBackgroundImage.size};
    
    [startButton setTitle:NSLocalizedString(@"Go",nil) forState:UIControlStateNormal];
    [startButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [startButton addTarget:self action:@selector(start) forControlEvents:UIControlEventTouchUpInside];
    [imageView addSubview:startButton];
    
    
    UIButton *checkbox = [[UIButton alloc] init];
    checkbox.selected = YES;
    [checkbox setTitle:NSLocalizedString(@"Share",nil) forState:UIControlStateNormal];
    [checkbox setImage:[UIImage imageWithName:@"new_feature_share_false"] forState:UIControlStateNormal];
    [checkbox setImage:[UIImage imageWithName:@"new_feature_share_true"] forState:UIControlStateSelected];
    
    checkbox.bounds = CGRectMake(0, 0, 200, 50);
    CGFloat checkboxCenterX = centerX;
    CGFloat checkboxCenterY = imageView.frame.size.height * 0.7;

    checkbox.center = CGPointMake(checkboxCenterX, checkboxCenterY);
    [checkbox setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    
    checkbox.titleLabel.font = [UIFont systemFontOfSize:15];
    [checkbox addTarget:self action:@selector(checkboxClick:) forControlEvents:UIControlEventTouchUpInside];
    
    checkbox.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 10);
    [imageView addSubview:checkbox];
    
}

- (void)start
{
    WFViewController *root = [[WFViewController alloc] init];
    WFNavigationController *nav = [[WFNavigationController alloc] initWithRootViewController:root];
 
    self.view.window.rootViewController = nav;
}

- (void)checkboxClick:(UIButton *)checkbox
{
    checkbox.selected = !checkbox.isSelected;
}

- (void)setupPageControll
{
    UIPageControl *pageControl = [[UIPageControl alloc] init];
    pageControl.numberOfPages = WFImageCount;
    CGFloat centerX = self.view.frame.size.width * 0.5;
    CGFloat centerY = self.view.frame.size.height - 30;
    pageControl.center = CGPointMake(centerX, centerY);
    pageControl.bounds = CGRectMake(0, 0, 100, 30);
    pageControl.userInteractionEnabled = NO;
    [self.view addSubview:pageControl];
    self.pageControl = pageControl;
    
    pageControl.currentPageIndicatorTintColor = WFColor(253, 98, 42);
    pageControl.pageIndicatorTintColor = WFColor(189, 189, 189);

}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    
    CGFloat offsetX = scrollView.contentOffset.x;

    double pageDouble = offsetX / scrollView.frame.size.width;
    int pageInt = (int)(pageDouble + 0.5);
    self.pageControl.currentPage = pageInt;
}
@end
