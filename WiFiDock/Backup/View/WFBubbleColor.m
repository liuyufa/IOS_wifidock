//
//  WFBubbleColor.m
//  WiFiDock
//
//  Created by apple on 15-1-12.
//  Copyright (c) 2015年 cn.hualu.WiFiDock. All rights reserved.
//

#import "WFBubbleColor.h"

@implementation WFBubbleColor

- (id)initWithGradientTop:(UIColor *)gradientTop gradientBottom:(UIColor *)gradientBottom border:(UIColor *)border
{
    if (self = [super init]) {
        self.gradientTop = gradientTop;
        self.gradientBottom = gradientBottom;
        self.border = border;
    }
    return self;

}

@end
