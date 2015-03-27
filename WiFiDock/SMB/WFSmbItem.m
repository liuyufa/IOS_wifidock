//
//  WFSmbFile.m
//  WiFiDock
//
//  Created by apple on 14-12-23.
//  Copyright (c) 2014年 cn.hualu.WiFiDock. All rights reserved.
//

#import "WFSmbItem.h"
#import "WFSmbFileState.h"
#import "WFSmbDirectory.h"
#import "WFSmbFile.h"


@implementation WFSmbItem
+ (instancetype)smbItemWith:(WFSmbFileState *)fileState filePath:(NSString *)filePath fileType:(WFSmbItemType)fileType
{
    return [[self alloc]initWith:fileState filePath:filePath fileType:fileType];
}

- (instancetype)initWith:(WFSmbFileState *)fileState filePath:(NSString *)filePath fileType:(WFSmbItemType)fileType
{
    self = [super init];
    if (self) {
        
        self.fileState = fileState;
        self.filePath = filePath;
        self.fileName = [filePath lastPathComponent];
        
        if (S_ISDIR(fileState.mode)) {
            
            self.fileType = WFSmbItemTypeDir;
            
            self.ID = [WFSmbDirectory class];
            
        }else{
            
            self.fileType = WFSmbItemTypeFile;
            
            self.ID = [WFSmbFile class];
        }
        
    }
    
    return self;
}

@end
