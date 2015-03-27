//
//  IGLStoLAction.m
//  IGL004
//
//  Created by apple on 2014/05/24.
//  Copyright (c) 2014年 hualu. All rights reserved.
//

#import "IGLStoLAction.h"

@implementation IGLStoLAction{
    BOOL loopover;
    //NSRunLoop *currentLoop;
}

+(id)actionWithItem:(IGLActionItem*)item{
    IGLStoLAction *manager =  [[IGLStoLAction alloc] init];
    manager.item = item;
    return manager;
}

-(void)doCopyAction{
    
    //currentLoop = CFRunLoopGetCurrent();
    
    _targetpath = [self buildPath];
    if(!_targetpath){
        [self runWhenFinished];
        return;
    }
    
    if([IGLActionUtils isExistsAtPath:_targetpath]){
        BOOL issuccess  = [IGLActionUtils removeFileAtPath:_targetpath];
        if(!issuccess){
            [self runWhenFinished];
            return;
        }
    }
    
    loopover = NO;
    __block id allFileList;
    [[IGLSMBProvier sharedSmbProvider] fetchAllFileAtPath:self.item.fromPath block:^(id result) {
        loopover = YES;
        allFileList = result;
    }];
    
    while (!loopover) {
        sleep(1);
    }
    
    if(![allFileList isKindOfClass:[NSArray class]]){
        [self runWhenFinished];
        return;
    }
    
    for (IGLSMBItem *item in allFileList) {
        if ([item isKindOfClass:[IGLSMBItemFile class]]) {
            self.item.fileSize += [(IGLSMBItemFile*)item stat].size;
        }
    }
    if([IGLActionUtils freeDiskSpaceInBytes] <= (self.item.fileSize+1024*1024)){
        [self runWhenFinished];
        return;
    }
    NSString *rootPath = [[self.item.fromPath stringByDeletingSMBLastPathComponent] stringByAppendingString:@"/"];
    for (IGLSMBItem *item in allFileList) {
        
        if ([item isKindOfClass:[IGLSMBItemTree class]]) {
            NSString* toPath = [self.item.toPath stringByAppendingSMBPathComponent:[[item path] stringByReplacingOccurrencesOfString:rootPath withString:@""]];
            [IGLActionUtils createAtPaht:toPath];
        }
        if ([item isKindOfClass:[IGLSMBItemFile class]]) {
            NSString* toPath = [self.item.toPath stringByAppendingSMBPathComponent:[[item path] stringByReplacingOccurrencesOfString:rootPath withString:@""]];
            [self copySMBFile:(IGLSMBItemFile *)item localPath:toPath];
        }
        if(_iscancel){
            break;
        }
    }
    [self runWhenFinished];
}

- (void) copySMBFile:(IGLSMBItemFile *)smbFile
           localPath:(NSString *)localPath
{
    BOOL issuccess = [[NSFileManager defaultManager] createFileAtPath:localPath
                contents:nil
                                                           attributes:nil];
    if(!issuccess){
        return;
    }
    NSFileHandle *fileHandle = [NSFileHandle fileHandleForWritingAtPath:localPath];
    if(!fileHandle){
        return;
    }
    loopover = NO;
    [self writeLocalFile:smbFile fileHandle:fileHandle len:0];
    while (!loopover) {
        sleep(1);
    }
//    while(!loopover){
//        [[NSRunLoop currentRunLoop] runMode:IGLCopyRunLoopMode beforeDate:[NSDate distantFuture]];
//    }
    [smbFile close];
    [fileHandle closeFile];
}

-(void)writeLocalFile:(IGLSMBItemFile *)smbFile fileHandle:(NSFileHandle *)fileHandle len:(NSInteger)len{
    
    if(len == -1 || _iscancel){
        loopover = YES;
        return;
    }
    self.item.overedSize +=len;
    [smbFile readDataOfLength:COPYSPEED
                        block:^(id result)
     {
         if ([result isKindOfClass:[NSData class]]) {
             NSData *data = result;
             if (data.length) {
                 [fileHandle writeData:data];
                 [self writeLocalFile:smbFile fileHandle:fileHandle len:data.length];
                 
             } else {
                 [self writeLocalFile:smbFile fileHandle:fileHandle len:-1];
             }
         }else{
             [self writeLocalFile:smbFile fileHandle:fileHandle len:-1];
         }
     }];
}

@end
