//
//  WFTransferItem.m
//  WiFiDock
//
//  Created by apple on 15-1-8.
//  Copyright (c) 2015年 cn.hualu.WiFiDock. All rights reserved.
//

#import "WFTransferItem.h"
#import "IGLNSOperation.h"


@interface WFTransferItem ()



@end

@implementation WFTransferItem
-(instancetype)initWithOperation:(IGLNSOperation *)obj
{
    self = [super init];
    if (self) {
        
        self.operation = obj;
        self.fileName = [obj operationName];
        
    }
    
    return self;
}


-(void) changeValve
{
    [self setProgress:0.0f];
    [self setPercent:nil];
}


+(instancetype)transferItemWithOperation:(IGLNSOperation *)obj
{
    return [[WFTransferItem alloc]initWithOperation:obj];
}


- (void)setProgress:(float)progress
{
    _progress = [[self.operation overedStr] floatValue];
}

-(void)setPercent:(NSString *)percent
{
    float total = [[self.operation totalStr] floatValue];
    float over = [[self.operation overedStr] floatValue];
    int result = over *100/total;
    _percent = [NSString stringWithFormat:@"%d",result];
}

@end
