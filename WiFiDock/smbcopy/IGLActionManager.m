//
//  IGLActionManager.m
//  IGL004
//
//  Created by apple on 2014/02/24.
//  Copyright (c) 2014年 hualu. All rights reserved.
//

#import "IGLActionManager.h"
#import<AssetsLibrary/AssetsLibrary.h>
#import <AddressBook/AddressBook.h>
#import "IGLMessageManager.h"
#include <sys/param.h>
#include <sys/mount.h>
#import "IGLLtoLAction.h"
#import "IGLLtoSAction.h"
#import "IGLStoLAction.h"
#import "IGLStoSAction.h"
#import  "WFFileUtil.h"

@implementation IGLActionManager
@synthesize sharedQueue = _sharedQueue;
@synthesize optionArray = _optionArray;
static IGLActionManager *sharedManage = nil;
-(id)init{
    self = [super init];
    if(self){
        _sharedQueue = [[NSOperationQueue alloc] init];
        //[_sharedQueue setMaxConcurrentOperationCount:1];
        _optionArray = [NSMutableArray array];
        //[_sharedQueue addObserver:self forKeyPath:@"operation" options:0 context:nil];
    }
    return self;
}
+ (IGLActionManager *)sharedManage
{
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        sharedManage = [[IGLActionManager alloc] init];
    });
    return sharedManage;
}

+(void)setManage:(IGLActionManager*)m{
    sharedManage = m;
}

-(void)addOperation:(NSOperation*)operation{
    [_optionArray  addObject:operation];
    [_sharedQueue addOperation:operation];
}
-(void)removeOperation:(NSOperation*)operation{

    [_optionArray  removeObject:operation];
    //
    [[NSNotificationCenter defaultCenter] postNotificationName:kCntChangedNotification object:nil];
    if([operation isCancelled]){
        return;
    }
    if([[operation class] isSubclassOfClass:[IGLCopyAction class]] && [_optionArray count]==0){
        [[IGLMessageManager sharedManage] showmessage:NSLocalizedString(@"Paste Success",nil)];
    }
    if([NSStringFromClass([operation class])  isEqual: @"IGLCopyPhotosAction"] && [_optionArray count]==0){
        [[IGLMessageManager sharedManage] showmessage:NSLocalizedString(@"Photos Backup Success",nil)];
    }
    if([NSStringFromClass([operation class])  isEqual: @"IGLCopyContactsAction"] && [_optionArray count]==0){
        [[IGLMessageManager sharedManage] showmessage:NSLocalizedString(@"Contacts Backup Success",nil)];
    }
    if([_optionArray count]==0){
         [[NSNotificationCenter defaultCenter] postNotificationName:@"kCopyOverNotification" object:nil];
    }
}
+(IGLCopyAction*)getCopyActionWithItem:(IGLActionItem*)item{
    if([item.fromPath hasPrefix:[WFFileUtil getDocumentPath]]&&[item.toPath hasPrefix:[WFFileUtil getDocumentPath]]){
        return [IGLLtoLAction actionWithItem:item];
    }
    if([item.fromPath hasPrefix:[WFFileUtil getDocumentPath]]&&[item.toPath hasPrefix:SAMBA_URL]){
        return [IGLLtoSAction actionWithItem:item];
    }
    //tmp
    if([item.fromPath hasPrefix:NSTemporaryDirectory()]&&[item.toPath hasPrefix:[WFFileUtil getDocumentPath]]){
        return [IGLLtoLAction actionWithItem:item];
    }
    if([item.fromPath hasPrefix:NSTemporaryDirectory()]&&[item.toPath hasPrefix:SAMBA_URL]){
        return [IGLLtoSAction actionWithItem:item];
    }
    //
    if([item.fromPath hasPrefix:SAMBA_URL]&&[item.toPath hasPrefix:[WFFileUtil getDocumentPath]]){
        return [IGLStoLAction actionWithItem:item];
    }
    if([item.fromPath hasPrefix:SAMBA_URL]&&[item.toPath hasPrefix:SAMBA_URL]){
       return [IGLStoSAction actionWithItem:item];
    }
    return [IGLCopyAction actionWithItem:item];
}
@end

