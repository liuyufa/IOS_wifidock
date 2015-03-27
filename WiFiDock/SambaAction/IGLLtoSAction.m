//
//  IGLLtoSAction.m
//  IGL004
//
//  Created by apple on 2014/05/23.
//  Copyright (c) 2014年 hualu. All rights reserved.
//

#import "IGLLtoSAction.h"
#import "IGLActionManager.h"
#import "WFFileUtil.h"
@implementation IGLLtoSAction{
    BOOL copyover;
}

+(id)actionWithItem:(IGLActionItem*)item{
    IGLLtoSAction *manager =  [[IGLLtoSAction alloc] init];
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
    NSFileManager* manager = [NSFileManager defaultManager];
    if(self.item.isFolder){
        self.item.fileSize =[WFFileUtil folderSizeAtPath:self.item.fromPath];
        
        if(![IGLActionUtils createAtPaht:_targetpath]){
            [self runWhenFinished];
            return;
        }
        
        NSEnumerator *childFilesEnumerator = [[manager subpathsAtPath:self.item.fromPath] objectEnumerator];
        NSString* fileName;
        while ((fileName = [childFilesEnumerator nextObject]) != nil){
            NSString* srcPath = [self.item.fromPath stringByAppendingSMBPathComponent:fileName];
            NSString* tarPath = [_targetpath stringByAppendingSMBPathComponent:fileName];
            if([WFFileUtil isFolder:srcPath]){
                [IGLActionUtils createAtPaht:tarPath];
            }else{
                [self copyAction:srcPath target:tarPath];
            }
            if(_iscancel){
                break;
            }
        }
    }else{
        self.item.fileSize =[WFFileUtil fileSizeAtPath:self.item.fromPath];
        [self copyAction:self.item.fromPath target:_targetpath];
    }
    [self runWhenFinished];
}


-(void)copyAction:(NSString*)srcPath target:(NSString*)tarPath
{
    NSFileHandle *readfile = [NSFileHandle fileHandleForReadingAtPath:srcPath];
    if(!readfile){
        return;
    }
    id result = [[IGLSMBProvier sharedSmbProvider]  createFileAtPath:tarPath overwrite:YES];
    if(![result isKindOfClass:[IGLSMBItemFile class]]){
        [readfile closeFile];
        return;
    }
    
    IGLSMBItemFile *file = (IGLSMBItemFile *)result;
    
    copyover = NO;
    
    [self writeSMBFile:file fileHandle:readfile];
    
    while(!copyover){
        sleep(1);
    }
    [readfile closeFile];
    [file close];
}


- (void) writeSMBFile:(IGLSMBItemFile *)smbFile
           fileHandle:(NSFileHandle *)readfile
{
    NSData *data = [readfile readDataOfLength:COPYSPEED];
    if(data.length>0&&!_iscancel){
        [smbFile writeData:data block:^(id result) {
            
            if ([result isKindOfClass:[NSNumber class]]) {
                [self  writeSMBFile:smbFile
                         fileHandle:readfile];
                self.item.overedSize += [data length];
            }
        }];
        
    }else{
        copyover = YES;
    }
}
@end
