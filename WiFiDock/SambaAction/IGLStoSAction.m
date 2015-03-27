//
//  IGLStoSAction.m
//  IGL004
//
//  Created by apple on 2014/05/25.
//  Copyright (c) 2014年 hualu. All rights reserved.
//

#import "IGLStoSAction.h"

@implementation IGLStoSAction{
    BOOL loopover;
}
+(id)actionWithItem:(IGLActionItem*)item{
    IGLStoSAction *manager =  [[IGLStoSAction alloc] init];
    manager.item = item;
    return manager;
}

-(void)doCopyAction{
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
    while(!loopover){
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
    if([self.item isFolder]){
        NSString *rootPath = [[self.item.fromPath stringByDeletingSMBLastPathComponent] stringByAppendingString:@"/"];
        for (IGLSMBItem *item in allFileList) {
            
            if ([item isKindOfClass:[IGLSMBItemTree class]]) {
                NSString* toPath = [self.item.toPath stringByAppendingSMBPathComponent:[[item path] stringByReplacingOccurrencesOfString:rootPath withString:@""]];
                [IGLActionUtils createAtPaht:toPath];
            }
            if ([item isKindOfClass:[IGLSMBItemFile class]]) {
                NSString* toPath = [self.item.toPath stringByAppendingSMBPathComponent:[[item path] stringByReplacingOccurrencesOfString:rootPath withString:@""]];
                [self copySMBFile:(IGLSMBItemFile *)item smbpath:toPath];
            }
            if(_iscancel){
                break;
            }
        }
    }else{
        if([allFileList count]>0){
            [self copySMBFile:(IGLSMBItemFile *)[allFileList objectAtIndex:0] smbpath:_targetpath];
        }
    }
    
    [self runWhenFinished];
}

- (void) copySMBFile:(IGLSMBItemFile *)smbFile
           smbpath:(NSString *)smbpath
{
    
    id result = [[IGLSMBProvier sharedSmbProvider]  createFileAtPath:smbpath overwrite:YES];
    if(![result isKindOfClass:[IGLSMBItemFile class]]){
        return;
    }
    IGLSMBItemFile *file = (IGLSMBItemFile *)result;
    loopover = NO;
    [self writeSmbFile:file fromSmbfile:smbFile len:0];
    while(!loopover){
        sleep(1);
    }
    [smbFile close];
    [file close];
}

-(void)writeSmbFile:(IGLSMBItemFile *)smbFile fromSmbfile:(IGLSMBItemFile *)fromSmbfile len:(NSInteger)len{
    
    if(len == -1 || _iscancel){
        loopover = YES;
        return;
    }
    self.item.overedSize +=len;
    [fromSmbfile readDataOfLength:COPYSPEED
                        block:^(id result)
     {
         if ([result isKindOfClass:[NSData class]]&&[result length] > 0) {
             [smbFile writeData:result block:^(id num) {
                 if ([num isKindOfClass:[NSNumber class]]) {
                     [self writeSmbFile:smbFile fromSmbfile:fromSmbfile len:[num integerValue]];
                 }else{
                     [self writeSmbFile:smbFile fromSmbfile:fromSmbfile len:-1];
                 }
             }];
         }else{
             [self writeSmbFile:smbFile fromSmbfile:fromSmbfile len:-1];
         }
     }];
}
@end
