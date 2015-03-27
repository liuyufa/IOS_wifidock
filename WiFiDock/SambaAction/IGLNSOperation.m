//
//  IGLNSOperation.m
//  IGL004
//
//  Created by apple on 2014/05/23.
//  Copyright (c) 2014年 hualu. All rights reserved.
//

#import "IGLNSOperation.h"
#import <UIKit/UIKit.h>
@implementation IGLNSOperation{
    BOOL ispause;
}
-(BOOL)isCancelled{
    return _iscancel;
}
-(id)init{
    if(self=[super init]){
        _complete = NO;
        _iscancel = NO;
        ispause = NO;
    }
    return self;
}
-(NSString*)operationName{return @"";}
-(NSString*)totalStr{return @"";}
-(NSString*)overedStr{return @"";}
-(float)progress{return 0;}
-(void)cancel{
    _iscancel = YES;
    [super cancel];
}
-(BOOL)isFinished{
    return _complete;
}

+ (BOOL)isMultitaskingSupported
{
	BOOL multiTaskingSupported = NO;
	if ([[UIDevice currentDevice] respondsToSelector:@selector(isMultitaskingSupported)]) {
		multiTaskingSupported = [(id)[UIDevice currentDevice] isMultitaskingSupported];
	}
	return multiTaskingSupported;
}
@end
