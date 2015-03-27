//
//  WFDockStaus.m
//  WiFiDock
//
//  Created by apple on 14-12-22.
//  Copyright (c) 2014年 cn.hualu.WiFiDock. All rights reserved.
//

#import "WFDockStaus.h"
#import "MBProgressHUD+WF.h"
#import "Reachability+WF.h"

@implementation WFDockStaus
+ (void)checkDockStatus
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        if(![Reachability isReachableSamba]){
            [self performSelectorOnMainThread:@selector(setEndNG) withObject:nil waitUntilDone:NO];
        }else{
            [self performSelectorOnMainThread:@selector(setEndOK) withObject:nil waitUntilDone:NO];
        }
    });
}
@end
