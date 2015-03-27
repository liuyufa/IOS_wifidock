//
//  WFCommon.h
//  WiFiDock
//
//  Created by apple on 14-12-5.
//  Copyright (c) 2014年 cn.hualu.WiFiDock. All rights reserved.
//

#ifndef WiFiDock_WFCommon_h
#define WiFiDock_WFCommon_h
#import "NSString+Ex.h"

#define WFColor(r, g, b) [UIColor colorWithRed:(r)/255.0 green:(g)/255.0 blue:(b)/255.0 alpha:1.0]


#define KWFFileUtilTempPath NSTemporaryDirectory()
#define KWFCachePath [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0]

#define kSmbIp                  @"10.10.1.1"
#define KSmbURL                 @"smb://Hualu:123456@10.10.1.1/hualu"
#define COPY_BUFFER_SIZE_SUB    1024
#define COPY_BUFFER_SIZE        4096
#define LOCAL_HTTP_PORT         12345
#define LOCAL_HTTP_PATH         @"http://127.0.0.1"
#define SAMBA_USERNAME          @"Hualu"
#define SAMBA_PWD               @"123456"
#define SAMBA_URL               @"smb://Hualu:123456@10.10.1.1/hualu"

typedef enum {
    File,
    FileDir,
} FileType;

#pragma mark通知类

#define kSambaChangedNotification   @"kSambaChangedNotification"
#define kCntChangedNotification     @"kCntChangedNotification"
#define kCopyOverNotification       @"kCopyOverNotification"
#define KWFCopyPhotosAction         @"KWFCopyPhotosAction"
#define KSelectePhotos              @"KSelectePhotos"
#define kLoadingFinsish             @"kLoadingFinsish"
#define KProgeress                  @"KProgeress"
#define KStopLoading                @"stop"
#define kDelete                     @"kDelete"

#pragma mark 系统版本
#define KVersion  [[[UIDevice currentDevice]systemVersion]floatValue]

#endif
