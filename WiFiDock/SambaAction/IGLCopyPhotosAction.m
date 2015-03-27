//
//  IGLCopyPhotosAction.m
//  IGL004
//
//  Created by apple on 2014/05/25.
//  Copyright (c) 2014年 hualu. All rights reserved.
//

#import "IGLCopyPhotosAction.h"
#import "IGLActionManager.h"
#include <sys/param.h>
#include <sys/mount.h>
#import <UIKit/UIKit.h>
@implementation IGLCopyPhotosAction
{
    //ALAssetsLibrary* library;
    BOOL _isRunlopOver;
    dispatch_queue_t    _dispatchQueue;
    UIBackgroundTaskIdentifier backgroundTask;
}
-(void)dealloc{
    NSLog(@"dealloc self");
}
- (void)startAsynchronous
{
	[[IGLActionManager sharedManage] addOperation:self];
}
-(id)initWithCopyPath:(NSString*)copyPath{
    self = [super init];
    if(self){
        _copyPath = copyPath;
    }
    return self;
}
-(BOOL)isFinished{
    return _complete;
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
    _dispatchQueue  = dispatch_queue_create("IGLSMBProvier", DISPATCH_QUEUE_SERIAL);
    backupover = 0;
    numofphoto = 0;
    [self loadImageFromPhotoLibrary_step1];
    while (!_complete) {
        sleep(1);
    }
}
-(void)runWhenFinished{
    if(_iscancel){
        [IGLActionUtils removeFileAtPath:_rootpath];
        _complete = YES;
    }else{
        _complete = YES;
    }
    [[IGLActionManager sharedManage] removeOperation:self];
    
    if (_dispatchQueue) {
#if __IPHONE_OS_VERSION_MIN_REQUIRED < 60000
        dispatch_release(_dispatchQueue);
#endif
        _dispatchQueue = NULL;
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
-(NSString*)operationName{return NSLocalizedString(@"Copy Photos", nil);}
-(NSString*)totalStr{return [NSString stringWithFormat:@"%d",numofphoto];}
-(NSString*)overedStr{return [NSString stringWithFormat:@"%d",backupover];}
-(float)progress{return backupover*1.0/numofphoto*1.0;}

-(void)loadImageFromPhotoLibrary_step1
{
    //dispatch_queue_t dispatchQueue =dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(_dispatchQueue, ^{
        ALAssetsLibraryGroupsEnumerationResultsBlock groupsEnumeration = ^(ALAssetsGroup* group, BOOL* stop){
            if (group!=nil) {
                [group setAssetsFilter:[ALAssetsFilter allPhotos]];
                numofphoto += [group numberOfAssets];
            }else{
                *stop = YES;
                if(numofphoto == 0){
                    [self performSelectorOnMainThread:@selector(runWhenFinished) withObject:nil waitUntilDone:YES];
                }else{
                    _rootpath = [_copyPath stringByAppendingSMBPathComponent:@"PhotoLibrary"];
                    if(![IGLActionUtils isExistsAtPath:_rootpath]){
                        if(![IGLActionUtils createAtPaht:_rootpath]){
                            [self performSelectorOnMainThread:@selector(runWhenFinished) withObject:nil waitUntilDone:YES];
                            return;
                        }
                    }
                    [self performSelectorOnMainThread:@selector(loadImageFromPhotoLibrary_step2) withObject:nil waitUntilDone:YES];
                }
            }
        };
        ALAssetsLibraryAccessFailureBlock failureblock = ^(NSError *error){
            [self performSelectorOnMainThread:@selector(runWhenFinished) withObject:nil waitUntilDone:YES];
        };
        
        ALAssetsLibrary* library = [[ALAssetsLibrary alloc] init];
        [library enumerateGroupsWithTypes:ALAssetsGroupAll
                               usingBlock:groupsEnumeration
                             failureBlock:failureblock];
    });
}

