//
//  IGLCopyAction.h
//  IGL004
//
//  Created by apple on 2014/05/24.
//  Copyright (c) 2014年 hualu. All rights reserved.
//

#import "IGLNSOperation.h"
#import "IGLActionItem.h"
#import "IGLActionUtils.h"

#define COPYSPEED COPY_BUFFER_SIZE_SUB*COPY_BUFFER_SIZE_SUB

static NSString *IGLCopyRunLoopMode = @"IGLCopyRunLoopMode";

@interface IGLCopyAction : IGLNSOperation
{
    NSString *_targetpath;
}
@property(nonatomic,strong) IGLActionItem *item;
- (void)startAsynchronous;
-(void)runWhenFinished;
+(id)actionWithItem:(IGLActionItem*)item;
-(NSString*)buildPath;
-(void)doCopyAction;
@end
