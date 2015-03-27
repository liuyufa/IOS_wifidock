//
//  WFActionManager.m
//  WiFiDock
//
//  Created by apple on 15-1-7.
//  Copyright (c) 2015年 cn.hualu.WiFiDock. All rights reserved.
//

#import "WFActionManager.h"
#import "WFAction.h"
#import "MBProgressHUD+WF.h"
#import "IGLMessageManager.h"
#import "WFFileUtil.h"
#import "WFLtoLAction.h"
#import "WFLtoSAction.h"
#import "WFStoLAction.h"
#import "WFStoSAction.h"
#import "IGLCopyAction.h"
#import "WFTransferItem.h"

static WFActionManager *sharedManage = nil;

@implementation WFActionManager

-(id)init{
    
    self = [super init];
    
    if(self){
        
        self.sharedQueue = [[NSOperationQueue alloc] init];
        
        [self.sharedQueue setMaxConcurrentOperationCount:1];
       
        self.optionArray = [NSMutableArray array];
        
    }
    return self;
}


+(instancetype)sharedManage
{
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        
        sharedManage = [[WFActionManager alloc] init];
        
    });
    return sharedManage;
}

-(void)addOperation:(NSOperation*)operation
{
    
    [self.optionArray  addObject:operation];
    [self.sharedQueue addOperation:operation];
    
}

-(void)removeOperation:(NSOperation*)operation
{
    [self.optionArray  removeObject:operation];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kCntChangedNotification object:nil];
    
    if([operation isCancelled]) return;
    
    if([[operation class] isSubclassOfClass:[IGLCopyAction class]] && [self.optionArray count]==0){
//        [MBProgressHUD hideHUD];
//        [[IGLMessageManager sharedManage] showmessage:NSLocalizedString(@"Paste Successfully",nil)];
//        [MBProgressHUD showSuccess:NSLocalizedString(@"Paste Successfully",nil)];
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//            [[IGLMessageManager sharedManage] showmessage:NSLocalizedString(@"Paste Successfully",nil)];
            [MBProgressHUD showSuccess:NSLocalizedString(@"Paste Successfully",nil)];
        });
  
    }
    
    if([NSStringFromClass([operation class])  isEqual: @"IGLCopyPhotosAction"] && [_optionArray count]==0){
        [[NSNotificationCenter defaultCenter] postNotificationName:@"kCopyOverNotification" object:nil];
        
    }
    
//    if([NSStringFromClass([operation class])  isEqual: @"WFCopyContactsAction"] && [_optionArray count]==0){
//        [MBProgressHUD showMessage:@"通讯录备份成功"];
//    }
    
    if([_optionArray count]==0){
//        [[NSNotificationCenter defaultCenter] postNotificationName:@"kCopyOverNotification" object:nil];
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [[NSNotificationCenter defaultCenter] postNotificationName:@"kCopyOverNotification" object:nil];
        });
        
    }
}

+(IGLCopyAction*)getCopyActionWithItem:(WFAction*)item
{
    /*
    if ([item.from hasPrefix:@"assets-library:"]&&[item.dest hasPrefix:[WFFileUtil getDocumentPath]]) {
        return [WFLToLAction actionWithItem:item];
    }
    
    if([item.from hasPrefix:@"assets-library:"]&&[item.dest hasPrefix:SAMBA_URL]){
        return [WFLToSAction actionWithItem:item];
    }
     */
    if([item.from hasPrefix:[WFFileUtil getDocumentPath]]&&[item.dest hasPrefix:[WFFileUtil getDocumentPath]]){
        return [WFLToLAction actionWithItem:item];
    }
    if([item.from hasPrefix:[WFFileUtil getDocumentPath]]&&[item.dest hasPrefix:SAMBA_URL]){
        return [WFLToSAction actionWithItem:item];
    }

    if([item.from hasPrefix:NSTemporaryDirectory()]&&[item.dest hasPrefix:[WFFileUtil getDocumentPath]]){
        return [WFLToLAction actionWithItem:item];
    }
    if([item.from hasPrefix:NSTemporaryDirectory()]&&[item.dest hasPrefix:SAMBA_URL]){
        return [WFLToSAction actionWithItem:item];
    }
    //
    if([item.from hasPrefix:SAMBA_URL]&&[item.dest hasPrefix:[WFFileUtil getDocumentPath]]){
        return [WFSToLAction actionWithItem:item];
    }
    if([item.from hasPrefix:SAMBA_URL]&&[item.dest hasPrefix:SAMBA_URL]){
        return [WFSToSAction actionWithItem:item];
    }
    return [IGLCopyAction actionWithItem:item];

}

@end