-(void)loadImageFromPhotoLibrary_step2
{
    //dispatch_queue_t dispatchQueue =dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(_dispatchQueue, ^{
        ALAssetsGroupEnumerationResultsBlock groupEnumerAtion = ^(ALAsset *result, NSUInteger index, BOOL *stop){
            if(_iscancel){
                return;
            }
            if (result!=nil) {
                if ([[result valueForProperty:ALAssetPropertyType] isEqualToString:ALAssetTypePhoto]) {
                    if([_copyPath hasPrefix:SAMBA_URL]){
                        [self uploadPhoto:result];
                    }else{
                        [self uploadtolocal:result];
                    }
                }
            }
        };
        //获取相册的组
        ALAssetsLibraryGroupsEnumerationResultsBlock groupsEnumeration = ^(ALAssetsGroup* group, BOOL* stop){
            if (group!=nil) {
                NSString *groupname = [group valueForProperty:ALAssetsGroupPropertyName];
                _subpath = [_rootpath stringByAppendingSMBPathComponent:groupname];
                
                if(![IGLActionUtils isExistsAtPath:_subpath]){
                    if(![IGLActionUtils createAtPaht:_subpath]){
                        [self performSelectorOnMainThread:@selector(runWhenFinished) withObject:nil waitUntilDone:YES];
                        return;
                    }
                }
                [group setAssetsFilter:[ALAssetsFilter allAssets]];
                [group enumerateAssetsUsingBlock:groupEnumerAtion];
            }else{
                *stop = YES;
                [self performSelectorOnMainThread:@selector(runWhenFinished) withObject:nil waitUntilDone:YES];
            }
        };
        
        ALAssetsLibraryAccessFailureBlock failureblock = ^(NSError *error){
            [self performSelectorOnMainThread:@selector(runWhenFinished) withObject:nil waitUntilDone:YES];
        };
        
        ALAssetsLibrary* library = [[ALAssetsLibrary alloc] init];
        [library enumerateGroupsWithTypes:ALAssetsGroupAll
                               usingBlock:groupsEnumeration
                             failureBlock:failureblock];
    });
    
}

