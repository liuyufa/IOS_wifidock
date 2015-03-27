//
//  WFPaste.h
//  WiFiDock
//
//  Created by apple on 15-1-21.
//  Copyright (c) 2015年 cn.hualu.WiFiDock. All rights reserved.
//

#import <Foundation/Foundation.h>
@class WFFile;
@interface WFPaste : NSObject
@property(nonatomic,copy)NSString *filePath;
@property(nonatomic,strong)WFFile *file;

@end
