//
//  IGLCopyAction.m
//  IGL004
//
//  Created by apple on 2014/05/24.
//  Copyright (c) 2014年 hualu. All rights reserved.
//

#import "IGLCopyAction.h"
#import "WFActionManager.h"
#import <UIKit/UIKit.h>
#import "WFActionManager.h"

@interface IGLCopyAction ()

@property(nonatomic,assign) UIBackgroundTaskIdentifier backgroundTask;

@end

@implementation IGLCopyAction

+(instancetype)actionWithItem:(WFAction*)item
{
    return [[IGLCopyAction alloc]initWithItem:item];
}

-(instancetype)initWithItem:(WFAction*)item
{
//    self = [super init];
//    if (self) {
//        
//        self.fileName =[self operationName];
//        self.totalSize = [self totalStr];
//        self.contentSize = [self overedStr];
//        self.progress = [self progress];
//    }
    
    return nil;
}

-(void)dealloc
{
    NSLog(@"IGLCopyAction");
}

- (void)main {
    
#if TARGET_OS_IPHONE && __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_4_0
    if ([IGLNSOperation isMultitaskingSupported]) {
        if (!self.backgroundTask || self.backgroundTask == UIBackgroundTaskInvalid) {
            self.backgroundTask = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (self.backgroundTask != UIBackgroundTaskInvalid)
                    {
                        [[UIApplication sharedApplication] endBackgroundTask:self.backgroundTask];
                        self.backgroundTask = UIBackgroundTaskInvalid;
                        [self cancel];
                    }
                });
            }];
        }
    }
#endif

    if(self.isCancelled) return;
    
    [self doCopyAction];
    
    while(!self.complete){
        [[NSRunLoop currentRunLoop] runMode:IGLCopyRunLoopMode beforeDate:[NSDate distantFuture]];
    }
    
    
    
    
}

-(void)doCopyAction{
    self.complete = YES;
}

-(void)cancel{
    self.iscancel = YES;
    [self runWhenFinished];
}
- (void)startAsynchronous
{
	[[WFActionManager sharedManage] addOperation:self];
}

-(NSString*)operationName
{
    return [self.item.from lastPathComponent];
}
-(NSString*)totalStr
{
    return [NSString stringWithFormat:@"%dKB",(int)(self.item.fileSize/1000)];
}
-(NSString*)overedStr
{
    return [NSString stringWithFormat:@"%dKB",(int)(self.item.overedSize/1000)];
}

-(float)progress{
    
    return self.item.overedSize*1.00/self.item.fileSize*1.00;
}

-(void)runWhenFinished{
    
    if(self.iscancel){
        if(self.targetpath){
            [WFActionTool removeFileAtPath:self.targetpath];
        }
        self.complete = YES;
        [[WFActionManager sharedManage] performSelectorOnMainThread:@selector(removeOperation:) withObject:self waitUntilDone:NO];
        
    }else{
        if(self.item.isCut){
            [WFActionTool removeFileAtPath:self.item.from];
        }
        self.complete = YES;
        [[WFActionManager sharedManage] performSelectorOnMainThread:@selector(removeOperation:) withObject:self waitUntilDone:NO];
    }
#if TARGET_OS_IPHONE && __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_4_0
	if ([IGLCopyAction isMultitaskingSupported]) {
		dispatch_async(dispatch_get_main_queue(), ^{
			if (self.backgroundTask != UIBackgroundTaskInvalid) {
				[[UIApplication sharedApplication] endBackgroundTask:self.backgroundTask];
				self.backgroundTask = UIBackgroundTaskInvalid;
			}
		});
	}
#endif
    
    
  
}
-(NSString*)buildPath{
    
    NSString *path = [self.item.dest stringByAppendingSMBPathComponent:[self.item.from lastPathComponent]];
//    NSString *path = [self.item.dest stringByAppendingSMBPathComponent:[self.item.from lastPathComponent]];
//    if([WFActionTool isExistsAtPath:path]){
//        switch (self.item.operation) {
//            case TheSameFileOperationSkip:
//                return nil;
//                break;
//            case TheSameFileOperationRecover:
//                if([path isEqualToString:self.item.from]){
//                    return nil;
//                }
//                break;
//            case TheSameFileOperationAppendName:{
//                path = [self changeNameWhenHaveSame:path];
//                break;
//            }
//            default:
//                return nil;
//                break;
//        }
//    }
    return path;
}

-(NSString*)changeNameWhenHaveSame:(NSString*)path{
    NSString *fileName = [path lastPathComponent];
    NSString *pathExtension = [path pathExtension];
    fileName = [fileName stringByDeletingPathExtension];
    for (int i = 2; i<999999; i++) {
        NSString *temp = [NSString stringWithFormat:@"%@(%d)",fileName,i];
        temp = [[path stringByDeletingSMBLastPathComponent] stringByAppendingSMBPathComponent:temp];
        if(pathExtension&&![pathExtension isEqualToString:@""]){
            temp = [temp stringByAppendingSMBPathExtension:pathExtension];
        }
        if(![WFActionTool isExistsAtPath:temp]){
            fileName = temp;
            break;
        }
    }
    return fileName;
}
@end
