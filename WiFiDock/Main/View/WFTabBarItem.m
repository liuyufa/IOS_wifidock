//
//  WFTabBarItem.m
//  WiFiDock
//
//  Created by apple on 14-12-8.
//  Copyright (c) 2014年 cn.hualu.WiFiDock. All rights reserved.
//

#import "WFTabBarItem.h"

@implementation WFTabBarItem

- (id)initWithTitle:(NSString *)title image:(UIImage*)image selectedImage:(UIImage *)selectedImage dirPath:(NSString *)dirPath
{
    self = [super initWithTitle:title image:image selectedImage:selectedImage];
    if (self) {
        
        self.dirPath = dirPath;
        
    }
    return self;
}
@end
