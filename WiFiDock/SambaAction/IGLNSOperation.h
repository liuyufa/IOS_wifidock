//
//  IGLNSOperation.h
//  IGL004
//
//  Created by apple on 2014/05/23.
//  Copyright (c) 2014年 hualu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface IGLNSOperation : NSOperation{
    BOOL _complete;
    BOOL _iscancel;
}
-(NSString*)operationName;
-(NSString*)totalStr;
-(NSString*)overedStr;
-(float)progress;
-(BOOL)isCancelled;
-(void)pause;
-(void)restart;
+ (BOOL)isMultitaskingSupported;
@end
