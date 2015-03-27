//
//  IGLMessageManager.h
//  IGL004
//
//  Created by apple on 2014/05/16.
//  Copyright (c) 2014年 hualu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface IGLMessageManager : NSObject
+(IGLMessageManager *)sharedManage;
-(void)addOperation:(NSOperation*)operation;
-(void)showmessage:(NSString*)message;
@end

@interface DoShouMessage : NSOperation
-(id)initWithMeaage:(NSString*)message;
- (void)startAsynchronous;
@end