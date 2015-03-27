//
//  WFLToSAction.m
//  WiFiDock
//
//  Created by apple on 15-1-7.
//  Copyright (c) 2015年 cn.hualu.WiFiDock. All rights reserved.
//

#import "WFLToSAction.h"
#import "IGLSMBProvier.h"

@interface WFLToSAction ()
@property(nonatomic,assign)BOOL copyover;

@end

@implementation WFLToSAction


+ (instancetype)actionWithItem:(WFAction *)item
{
    return [[WFLToSAction alloc]initWithItem:item];
}

- (instancetype)initWithItem:(WFAction *)item
{
     self = [super init];
    if (self) {
        
        self.item = item;
    }
    return self;
}

-(void)doCopyAction{
    self.targetpath = [self buildPath];
    if(!self.targetpath){
        [self runWhenFinished];
        return;
    }
    if([WFActionTool isExistsAtPath:self.targetpath]){
        BOOL result  = [WFActionTool removeFileAtPath:self.targetpath];
        if(!result){
            [self runWhenFinished];
            return;
        }
    }
    NSFileManager* manager = [NSFileManager defaultManager];
    if(self.item.isFolder){
        self.item.fileSize =[WFFileUtil folderSizeAtPath:self.item.from];
        
        if(![WFActionTool createAtPaht:self.targetpath]){
            [self runWhenFinished];
            return;
        }
        
        NSEnumerator *filesEnumerator = [[manager subpathsAtPath:self.item.from] objectEnumerator];
        NSString* fileName;
        while ((fileName = [filesEnumerator nextObject]) != nil){
            NSString* srcPath = [self.item.from stringByAppendingSMBPathComponent:fileName];
            NSString* tarPath = [self.targetpath stringByAppendingSMBPathComponent:fileName];
            if([WFFileUtil isFolder:srcPath]){
                [WFActionTool createAtPaht:tarPath];
            }else{
                [self copyAction:srcPath target:tarPath];
            }
            if(self.iscancel){
                break;
            }
        }
    }else{
        self.item.fileSize =[WFFileUtil fileSizeAtPath:self.item.from];
        [self copyAction:self.item.from target:self.targetpath];
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
    
    self.copyover = NO;
    
    [self writeSMBFile:file fileHandle:readfile];
    
    while(!self.copyover){
        sleep(1);
    }
    [readfile closeFile];
    [file close];
   
}


- (void) writeSMBFile:(IGLSMBItemFile *)smbFile
           fileHandle:(NSFileHandle *)readfile
{
    NSData *data = [readfile readDataOfLength:COPYSPEED];
    if(data.length>0&&!self.iscancel){
        [smbFile writeData:data block:^(id result) {
            
            if ([result isKindOfClass:[NSNumber class]]) {
                [self  writeSMBFile:smbFile
                         fileHandle:readfile];
                self.item.overedSize += [data length];
            }
        }];
        
    }else{
        self.copyover = YES;
    }
}


@end
