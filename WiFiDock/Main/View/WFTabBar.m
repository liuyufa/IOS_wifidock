//
//  WFTitleBar.m
//  WiFiDock
//
//  Created by apple on 14-12-3.
//  Copyright (c) 2014年 cn.hualu.WiFiDock. All rights reserved.
//

#import "WFTabBar.h"
#import "WFTabBarButton.h"
#import "WFTabBarItem.h"

@interface WFTabBar ()



@property (strong, nonatomic) NSMutableArray *tabBarButtons;
@end
@implementation WFTabBar

- (NSMutableArray *)tabBarButtons
{
    if (_tabBarButtons == nil) {
        _tabBarButtons = [NSMutableArray array];
    }
    return _tabBarButtons;
}

-(id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
//        self.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"tabbar_background"]];
        self.backgroundColor = WFColor(243, 244, 242);
        
    }
    
    return self;
}



-(void)addTabBarButtonWithItem:(WFTabBarItem *)item
{
    WFTabBarButton *button = [[WFTabBarButton alloc]init];
    
    button.item = item;
    
    [button addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchDown];
    [self addSubview:button];
    [self.tabBarButtons addObject:button];
    
    if (self.tabBarButtons.count == 1) {
        [self buttonClick:button];
    }
}

- (void)buttonClick:(WFTabBarButton *)button
{
    if ([self.delegate respondsToSelector:@selector(tabBar:didSelectedButtonFrom:to:)]) {
        [self.delegate tabBar:self didSelectedButtonFrom:self.selectedButton to:button];
        
    }
    
    self.selectedButton.selected = NO;
    button.selected = YES;
    self.selectedButton = button;
}

-(void)layoutSubviews
{
    [super layoutSubviews];
    
    CGFloat buttonH = self.frame.size.height;
    CGFloat buttonW = self.frame.size.width / self.tabBarButtons.count;
    for (int index = 0; index<self.tabBarButtons.count; index++) {
        WFTabBarButton *button = self.tabBarButtons[index];
        button.tag = index;
        CGFloat buttonX = index * buttonW;

        button.frame = CGRectMake(buttonX, 0, buttonW, buttonH);
       
    }
}
@end
