//
//  WFEditBar.m
//  WiFiDock
//
//  Created by apple on 14-12-4.
//  Copyright (c) 2014年 cn.hualu.WiFiDock. All rights reserved.
//

#import "WFEditBar.h"
#import "WFEditButton.h"
#import "UIImage+IW.h"
@interface WFEditBar ()

@property (weak, nonatomic) WFEditButton *selectedButton;
@end
@implementation WFEditBar

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
        self.backgroundColor = WFColor(243, 244, 242);
        [self setupChildBtns];
    }
    
    return self;
}


- (void)setupChildBtns
{
    NSMutableArray *btn = [[NSMutableArray alloc]init];
    WFEditButton *copyBtn = [[WFEditButton alloc]init];
    [copyBtn setTitle:NSLocalizedString(@"Copy",nil) forState:UIControlStateNormal];
    
    [copyBtn setImage:[UIImage imageWithName:@"icon_toolbar_copy"] forState:UIControlStateNormal ];
    [self addSubview:copyBtn];
    [btn addObject:copyBtn];
    
    
    WFEditButton *allBtn = [[WFEditButton alloc]init];
    
    [allBtn setTitle:NSLocalizedString(@"All",nil) forState:UIControlStateNormal];
    [allBtn setImage:[UIImage imageWithName:@"icon_toolbar_selectall"] forState:UIControlStateNormal];
    [self addSubview:allBtn];
    [btn addObject:allBtn];
    
    WFEditButton *deleteBtn = [[WFEditButton alloc]init];
    [deleteBtn setTitle:NSLocalizedString(@"Delete",nil) forState:UIControlStateNormal];
    [deleteBtn setImage:[UIImage imageWithName:@"icon_toolbar_delete"] forState:UIControlStateNormal];
    [self addSubview:deleteBtn];
    [btn addObject:deleteBtn];
    
    WFEditButton *cutBtn = [[WFEditButton alloc]init];
    [cutBtn setTitle:NSLocalizedString(@"Cut",nil) forState:UIControlStateNormal];
    [cutBtn setImage:[UIImage imageWithName:@"icon_toolbar_cut"] forState:UIControlStateNormal];
    [self addSubview:cutBtn];
    [btn addObject:cutBtn];
 
    WFEditButton *moreBtn = [[WFEditButton alloc]init];
    [moreBtn setTitle:NSLocalizedString(@"encrypt",nil) forState:UIControlStateNormal];
    [moreBtn setImage:[UIImage imageWithName:@"icon_toolbar_encrypt"] forState:UIControlStateNormal];
   
    [self addSubview:moreBtn];
    [btn addObject:moreBtn];
    
    self.tabBarButtons = [btn copy];
}


- (void)buttonClick:(WFEditButton *)button
{
    if ([self.delegate respondsToSelector:@selector(editBar:didSelectedButtonFrom:to:)]) {
        [self.delegate editBar:self didSelectedButtonFrom:self.selectedButton to:button];
        
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
        
        WFEditButton *button = self.tabBarButtons[index];
       
        [button addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchDown];
        
        button.tag = index;
    
        CGFloat buttonX = index * buttonW;
        
        button.frame = CGRectMake(buttonX, 0, buttonW, buttonH);
    }
}
@end
