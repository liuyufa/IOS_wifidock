//
//  WFProgress.h
//  WiFiDock
//
//  Created by apple on 15-1-8.
//  Copyright (c) 2015年 cn.hualu.WiFiDock. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WFProgress : UIView
@property(nonatomic,assign)float progress;
@property(nonatomic,strong)UIColor *innerColor;
@property(nonatomic,strong)UIColor *emptyColor;
@property(nonatomic,strong)UIColor *outerColor;
@end
