
//
//  WFButton.m
//  WiFiDock
//
//  Created by apple on 15-1-13.
//  Copyright (c) 2015年 cn.hualu.WiFiDock. All rights reserved.
//

#import "WFButton.h"
const double WFTabBarImageRatio = 0.8;
@implementation WFButton

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if(self){
        self.imageView.contentMode = UIViewContentModeCenter;
        self.titleLabel.textAlignment = NSTextAlignmentCenter;
        self.titleLabel.font = [UIFont systemFontOfSize:20];
        
        [self.layer setBorderWidth:1.0];
        self.layer.backgroundColor = (__bridge CGColorRef)([UIImage imageNamed:@"main_splitter"]);
        
        
    }
    
    return self;
}

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

@end
