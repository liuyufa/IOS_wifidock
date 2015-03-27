//
//  WFPath.h
//  WiFiDock
//
//  Created by apple on 15-1-12.
//  Copyright (c) 2015年 cn.hualu.WiFiDock. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WFPath : NSObject

@property(nonatomic,copy)NSString *rootPath;
@property(nonatomic,copy)NSString *rootName;

-(instancetype)initWithPath:(NSString *)path name:(NSString *)name;

@end
