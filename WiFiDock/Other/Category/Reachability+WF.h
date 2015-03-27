//
//  Reachability+WF.h
//  WiFiDock
//
//  Created by apple on 14-12-22.
//  Copyright (c) 2014年 cn.hualu.WiFiDock. All rights reserved.
//

#import "Reachability.h"

@interface Reachability (WF)


+ (void)startCheckWithReachability:(Reachability *)reachability;
+ (BOOL)isReachableSamba;

+ (BOOL) sambaStatus;

@end
