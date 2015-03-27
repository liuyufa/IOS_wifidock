//
//  IGLCopyContactsAction.h
//  IGL004
//
//  Created by apple on 2014/05/25.
//  Copyright (c) 2014年 hualu. All rights reserved.
//

#import "IGLNSOperation.h"


@interface IGLCopyContactsAction : IGLNSOperation
{
    long long  fileSize;
    long long  overedSize;
    NSString * _targetpath;
    NSString * _copyPath;
}
-(id)initWithCopyPath:(NSString*)copyPath;
- (void)startAsynchronous;
@end
