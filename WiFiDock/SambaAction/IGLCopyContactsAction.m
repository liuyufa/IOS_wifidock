//
//  IGLCopyContactsAction.m
//  IGL004
//
//  Created by apple on 2014/05/25.
//  Copyright (c) 2014年 hualu. All rights reserved.
//

#import "IGLCopyContactsAction.h"
#import "IGLActionManager.h"
#import<AssetsLibrary/AssetsLibrary.h>
#import <AddressBook/AddressBook.h>
#include <sys/param.h>
#include <sys/mount.h>
#include "FileUtil_C.h"
#import  <UIKit/UIKit.h>

@implementation IGLCopyContactsAction{
    UIBackgroundTaskIdentifier backgroundTask;
}
-(id)initWithCopyPath:(NSString*)copyPath{
    self = [super init];
    if(self){
        _copyPath = copyPath;
    }
    return self;
}
- (void)startAsynchronous
{
	[[IGLActionManager sharedManage] addOperation:self];
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
    _complete = NO;
    fileSize = 0;
    overedSize = 0;
    [self loadContactsData];
}
-(void)runWhenFinished{
    if(_iscancel){
        if(_targetpath){
            [IGLActionUtils removeFileAtPath:_targetpath];
        }
        [[IGLActionManager sharedManage] removeOperation:self];
    }else{
        _complete = YES;
        [[IGLActionManager sharedManage] removeOperation:self];
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
-(NSString*)operationName{return NSLocalizedString(@"Copy Contacts", nil);}
-(NSString*)totalStr{return [NSString stringWithFormat:@"%dKB",(int)(fileSize/1000)];}
-(NSString*)overedStr{return [NSString stringWithFormat:@"%dKB",(int)(overedSize/1000)];}
-(float)progress{return overedSize*1.0/fileSize*1.0;}

-(void)loadContactsData
{
    
    _targetpath = [_copyPath stringByAppendingSMBPathComponent:@"Contacts_Vcard.vcf"];
    
    if([IGLActionUtils isExistsAtPath:_targetpath]){
        _targetpath = [self changeNameWhenHaveSame:_targetpath];
    }
    
    if(![_copyPath hasPrefix:SAMBA_URL]){
        [self backupContacts];
        [self runWhenFinished];
        return;
    }
    
    id result = [[IGLSMBProvier sharedSmbProvider]  createFileAtPath:_targetpath overwrite:YES];
    if(![result isKindOfClass:[IGLSMBItemFile class]]){
        [self runWhenFinished];
        return;
    }
    IGLSMBItemFile *file = (IGLSMBItemFile *)result;
    
    CFErrorRef innerError = nil;
    ABAddressBookRef addressBook;
    if ([self isABAddressBookCreateWithOptionsAvailable]) {
        addressBook = ABAddressBookCreateWithOptions(NULL,&innerError);
        //            AddressBookUpdated(addressBook, nil, self);
        //            CFRelease(addressBook);
    } else {
        addressBook = ABAddressBookCreate();
        //            AddressBookUpdated(addressBook, NULL, self);
        //            CFRelease(addressBook);
    }
    
    if (innerError) {
        [self runWhenFinished];
        return;
    }
    
    CFArrayRef contacts = ABAddressBookCopyArrayOfAllPeople(addressBook);
    CFDataRef contactsdata =ABPersonCreateVCardRepresentationWithPeople(contacts);
    long long datasize = CFDataGetLength(contactsdata);
    fileSize = datasize;
    long readover = 0;
    while (readover < datasize) {
        if(_iscancel){
            break;
        }
        long readdata = COPY_BUFFER_SIZE;
        if(datasize - readover < readdata){
            readdata = datasize - readover;
        }
        UInt8* buffer = malloc(readdata);
        //UInt8 *buffer[readdata];
        CFDataGetBytes(contactsdata, CFRangeMake((CFIndex)readover,(CFIndex)readdata), buffer);
        readover = readover + readdata;
        overedSize = readover;
        NSData *data = [NSData dataWithBytes:(void *)(buffer) length:readdata];
        [file writeData:data];
    }
    CFRelease(contactsdata);
    CFRelease(addressBook);
    [file close];
    [self runWhenFinished];
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
-(BOOL)isABAddressBookCreateWithOptionsAvailable {
    return &ABAddressBookCreateWithOptions != NULL;
}

-(void)backupContacts {
    ABAddressBookRef addressBook;
    if ([self isABAddressBookCreateWithOptionsAvailable]) {
        CFErrorRef error = nil;
        addressBook = ABAddressBookCreateWithOptions(NULL,&error);
        AddressBookUpdated(addressBook, nil, self);
        CFRelease(addressBook);
    } else {
        addressBook = ABAddressBookCreate();
        AddressBookUpdated(addressBook, NULL, self);
        CFRelease(addressBook);
    }
}

void AddressBookUpdated(ABAddressBookRef addressBook, CFDictionaryRef info, id selfObject) {
    CFArrayRef people = ABAddressBookCopyArrayOfAllPeople(addressBook);
    NSData *vCardData = (__bridge_transfer NSData*)(ABPersonCreateVCardRepresentationWithPeople(people));
    [selfObject writeToFile:vCardData];
};

- (void)writeToFile: (NSData *)data{
    [data writeToFile:_targetpath options:NSDataWritingAtomic error:nil];
}

@end
