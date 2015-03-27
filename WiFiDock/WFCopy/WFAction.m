
//
//  WFAction.m
//  WiFiDock
//
//  Created by apple on 15-1-7.
//  Copyright (c) 2015年 cn.hualu.WiFiDock. All rights reserved.
//

#import "WFAction.h"

@implementation WFAction

+(instancetype)actionWithPath:(NSString*)from to:(NSString*)dest
{
    
    return [[WFAction alloc]initWithPath:from to:dest];
}

-(instancetype)initWithPath:(NSString*)from to:(NSString*)dest
{
    self = [super init];
    
    if (self) {
        self.from = from;
        self.dest = dest;
        self.fileSize = 0.0f;
        self.overedSize = 0.0f;
        self.isFolder = NO;
        self.isCut = NO;
        
    }
    
    return self;
}

@end
