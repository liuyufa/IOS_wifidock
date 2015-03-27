//
//  WFPreviewController.h
//  WiFiDock
//
//  Created by apple on 14-12-10.
//  Copyright (c) 2014年 cn.hualu.WiFiDock. All rights reserved.
//

#import <QuickLook/QuickLook.h>

@interface WFPreviewController : QLPreviewController

- (instancetype)initWithURL:(NSURL*)url query:(NSArray*)urls index:(NSInteger)index;

@end
