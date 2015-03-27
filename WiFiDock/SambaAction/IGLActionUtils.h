//
//  IGLActionUtils.h
//  IGL004
//
//  Created by apple on 2014/05/23.
//  Copyright (c) 2014年 hualu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IGLActionItem.h"
#import "IGLSMBProvier.h"
@interface IGLActionUtils : NSObject
+(BOOL)isExistsAtPath:(NSString*)path;
+(BOOL)haveSameName:(IGLActionItem*)item;
+(BOOL)canPaste:(IGLActionItem*)item;
+(BOOL)removeFileAtPath:(NSString*)path;
+(BOOL)renameFileAtPaht:(NSString*)path rename:rename;
+(BOOL)createAtPaht:(NSString*)path;
+ (long long) freeDiskSpaceInBytes;
+(NSString*)buildUploadImageName:(NSString*)baseDir;
+(NSString*)buildUploadVideoName:(NSString*)baseDir;
@end
