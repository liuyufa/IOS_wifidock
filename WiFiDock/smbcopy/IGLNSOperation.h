//
//  IGLNSOperation.h
//  IGL004
//
//  Created by apple on 2014/05/23.
//  Copyright (c) 2014年 hualu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface IGLNSOperation : NSOperation

@property(nonatomic,assign)BOOL iscancel;
@property(nonatomic,assign)BOOL complete;
-(NSString*)operationName;
-(NSString*)totalStr;
-(NSString*)overedStr;
-(float)progress;
-(BOOL)isCancelled;

//-(void)restart;
+ (BOOL)isMultitaskingSupported;
@end
