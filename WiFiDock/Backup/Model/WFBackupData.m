//
//  WFBackupData.m
//  WiFiDock
//
//  Created by apple on 15-1-12.
//  Copyright (c) 2015年 cn.hualu.WiFiDock. All rights reserved.
//

#import "WFBackupData.h"
#import "Reachability+WF.h"
#import "WFNetCheckController.h"
#import "WFPath.h"
#import "WFFileUtil.h"
@implementation WFBackupData

- (NSMutableArray *)paths
{
    if (!_paths) {
        _paths = [NSMutableArray array];
    }
    return _paths;
}
-(void)setBackupDataSoure
{
    NSMutableArray *paths = [NSMutableArray array];
    
    if ([Reachability sambaStatus]) {
        
        
        [self getStorageStaus];
        
        if (self.rootSambaDockPath) {
            
            WFPath *pathType = [[WFPath alloc]initWithPath:self.rootSambaDockPath name:@"云盘坞"];
            
            [paths addObject:pathType];
            
        }
        if (self.rootSambaUSBPath) {
            
            WFPath *pathType = [[WFPath alloc]initWithPath:self.rootSambaUSBPath name:@"USB"];
            
            [paths addObject:pathType];
        }
        
        if (self.rootSambaTFPath) {
            
            WFPath *pathType = [[WFPath alloc]initWithPath:self.rootSambaTFPath name:@"TF卡"];
            
            [paths addObject:pathType];
            
        }
        
        self.paths = paths;
        
    }
}

- (void)getStorageStaus
{
    
    [[WFNetCheckController sharedNetCheck] getStorageStaus];
    
    self.rootLocalPath = [WFFileUtil getDocumentPath];
    self.rootSambaDockPath = [WFNetCheckController sharedNetCheck].dockPath;
    self.rootSambaTFPath = [WFNetCheckController sharedNetCheck].tfPath;
    self.rootSambaUSBPath =[WFNetCheckController sharedNetCheck].usbPath;
    
    
}

@end
