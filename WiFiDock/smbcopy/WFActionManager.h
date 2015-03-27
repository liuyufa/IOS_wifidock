//
//  WFActionManager.h
//  WiFiDock
//
//  Created by apple on 15-1-7.
//  Copyright (c) 2015年 cn.hualu.WiFiDock. All rights reserved.
//

#import <Foundation/Foundation.h>



@class IGLCopyAction,WFAction;

@interface WFActionManager : NSObject
@property(nonatomic,strong)NSOperationQueue *sharedQueue;
@property(nonatomic,strong)NSMutableArray *optionArray;

+(instancetype)sharedManage;
-(void)addOperation:(NSOperation*)operation;
-(void)removeOperation:(NSOperation*)operation;
+(IGLCopyAction*)getCopyActionWithItem:(WFAction*)item;

@end
