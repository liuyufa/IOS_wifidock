//
//  IGLActionItem.m
//  IGL004
//
//  Created by apple on 2014/05/23.
//  Copyright (c) 2014年 hualu. All rights reserved.
//

#import "IGLActionItem.h"

@implementation IGLActionItem

-(id)init{
    if(self=[super init]){
        self.operation = TheSameFileOperationRecover;
        self.fileSize = 0.0;
        self.overedSize = 0.0;
        self.isFolder = NO;
        self.isCut = NO;
    }
    return self;
}
+(id)itemWithPath:(NSString*)f t:(NSString*)t{
    IGLActionItem *item = [[IGLActionItem alloc] init];
    item.fromPath = f;
    item.toPath = t;
    return item;
}
@end
