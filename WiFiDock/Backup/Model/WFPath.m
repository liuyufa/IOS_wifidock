//
//  WFPath.m
//  WiFiDock
//
//  Created by apple on 15-1-12.
//  Copyright (c) 2015年 cn.hualu.WiFiDock. All rights reserved.
//

#import "WFPath.h"

@implementation WFPath

-(instancetype)initWithPath:(NSString *)path name:(NSString *)name
{
    self = [super init];
    
    if (self) {
        
        self.rootName = name;
        self.rootPath = path;
    }
    return self;
}

@end
