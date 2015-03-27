//
//  WFTabBarButton.m
//  WiFiDock
//
//  Created by apple on 14-12-3.
//  Copyright (c) 2014年 cn.hualu.WiFiDock. All rights reserved.
//

#import "WFTabBarButton.h"

const double WFTabBarImageRatio = 0.65;
#define WFTabBarButtonTitleSelectedColor  WFColorColor(236, 103, 0)
#define WFTabBarButtonTitleColor WFColor(65, 65, 65)
@implementation WFTabBarButton

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if(self){
        self.imageView.contentMode = UIViewContentModeCenter;
        self.titleLabel.textAlignment = NSTextAlignmentCenter;
        self.titleLabel.font = [UIFont systemFontOfSize:11];
        [self setTitleColor:WFColor(236, 103, 0) forState:UIControlStateSelected];
        [self setTitleColor:WFTabBarButtonTitleColor forState:UIControlStateNormal];
    }
    
    return self;
}

- (void)setHighlighted:(BOOL)highlighted {}

- (CGRect)titleRectForContentRect:(CGRect)contentRect
{
    CGFloat titleY = contentRect.size.height * WFTabBarImageRatio;
    CGFloat titleH = contentRect.size.height - titleY;
    CGFloat titleW = contentRect.size.width;
    return CGRectMake(0, titleY, titleW,  titleH);
}

-(CGRect)imageRectForContentRect:(CGRect)contentRect
{
    CGFloat imageH = contentRect.size.height * WFTabBarImageRatio;
    CGFloat imageW = contentRect.size.width;
    return CGRectMake(0, 0, imageW,  imageH);
}

-(void)setItem:(WFTabBarItem *)item
{
    _item = item;
  
    [item addObserver:self forKeyPath:@"title" options:NSKeyValueObservingOptionNew context:nil];
    [item addObserver:self forKeyPath:@"image" options:NSKeyValueObservingOptionNew context:nil];
    [item addObserver:self forKeyPath:@"selectedImage" options:NSKeyValueObservingOptionNew context:nil];
    
    
    
     
     [self observeValueForKeyPath:nil ofObject:nil change:nil context:nil];
   
}

-(void)dealloc
{
    [self.item removeObserver:self forKeyPath:@"title"];
    [self.item removeObserver:self forKeyPath:@"image"];
    [self.item removeObserver:self forKeyPath:@"selectedImage"];
   
    
}


- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    [self setTitle:self.item.title forState:UIControlStateNormal];
    [self setImage:self.item.image forState:UIControlStateNormal];
    [self setImage:self.item.selectedImage forState:UIControlStateSelected];
}

@end
