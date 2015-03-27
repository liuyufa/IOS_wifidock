//
//  WFSTOSAction.m
//  WiFiDock
//
//  Created by apple on 15-1-7.
//  Copyright (c) 2015年 cn.hualu.WiFiDock. All rights reserved.
//

#import "WFSToSAction.h"
#import "IGLSMBProvier.h"

@interface WFSToSAction()
@property(nonatomic,assign) BOOL loop;

@end

@implementation WFSToSAction

+ (instancetype)actionWithItem:(WFAction *)item
{
    return [[WFSToSAction alloc]initWithItem:item];
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
    while(!self.loop){
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
        NSString *rootPath = [[self.item.from  stringByDeletingSMBLastPathComponent] stringByAppendingString:@"/"];
        for (IGLSMBItem *item in allFileList) {
            
            if ([item isKindOfClass:[IGLSMBItemTree class]]) {
                NSString* toPath = [self.item.dest stringByAppendingSMBPathComponent:[[item path] stringByReplacingOccurrencesOfString:rootPath withString:@""]];
                [WFActionTool createAtPaht:toPath];
            }
            if ([item isKindOfClass:[IGLSMBItemFile class]]) {
                NSString* toPath = [self.item.dest  stringByAppendingSMBPathComponent:[[item path] stringByReplacingOccurrencesOfString:rootPath withString:@""]];
                [self copySMBFile:(IGLSMBItemFile *)item smbpath:toPath];
            }
            if(self.iscancel){
                break;
            }
        }
    }else{
        if([allFileList count]>0){
            [self copySMBFile:(IGLSMBItemFile *)[allFileList objectAtIndex:0] smbpath:self.targetpath];
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
    self.loop = NO;
    [self writeSmbFile:file fromSmbfile:smbFile len:0];
    while(!self.loop){
        sleep(1);
    }
    [smbFile close];
    [file close];
    
}

-(void)writeSmbFile:(IGLSMBItemFile *)smbFile fromSmbfile:(IGLSMBItemFile *)fromSmbfile len:(NSInteger)len{
    
    if(len == -1 || self.iscancel){
        self.loop = YES;
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
