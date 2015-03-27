//
//  WFSTOLAction.m
//  WiFiDock
//
//  Created by apple on 15-1-7.
//  Copyright (c) 2015年 cn.hualu.WiFiDock. All rights reserved.
//

#import "WFSToLAction.h"
#import "IGLSMBProvier.h"
@interface WFSToLAction ()
@property(nonatomic,assign) BOOL loop;

@end

@implementation WFSToLAction

+ (instancetype)actionWithItem:(WFAction *)item
{
    return [[WFSToLAction alloc]initWithItem:item];
}

- (instancetype)initWithItem:(WFAction *)item
{
     self = [super init];
    if (self) {
        
        self.item = item;
    }
    return self;
}

-(void)dealloc
{
    NSLog(@"doCopyAction dealloc");
}

-(void)doCopyAction
{

    self.targetpath = [self buildPath];
    if(!self.targetpath){
        [self runWhenFinished];
        return;
    }
    
    if([WFActionTool isExistsAtPath:self.targetpath]){
        BOOL issuccess  = [WFActionTool removeFileAtPath:self.targetpath];
        if(!issuccess){
            [self runWhenFinished];
            return;
        }
    }
    
    self.loop = NO;
    __block id allFileList;
    [[IGLSMBProvier sharedSmbProvider] fetchAllFileAtPath:self.item.from block:^(id result) {
        self.loop = YES;
        allFileList = result;
    }];
    
    while (!self.loop) {
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
    if([WFActionTool freeDiskSpaceInBytes] <= (self.item.fileSize+1024*1024)){
        [self runWhenFinished];
        return;
    }
    NSString *rootPath = [[self.item.from stringByDeletingSMBLastPathComponent] stringByAppendingString:@"/"];
    for (IGLSMBItem *item in allFileList) {
        
        if ([item isKindOfClass:[IGLSMBItemTree class]]) {
            NSString* toPath = [self.item.dest stringByAppendingSMBPathComponent:[[item path] stringByReplacingOccurrencesOfString:rootPath withString:@""]];
            [WFActionTool createAtPaht:toPath];
        }
        if ([item isKindOfClass:[IGLSMBItemFile class]]) {
            NSString* toPath = [self.item.dest stringByAppendingSMBPathComponent:[[item path] stringByReplacingOccurrencesOfString:rootPath withString:@""]];
            [self copySMBFile:(IGLSMBItemFile *)item localPath:toPath];
        }
        if(self.iscancel){
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
    self.loop = NO;
    [self writeLocalFile:smbFile fileHandle:fileHandle len:0];
    while (!self.loop) {
        sleep(1);
    }
   
    [smbFile close];
    [fileHandle closeFile];
    
}

-(void)writeLocalFile:(IGLSMBItemFile *)smbFile fileHandle:(NSFileHandle *)fileHandle len:(NSInteger)len
{
    
    if(len == -1 || self.iscancel){
        self.loop = YES;
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
