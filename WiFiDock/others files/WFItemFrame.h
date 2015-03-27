//
//  WFItemFrame.h
//  WiFiDock
//
//  Created by apple on 14-12-29.
//  Copyright (c) 2014年 cn.hualu.WiFiDock. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class WFFile;
@interface WFItemFrame : NSObject

@property(nonatomic,strong) WFFile *file;
@property (assign, nonatomic,readonly) CGRect iconViewF;
@property (assign, nonatomic,readonly) CGRect titleLableF;
@property (assign, nonatomic,readonly) CGRect subtitleLableF;
@property (assign, nonatomic,readonly) CGRect sizeLableF;

@end