- (void)uploadPhoto:(ALAsset*)asset
{
    ALAssetRepresentation *assetRepresentation =[asset defaultRepresentation];
    NSString *filePath = [_subpath stringByAppendingSMBPathComponent:assetRepresentation.filename];
    if([IGLActionUtils isExistsAtPath:filePath]){
        backupover ++;
        return;
    }
    id result = [[IGLSMBProvier sharedSmbProvider]  createFileAtPath:filePath overwrite:YES];
    if(![result isKindOfClass:[IGLSMBItemFile class]]){
        backupover ++;
        return;
    }
    IGLSMBItemFile *file = (IGLSMBItemFile *)result;
    long long imagesize = assetRepresentation.size;
    long long readover = 0;
    while (readover < imagesize) {
        NSUInteger readdata = COPY_BUFFER_SIZE;
        if(imagesize - readover < readdata){
            readdata = imagesize - readover;
        }
        NSError *err;
        uint8_t *buffer[readdata];
        NSUInteger numofread = [assetRepresentation getBytes:&buffer fromOffset:readover length:sizeof(buffer) error:&err];
        if(err){
            break;
        }
        if(numofread>0){
            readover = readover + numofread;
            NSData *data = [NSData dataWithBytes:(void *)(buffer) length:numofread];
            [file writeData:data];
        }
    }
    [file close];
    backupover ++;
}
//-(void)loadImageFromPhotoLibrary_step1
//{
//    dispatch_queue_t dispatchQueue =dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
//    dispatch_async(dispatchQueue, ^{
//    _isRunlopOver = NO;
//    ALAssetsLibraryGroupsEnumerationResultsBlock groupsEnumeration = ^(ALAssetsGroup* group, BOOL* stop){
//        if (group!=nil) {
//            [group setAssetsFilter:[ALAssetsFilter allPhotos]];
//            numofphoto += [group numberOfAssets];
//        }else{
//            *stop = YES;
//            _isRunlopOver = YES;
//        }
//    };
//    ALAssetsLibraryAccessFailureBlock failureblock = ^(NSError *error){
//        _isRunlopOver = YES;
//    };
//    
//    library = [[ALAssetsLibrary alloc] init];
//    [library enumerateGroupsWithTypes:ALAssetsGroupAll
//                           usingBlock:groupsEnumeration
//                         failureBlock:failureblock];
//    
//    while(!_isRunlopOver){
//        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
//    }
//    if(numofphoto>0){
//        _rootpath = [_copyPath stringByAppendingSMBPathComponent:@"PhotoLibrary"];
//        if(![IGLActionUtils isExistsAtPath:_rootpath]){
//            if(![IGLActionUtils createAtPaht:_rootpath]){
//                [self runWhenFinished];
//                return;
//            }
//        }
//        [self loadImageFromPhotoLibrary_step2];
//    }else{
//        [self runWhenFinished];
//    }
//    });
//}
//
//-(void)loadImageFromPhotoLibrary_step2
//{
//    _isRunlopOver = NO;
//    ALAssetsGroupEnumerationResultsBlock groupEnumerAtion = ^(ALAsset *result, NSUInteger index, BOOL *stop){
//        if(_iscancel){
//            return;
//        }
//        if (result!=nil) {
//            if ([[result valueForProperty:ALAssetPropertyType] isEqualToString:ALAssetTypePhoto]) {
//                if([_copyPath hasPrefix:SAMBA_URL]){
//                    [self uploadPhoto:result];
//                }else{
//                    [self uploadtolocal:result];
//                }
//            }
//        }
//    };
//    //获取相册的组
//    ALAssetsLibraryGroupsEnumerationResultsBlock groupsEnumeration = ^(ALAssetsGroup* group, BOOL* stop){
//        if (group!=nil) {
//            NSString *groupname = [group valueForProperty:ALAssetsGroupPropertyName];
//            _subpath = [_rootpath stringByAppendingSMBPathComponent:groupname];
//            
//            if(![IGLActionUtils isExistsAtPath:_subpath]){
//                if(![IGLActionUtils createAtPaht:_subpath]){
//                    return;
//                }
//            }
//            [group setAssetsFilter:[ALAssetsFilter allAssets]];
//            [group enumerateAssetsUsingBlock:groupEnumerAtion];
//        }else{
//            *stop = YES;
//            _isRunlopOver = YES;
//        }
//    };
//    
//    ALAssetsLibraryAccessFailureBlock failureblock = ^(NSError *error){
//        _isRunlopOver = YES;
//    };
//    
//    //ALAssetsLibrary* library = [[ALAssetsLibrary alloc] init];
//    [library enumerateGroupsWithTypes:ALAssetsGroupAll
//                           usingBlock:groupsEnumeration
//                         failureBlock:failureblock];
//    while(!_isRunlopOver){
//        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
//    }
//}
//
- (void)uploadtolocal:(ALAsset*)asset
{
    ALAssetRepresentation *assetRepresentation =[asset defaultRepresentation];
    long long imagesize = assetRepresentation.size;
    
    if([IGLActionUtils freeDiskSpaceInBytes] <= (assetRepresentation.size+1024*1024)){
        return;
    }
    NSString *filePath = [_subpath stringByAppendingSMBPathComponent:assetRepresentation.filename];
    if([IGLActionUtils isExistsAtPath:filePath]){
        backupover ++;
        return;
    }else{
        [[NSFileManager defaultManager] createFileAtPath:filePath contents:nil attributes:nil];
    }
    
    NSFileHandle *fileHandel = [NSFileHandle fileHandleForWritingAtPath:filePath];
    
    
    long long readover = 0;
    while (readover < imagesize) {
        NSUInteger readdata = COPY_BUFFER_SIZE;
        if(imagesize - readover < readdata){
            readdata = imagesize - readover;
        }
        NSError *err;
        uint8_t *buffer[readdata];
        NSUInteger numofread = [assetRepresentation getBytes:&buffer fromOffset:readover length:sizeof(buffer) error:&err];
        if(err){
            break;
        }
        if(numofread>0){
            readover = readover + numofread;
            NSData *data = [NSData dataWithBytes:(void *)(buffer) length:numofread];
            [fileHandel writeData:data];
        }
    }
    [fileHandel closeFile];
    backupover ++;
    
}
//
//- (void)uploadPhoto:(ALAsset*)asset
//{
//    ALAssetRepresentation *assetRepresentation =[asset defaultRepresentation];
//    NSString *filePath = [_subpath stringByAppendingSMBPathComponent:assetRepresentation.filename];
////    if([IGLActionUtils isExistsAtPath:filePath]){
////        backupover ++;
////        return;
////    }
//    id result = [[IGLSMBProvier sharedSmbProvider]  createFileAtPath:filePath overwrite:YES];
//    if(![result isKindOfClass:[IGLSMBItemFile class]]){
//        backupover ++;
//        return;
//    }
//    IGLSMBItemFile *file = (IGLSMBItemFile *)result;
//    long long imagesize = [assetRepresentation size];
//    long long readover = 0;
//    while (readover < imagesize) {
//        NSUInteger readdata = COPY_BUFFER_SIZE;
//        if(imagesize - readover < readdata){
//            readdata = imagesize - readover;
//        }
//        NSError *err;
//        uint8_t *buffer[readdata];
//        NSUInteger numofread = [assetRepresentation getBytes:&buffer fromOffset:readover length:sizeof(buffer) error:&err];
//        if(err){
//            break;
//        }
//        if(numofread>0){
//            readover = readover + numofread;
//            NSData *data = [NSData dataWithBytes:(void *)(buffer) length:numofread];
//            [file writeData:data];
//        }
//    }
//    [file close];
//    backupover ++;
//}
@end
