//
//  WFActionTool.h
//  WiFiDock
//
//  Created by apple on 15-1-7.
//  Copyright (c) 2015年 cn.hualu.WiFiDock. All rights reserved.
//

#import <Foundation/Foundation.h>
@class WFAction;
@interface WFActionTool : NSObject

+(BOOL)canPaste:(WFAction*)item;
+(BOOL)haveSameName:(WFAction*)item;
+ (long long) freeDiskSpaceInBytes;
+(BOOL)isExistsAtPath:(NSString*)path;
+(BOOL)removeFileAtPath:(NSString*)path;
+(BOOL)createAtPaht:(NSString*)path;
+(NSString*)buildUploadImageName:(NSString*)baseDir;
+(NSString*)buildUploadVideoName:(NSString*)baseDir;
+(BOOL)renameFileAtPaht:(NSString*)path rename:(NSString *)rename;
@end
