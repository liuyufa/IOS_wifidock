//
//  IGLCopyPhotosAction.m
//  IGL004
//
//  Created by apple on 2014/05/25.
//  Copyright (c) 2014年 hualu. All rights reserved.
//

#import "IGLCopyPhotosAction.h"
#import "WFActionManager.h"
#include <sys/param.h>
#include <sys/mount.h>
#import  <UIKit/UIKit.h>
#import "IGLCopyAction.h"
#import "WFActionTool.h"
#import<AssetsLibrary/AssetsLibrary.h>
#import "IGLSMBProvier.h"
#import "ZLPhotoAssets.h"

@implementation IGLCopyPhotosAction
{
    //ALAssetsLibrary* library;
    BOOL _isRunlopOver;
    dispatch_queue_t    _dispatchQueue;
    UIBackgroundTaskIdentifier backgroundTask;
    NSArray *_selectArray;
}
-(void)dealloc{
    NSLog(@"dealloc self");
}
- (void)startAsynchronous
{
	[[WFActionManager sharedManage] addOperation:self];
}
-(id)initWithCopyPath:(NSString*)copyPath{
    self = [super init];
    if(self){
        _copyPath = copyPath;
        
    }
    return self;
}

- (id)initWithArray:(NSArray *)seletectArray Path:(NSString *)path
{
    self = [super init];
    
    if(self){

        _selectArray = seletectArray;
        _copyPath = path;
    }
    
    return self;
}

-(BOOL)isFinished{
    return self.complete;
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
//    [self loadImageFromPhotoLibrary_step1];
    [self loadImage];
    while (!self.complete) {
        sleep(1);
    }
}
-(void)runWhenFinished{
    if(self.iscancel){
        [WFActionTool removeFileAtPath:_rootpath];
        self.complete = YES;
    }else{
        self.complete = YES;
    }
    [[WFActionManager sharedManage] removeOperation:self];
    
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
                    if(![WFActionTool isExistsAtPath:_rootpath]){
                        if(![WFActionTool createAtPaht:_rootpath]){
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
            if(self.iscancel){
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
                
                if(![WFActionTool isExistsAtPath:_subpath]){
                    if(![WFActionTool createAtPaht:_subpath]){
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

- (void)loadImage
{
    numofphoto = _selectArray.count;
//    NSDate  *curdate=[NSDate date];
//    NSDateFormatter  *dateformatter=[[NSDateFormatter alloc] init];
//    [dateformatter setDateFormat:@"YYYYMMddHHmmss"];
//    NSString *locationString=[dateformatter stringFromDate:curdate];

    NSString *fileName = [NSString stringWithFormat:@"%@",@"Wifidockbackups"];
    _rootpath = [_copyPath stringByAppendingSMBPathComponent:fileName];
    
    if(![WFActionTool isExistsAtPath:_rootpath]){
        
        BOOL value = [WFActionTool createAtPaht:_rootpath];
        
        if (!value) {
            [self performSelectorOnMainThread:@selector(runWhenFinished) withObject:nil waitUntilDone:YES];
            return;
        }
    }


    for (ZLPhotoAssets *asset in _selectArray) {
        
        ALAssetRepresentation *assetRepresentation =[asset.asset defaultRepresentation];
        NSString *filePath = [_rootpath stringByAppendingSMBPathComponent:assetRepresentation.filename];
        if([WFActionTool isExistsAtPath:filePath]){
            backupover ++;
            continue;
        }else{
            
            [self uploadPhoto:asset.asset];
        }
    }
    
    [[IGLMessageManager sharedManage] showmessage:NSLocalizedString(@"Album Backups Successfully",nil)];
    
    [self performSelectorOnMainThread:@selector(runWhenFinished) withObject:nil waitUntilDone:YES];
}



- (void)uploadPhoto:(ALAsset*)asset
{
    ALAssetRepresentation *assetRepresentation =[asset defaultRepresentation];
//    NSString *filePath = [_subpath stringByAppendingSMBPathComponent:assetRepresentation.filename];
    NSString *filePath = [_rootpath stringByAppendingSMBPathComponent:assetRepresentation.filename];
//    if([WFActionTool isExistsAtPath:filePath]){
//        backupover ++;
//        return;
//    }
    id result = [[IGLSMBProvier sharedSmbProvider]  createFileAtPath:filePath overwrite:YES];
    if(![result isKindOfClass:[IGLSMBItemFile class]]){
        backupover ++;
        return;
    }
    IGLSMBItemFile *file = (IGLSMBItemFile *)result;
    long long imagesize = assetRepresentation.size;
    long long readover = 0;
    while (readover < imagesize) {
        long long readdata = COPY_BUFFER_SIZE;
        if(imagesize - readover < readdata){
            readdata = imagesize - readover;
        }
        NSError *err;
        uint8_t buffer[readdata];
        NSUInteger numofread = [assetRepresentation getBytes:buffer fromOffset:readover length:sizeof(buffer) error:&err];
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

- (void)uploadtolocal:(ALAsset*)asset
{
    ALAssetRepresentation *assetRepresentation =[asset defaultRepresentation];
    long long imagesize = assetRepresentation.size;
    
    if([WFActionTool freeDiskSpaceInBytes] <= (assetRepresentation.size+1024*1024)){
        return;
    }
    NSString *filePath = [_subpath stringByAppendingSMBPathComponent:assetRepresentation.filename];
    if([WFActionTool isExistsAtPath:filePath]){
        backupover ++;
        return;
    }else{
        [[NSFileManager defaultManager] createFileAtPath:filePath contents:nil attributes:nil];
    }
    
    NSFileHandle *fileHandel = [NSFileHandle fileHandleForWritingAtPath:filePath];
    
    
    long long readover = 0;
    while (readover < imagesize) {
        long long readdata = COPY_BUFFER_SIZE;
        if(imagesize - readover < readdata){
            readdata = imagesize - readover;
        }
        NSError *err;
        uint8_t *buffer;
        NSUInteger numofread = [assetRepresentation getBytes:buffer fromOffset:readover length:sizeof(buffer) error:&err];
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

@end
