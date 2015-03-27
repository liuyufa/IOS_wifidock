

//
//  WFTransferDate.m
//  WiFiDock
//
//  Created by apple on 15-1-9.
//  Copyright (c) 2015年 cn.hualu.WiFiDock. All rights reserved.
//

#import "WFTransferDate.h"
#import "IGLNSOperation.h"
#import "WFActionManager.h"
#import "WFTransferItem.h"

@implementation WFTransferDate

-(instancetype)init
{
    if (self = [super init]) {
        
        self.data = [NSMutableArray array];
    }
    return self;
}


- (void)loadDate
{
    
    NSArray *items = [NSArray array];
    
    items = [WFActionManager sharedManage].optionArray;
    
    NSMutableArray *itemArray = [NSMutableArray array];
    
    for (IGLNSOperation *operation in items) {
        
        if([operation isFinished] || [operation isCancelled]){
            continue;
        }
        
        WFTransferItem *item =[[WFTransferItem alloc]initWithOperation:operation];
        [itemArray addObject:item];
    }
    
    self.data = itemArray;
}
@end
