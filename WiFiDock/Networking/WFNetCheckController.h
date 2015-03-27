//
//  WFNetCheckController.h
//  WiFiDock
//
//  Created by apple on 14-12-22.
//  Copyright (c) 2014年 cn.hualu.WiFiDock. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Reachability+WF.h"

@interface WFNetCheckController : NSObject
@property (nonatomic, strong) Reachability  *reachability;
@property (nonatomic, assign) NetworkStatus networkStatus;
@property (nonatomic, assign) BOOL  requiredConnect;
@property (nonatomic, assign) BOOL canConnectSamba;
@property (nonatomic, copy) NSString*  SSID;
@property(nonatomic, copy)NSString *dockPath;
@property(nonatomic, copy)NSString *tfPath;
@property(nonatomic, copy)NSString *usbPath;
+ (WFNetCheckController *)sharedNetCheck;
- (void)getStorageStaus;

@end
