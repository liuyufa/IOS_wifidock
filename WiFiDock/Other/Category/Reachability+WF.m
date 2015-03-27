//
//  Reachability+WF.m
//  WiFiDock
//
//  Created by apple on 14-12-22.
//  Copyright (c) 2014年 cn.hualu.WiFiDock. All rights reserved.
//

#import "Reachability+WF.h"
#import "Reachability.h"
#import "WFNetCheckController.h"
#import <SystemConfiguration/CaptiveNetwork.h>

@implementation Reachability (WF)

+ (void)startCheckWithReachability:(Reachability *)reachability
{
    WFNetCheckController *check = [WFNetCheckController sharedNetCheck];
    
    if (check.reachability) {
        
        [check.reachability stopNotifier];
        
        check.reachability = nil;
    }
    
    check.reachability = reachability;
    
    [check.reachability startNotifier];
}

+ (BOOL)isReachableSamba
{
    WFNetCheckController *check = [WFNetCheckController sharedNetCheck];
    
    if (!check.reachability) return NO;
    
    NetworkStatus networkStatus = [check networkStatus];
        
    if(networkStatus != ReachableViaWiFi) return NO;
    
    if(![check.reachability currentSambaServerStatus]) return NO;
    
    return YES;
}

+ (BOOL) sambaStatus
{
    return [[WFNetCheckController sharedNetCheck] canConnectSamba];
}

@end
