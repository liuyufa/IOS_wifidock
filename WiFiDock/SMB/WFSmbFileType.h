//
//  WFSmbFileType.h
//  WiFiDock
//
//  Created by apple on 14-12-23.
//  Copyright (c) 2014年 cn.hualu.WiFiDock. All rights reserved.
//

#ifndef WiFiDock_WFSmbFileType_h
#define WiFiDock_WFSmbFileType_h

typedef enum {
    WFSmbItemTypeUnknown,
    WFSmbItemTypeWorkgroup,
    WFSmbItemTypeServer,
    WFSmbItemTypeFileShare,
    WFSmbItemTypePrinter,
    WFSmbItemTypeComms,
    WFSmbItemTypeIPC,
    WFSmbItemTypeDir,
    WFSmbItemTypeFile,
    WFSmbItemTypeLink,
    
} WFSmbItemType;

typedef enum {
    WFSmbErrorUnknown,
    WFSmbErrorInvalidArg,
    WFSmbErrorInvalidProtocol,
    WFSmbErrorOutOfMemory,
    WFSmbErrorPermissionDenied,
    WFSmbErrorInvalidPath,
    WFSmbErrorPathIsNotDir,
    WFSmbErrorPathIsDir,
    WFSmbErrorWorkgroupNotFound,
    WFSmbErrorShareDoesNotExist,
    WFSmbErrorItemAlreadyExists,
    WFSmbErrorDirNotEmpty,
    WFSmbErrorFileIO,
} WFSmbError;

@class WFSmbItem;

typedef void (^WFSmbBlock)(id result);
typedef void (^WFSmbBlockProgress)(WFSmbItem *item, long transferred);
typedef BOOL (^WFSmbCancelBlock)();

#endif
