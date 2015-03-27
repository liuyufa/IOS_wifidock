//
//  IGLMessageManager.m
//  IGL004
//
//  Created by apple on 2014/05/16.
//  Copyright (c) 2014年 hualu. All rights reserved.
//

#import "IGLMessageManager.h"
#import "IGLNotifyHUD.h"

#define IGLMESSAGERUNMODE  @"IGLMESSAGERUNMODE"
@implementation IGLMessageManager{
    NSOperationQueue *_sharedQueue;
    dispatch_queue_t    _dispatchQueue;
}
+ (IGLMessageManager *)sharedManage
{
    static IGLMessageManager *state = nil;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        state = [[IGLMessageManager alloc] init];
    });
    return state;
}
-(void)dealloc{
    if (_dispatchQueue) {
        _dispatchQueue = NULL;
    }
}
-(instancetype)init{
    self = [super init];
    if(self){
        _sharedQueue = [[NSOperationQueue alloc] init];
        [_sharedQueue setMaxConcurrentOperationCount:1];
        _dispatchQueue  = dispatch_queue_create("com.wifidock", DISPATCH_QUEUE_SERIAL);
    }
    return self;
}
-(void)addOperation:(NSOperation*)operation{
    [_sharedQueue addOperation:operation];
}

-(void)showmessage:(NSString*)message{
    //dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        DoShouMessage *show = [[DoShouMessage alloc] initWithMeaage:message];
        [show startAsynchronous];
    //});
}
@end

@implementation DoShouMessage{
    NSString* _message;
    BOOL isfinish;
}

-(void)dealloc{
    NSLog(@"dealloc self");
}

- (void)startAsynchronous{
    [[IGLMessageManager sharedManage] addOperation:self];
}
-(id)initWithMeaage:(NSString*)message{
    self = [super init];
    if(self){
        _message = message;
        isfinish = NO;
    }
    return self;
}
-(void)main{
    __block BOOL isover = NO;
    dispatch_async(dispatch_get_main_queue(), ^{
        IGLNotifyHUD *notify = [IGLNotifyHUD notifyHUDWithImage:nil text:_message];
        //_notify.center = [UIApplication sharedApplication].keyWindow.center;
        //test
        CGPoint center = [UIApplication sharedApplication].keyWindow.center;
        
        notify.center = center;
  
        [[UIApplication sharedApplication].keyWindow addSubview:notify];
        [[UIApplication sharedApplication].keyWindow bringSubviewToFront:notify];
        [notify presentWithDuration:0.5f speed:0.5f inView:[UIApplication sharedApplication].keyWindow completion:^{
            dispatch_async(dispatch_get_main_queue(), ^{
                [notify removeFromSuperview];
            });
            isover = YES;
        }];
    });
   
    while(!isover){
        //[[NSRunLoop currentRunLoop] runMode:IGLMESSAGERUNMODE beforeDate:[NSDate distantFuture]];
        sleep(1);
    }
    isfinish = YES;
}
-(BOOL)isFinished{
    return isfinish;
}
@end