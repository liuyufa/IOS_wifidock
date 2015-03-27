//
//  IGLCopyAction.m
//  IGL004
//
//  Created by apple on 2014/05/24.
//  Copyright (c) 2014年 hualu. All rights reserved.
//

#import "IGLCopyAction.h"
#import "IGLActionManager.h"
#import <UIKit/UIKit.h>

@implementation IGLCopyAction{
    UIBackgroundTaskIdentifier backgroundTask;
}
-(void)dealloc{
    //NSLog(@"dealloc self");
}

- (void)main {
    
#if TARGET_OS_IPHONE && __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_4_0
    if ([IGLNSOperation isMultitaskingSupported]) {
        if (!backgroundTask || backgroundTask == UIBackgroundTaskInvalid) {
            backgroundTask = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
                // Synchronize the cleanup call on the main thread in case
                // the task actually finishes at around the same time.
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (backgroundTask != UIBackgroundTaskInvalid)
                    {
                        [[UIApplication sharedApplication] endBackgroundTask:backgroundTask];
                        backgroundTask = UIBackgroundTaskInvalid;
                        [self cancel];
                    }
                });
            }];
        }
    }
#endif

    
    [self doCopyAction];
    
    while(!_complete){
        [[NSRunLoop currentRunLoop] runMode:IGLCopyRunLoopMode beforeDate:[NSDate distantFuture]];
    }
}

-(void)doCopyAction{
    _complete = YES;
}

-(void)cancel{
    _iscancel = YES;
    [self runWhenFinished];
}
- (void)startAsynchronous
{
	[[IGLActionManager sharedManage] addOperation:self];
}

-(NSString*)operationName{return [self.item.fromPath lastPathComponent];}
-(NSString*)totalStr{return [NSString stringWithFormat:@"%dKB",(int)(self.item.fileSize/1000)];}
-(NSString*)overedStr{return [NSString stringWithFormat:@"%dKB",(int)(self.item.overedSize/1000)];}
-(float)progress{return self.item.overedSize*1.00/self.item.fileSize*1.00;}

-(void)runWhenFinished{
    if(_iscancel){
        if(_targetpath){
            [IGLActionUtils removeFileAtPath:_targetpath];
        }
        _complete = YES;
        [[IGLActionManager sharedManage] performSelectorOnMainThread:@selector(removeOperation:) withObject:self waitUntilDone:NO];
        
    }else{
        if(self.item.isCut){
            [IGLActionUtils removeFileAtPath:self.item.fromPath];
        }
        _complete = YES;
        [[IGLActionManager sharedManage] performSelectorOnMainThread:@selector(removeOperation:) withObject:self waitUntilDone:NO];
    }
#if TARGET_OS_IPHONE && __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_4_0
	if ([IGLCopyAction isMultitaskingSupported]) {
		dispatch_async(dispatch_get_main_queue(), ^{
			if (backgroundTask != UIBackgroundTaskInvalid) {
				[[UIApplication sharedApplication] endBackgroundTask:backgroundTask];
				backgroundTask = UIBackgroundTaskInvalid;
			}
		});
	}
#endif
}
-(NSString*)buildPath{
    NSString *path = [self.item.toPath stringByAppendingSMBPathComponent:[self.item.fromPath lastPathComponent]];
    if([IGLActionUtils isExistsAtPath:path]){
        switch (self.item.operation) {
            case TheSameFileOperationSkip:
                return nil;
                break;
            case TheSameFileOperationRecover:
                if([path isEqualToString:self.item.fromPath]){
                    return nil;
                }
                break;
            case TheSameFileOperationAppendName:{
                path = [self changeNameWhenHaveSame:path];
                break;
            }
            default:
                return nil;
                break;
        }
    }
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
        if(![IGLActionUtils isExistsAtPath:temp]){
            fileName = temp;
            break;
        }
    }
    return fileName;
}
@end
