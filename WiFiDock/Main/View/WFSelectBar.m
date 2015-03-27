//
//  WFSelect.m
//  WiFiDock
//
//  Created by apple on 15-2-6.
//  Copyright (c) 2015年 cn.hualu.WiFiDock. All rights reserved.
//

#import "WFSelectBar.h"
#import "WFEditButton.h"
#import "UIImage+IW.h"


@interface WFSelectBar()

@property (weak, nonatomic) WFEditButton *selectedButton;

@end

@implementation WFSelectBar

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
    
    WFEditButton *pasteBtn = [[WFEditButton alloc]init];
    [pasteBtn setTitle:NSLocalizedString(@"Paste",nil) forState:UIControlStateNormal];
    
    [pasteBtn setImage:[UIImage imageWithName:@"icon_toolbar_paste"] forState:UIControlStateNormal ];
    [self addSubview:pasteBtn];
    [btn addObject:pasteBtn];
    
    WFEditButton *deleteBtn = [[WFEditButton alloc]init];
    [deleteBtn setTitle:NSLocalizedString(@"Delete",nil) forState:UIControlStateNormal];
    [deleteBtn setImage:[UIImage imageWithName:@"icon_toolbar_delete"] forState:UIControlStateNormal];
    [self addSubview:deleteBtn];
    [btn addObject:deleteBtn];
    
    WFEditButton *encryptBtn = [[WFEditButton alloc]init];
    [encryptBtn setTitle:NSLocalizedString(@"encrypt",nil) forState:UIControlStateNormal];
    
    [encryptBtn setImage:[UIImage imageWithName:@"icon_toolbar_encrypt"] forState:UIControlStateNormal ];
    [self addSubview:encryptBtn];
    [btn addObject:encryptBtn];
    
    
    WFEditButton *cancelBtn = [[WFEditButton alloc]init];
    [cancelBtn setTitle:NSLocalizedString(@"Cancel",nil) forState:UIControlStateNormal];
    
    [cancelBtn setImage:[UIImage imageWithName:@"icon_toolbar_cancel"] forState:UIControlStateNormal ];
    [self addSubview:cancelBtn];
    [btn addObject:cancelBtn];
    
    self.tabBarButtons = [btn copy];
}

- (void)buttonClick:(WFEditButton *)button
{
    if ([self.delegate respondsToSelector:@selector(selectBar:didSelectedButtonFrom:to:)]) {
        [self.delegate selectBar:self didSelectedButtonFrom:self.selectedButton to:button];
        
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
