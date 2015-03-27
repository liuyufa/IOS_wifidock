//
//  IGLCopyAction.h
//  IGL004
//
//  Created by apple on 2014/05/24.
//  Copyright (c) 2014年 hualu. All rights reserved.
//

#import "IGLNSOperation.h"
#import "WFActionTool.h"
#import "WFFileUtil.h"
#import "WFAction.h"
#import "IGLMessageManager.h"
#define COPYSPEED COPY_BUFFER_SIZE_SUB*COPY_BUFFER_SIZE_SUB

static NSString *IGLCopyRunLoopMode = @"IGLCopyRunLoopMode";


@interface IGLCopyAction : IGLNSOperation

@property(nonatomic,copy)   NSString *targetpath;
@property(nonatomic,strong) WFAction *item;

@property(nonatomic,copy) NSString *fileName;
@property(nonatomic,copy) NSString *totalSize;
@property(nonatomic,copy) NSString *contentSize;
@property(nonatomic,assign)float progress;

- (void)startAsynchronous;
-(void)runWhenFinished;
+(instancetype)actionWithItem:(WFAction*)item;
-(instancetype)initWithItem:(WFAction*)item;
-(NSString*)buildPath;
-(void)doCopyAction;
@end
