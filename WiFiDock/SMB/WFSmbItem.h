//
//  WFSMBFile.h
//  WiFiDock
//
//  Created by apple on 14-12-23.
//  Copyright (c) 2014年 cn.hualu.WiFiDock. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WFSmbFileType.h"

@class WFSmbFileState;

@interface WFSmbItem : NSObject

@property (nonatomic, copy) NSString *filePath;
@property (nonatomic, copy) NSString *fileName;
@property (nonatomic,assign)WFSmbItemType fileType;
@property (nonatomic,strong)WFSmbFileState *fileState;
@property (nonatomic, strong) id ID;

+ (instancetype)smbItemWith:(WFSmbFileState *)fileState filePath:(NSString *)filePath fileType:(WFSmbItemType)fileType;

- (instancetype)initWith:(WFSmbFileState *)fileState filePath:(NSString *)filePath fileType:(WFSmbItemType)fileType;

@end
