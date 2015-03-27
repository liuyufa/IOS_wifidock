//
//  WFLocalViewController.h
//  WiFiDock
//
//  Created by apple on 14-12-3.
//  Copyright (c) 2014年 cn.hualu.WiFiDock. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WFBaseController.h"
#import "WFFile.h"

@interface WFLocalViewController : WFBaseController
- (instancetype)initWithFile:(WFFile *)file;

@end
