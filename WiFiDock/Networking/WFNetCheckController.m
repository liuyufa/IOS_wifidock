//
//  WFNetCheckController.m
//  WiFiDock
//
//  Created by apple on 14-12-22.
//  Copyright (c) 2014年 cn.hualu.WiFiDock. All rights reserved.
//

#import "WFNetCheckController.h"
#import  "IGLSMBProvier.h"
#import "WFDiskInfo.h"
#import "WFConfigInfo.h"

#define KSmbRootDirConfig  @"smb://Hualu:123456@10.10.1.1/hualu/.config"
#define KSmbRootDirSd      @"smb://Hualu:123456@10.10.1.1/hualu/sd"
#define KSmbRootDirDock    @"smb://Hualu:123456@10.10.1.1/hualu/awsd"

@interface WFNetCheckController ()

@property(nonatomic, strong)NSMutableArray *dessArray;
@end

@implementation WFNetCheckController

- (NSMutableArray *)dessArray
{
    if (!_dessArray) {
        _dessArray = [NSMutableArray array];
    }
    return _dessArray;
}
+ (WFNetCheckController *)sharedNetCheck
{
    static WFNetCheckController *staticCheck = nil;
    if (!staticCheck) {
        staticCheck = [[WFNetCheckController alloc] init];
        [[NSNotificationCenter defaultCenter] addObserver:staticCheck selector:@selector(reachabilityChanged:) name:kReachabilityChangedNotification object:nil];
        staticCheck.networkStatus = NotReachable;
        staticCheck.requiredConnect = NO;
    }
    return staticCheck;
}

-(void)setCanConnectSamba:(BOOL)canConnectSamba
{
    _canConnectSamba = canConnectSamba;
    
    _canConnectSamba = [Reachability isReachableSamba];

}

- (void)reachabilityChanged:(NSNotification* )notification
{
    Reachability* curReachability = [notification object];
    NSParameterAssert([curReachability isKindOfClass:[Reachability class]]);
    self.networkStatus = [curReachability currentReachabilityStatus];
    self.requiredConnect = [curReachability connectionRequired];
    self.canConnectSamba = [Reachability isReachableSamba];
    if(self.canConnectSamba){
        
        self.dockPath = nil;
        self.tfPath = nil;
        self.usbPath = nil;
        
        id  reslut =  [[IGLSMBProvier sharedSmbProvider] fetchFoldorAtPath:KSmbURL];
        
        if (!reslut) return;
        
        if ([reslut isKindOfClass:[NSArray class]]) {
            
            for (IGLSMBItemTree *item in reslut) {
                
                [self getConfigData:item];
            }
        }
        
        [self setupPath];
        
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kSambaChangedNotification object:nil];
}

- (void)setReachability:(Reachability *)reachability
{
    _reachability = reachability;
    self.networkStatus = [reachability currentReachabilityStatus];
    self.requiredConnect = [reachability connectionRequired];
    self.canConnectSamba = [Reachability isReachableSamba];
    
    if(self.canConnectSamba){
    
        self.dockPath = nil;
        self.tfPath = nil;
        self.usbPath = nil;
        
        id  reslut =  [[IGLSMBProvier sharedSmbProvider] fetchFoldorAtPath:KSmbURL];
        
        if (!reslut) return;
        if ([reslut isKindOfClass:[NSArray class]]) {
            
            for (IGLSMBItemTree *item in reslut) {
                
                [self getConfigData:item];
            }
        }
        
        [self setupPath];
    }

}

- (void)setupPath
{
    for (WFDiskInfo *diskInfo in self.dessArray) {
        
        if ([diskInfo.dess isEqualToString:@"WiFiDock"]) {
           
            self.dockPath = diskInfo.path;
            continue;
        
        }else if ([diskInfo.dess isEqualToString:@"SD"]) {
            
            self.tfPath = diskInfo.path;
            continue;
        
        }else if ([diskInfo.dess isEqualToString:@"USB"]) {
            
            self.usbPath = diskInfo.path;
            continue;
        
        }
    }
}

- (void)getConfigData:(IGLSMBItemTree *)item
{
    WFDiskInfo *diskInfo = [[WFDiskInfo alloc]init];
    WFConfigInfo *config = [[WFConfigInfo alloc]init];
    diskInfo.path = item.path;
    
    if ([diskInfo.path isEqualToString:KSmbRootDirConfig]) {
        diskInfo.dess = @".config";
        
    }else if ([diskInfo.path hasPrefix:KSmbRootDirSd]) {
        [config deleteConfigFileFromLocal:@".config"];
        NSString *urlString = diskInfo.path;
        NSString *remoteUrl = [NSString stringWithFormat:@"%@/.config",urlString];
        [config getConfigInfoFromSmb:remoteUrl];
        diskInfo.dess = [config getConfigInfo:[config readConfigFilefromLocal:@".config"]];
    }else if ([diskInfo.path isEqualToString:KSmbRootDirDock]) {
        
        diskInfo.dess = @"WiFiDock";
        
    }
    
    [self.dessArray addObject:diskInfo];
}

- (void)getStorageStaus
{
    self.dockPath = nil;
    self.tfPath = nil;
    self.usbPath = nil;
    id  reslut =  [[IGLSMBProvier sharedSmbProvider] fetchFoldorAtPath:KSmbURL];
    if (!reslut) return;
        
    if ([reslut isKindOfClass:[NSArray class]]) {
    
        for (IGLSMBItemTree *item in reslut) {
            
            [self getConfigData:item];
        }
    }
    
    [self setupPath];
 
}



@end
