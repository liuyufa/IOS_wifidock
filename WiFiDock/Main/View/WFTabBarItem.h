//
//  WFTabBarItem.h
//  WiFiDock
//
//  Created by apple on 14-12-8.
//  Copyright (c) 2014年 cn.hualu.WiFiDock. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WFTabBarItem : UITabBarItem

@property(nonatomic, strong)NSString *dirPath;
@property(nonatomic, strong)NSMutableArray *dataSource;

- (instancetype)initWithTitle:(NSString *)title image:(UIImage*)image selectedImage:(UIImage *)selectedImage dirPath:(NSString *)dirPath;
@end
