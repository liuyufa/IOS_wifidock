//
//  WFFileUtil.h
//  WiFiDock
//
//  Created by apple on 14-12-6.
//  Copyright (c) 2014年 cn.hualu.WiFiDock. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#define WFImageType [NSArray arrayWithObjects:@"tif",@"jpg",@"jpeg",@"gif",@"png",@"ico",@"cur",@"xbm",@"bmp",nil]
#define WFDocType  [NSArray arrayWithObjects:@"txt",@"pdf",@"word",@"doc",@"docx",@"xls",@"xlsx",@"vcf",@"ppt",@"pptx",nil]
#define WFAudioType  [NSArray arrayWithObjects:@"mp3",@"aac",@"m4a",@"wma",@"ogg",@"wav",@"ape",@"flac",nil]
#define WFMovieType  [NSArray arrayWithObjects:@"mov",@"mp4",@"3gp",@"avi",@"mpeg",@"flv",@"f4v",@"mpg",@"rmvb",@"rm",@"mkv",@"wmv",@"asf",@"divx",@"ram",@"vod",nil]

@class WFFile;

@interface WFFileUtil : NSObject
+ (BOOL) fileCopyWithItem:(id)item destPath:(NSString *)destPath;
+ (BOOL) isExistsAtPath:(NSString *)path;
+ (BOOL) createFolderAtPaht:(NSString *)path;
+ (NSString *)getDocumentPath;
+(long long) folderSizeAtPath:(NSString*) folderPath;
+ (long long) fileSizeAtPath:(NSString*) filePath;
+(BOOL)isFolder:(NSString*) path;
+(BOOL)removeFileAtPaht:(NSString*)filePath;
+(BOOL)renameFileAtPaht:(NSString*)filePath rename:(NSString*)rename;
//+ (void)fileCopyWithItem:(WFFile *)file destPath:(NSString *)destPath;

+ (UIImage *)getFileIcon:(NSString *)extension;
+ (BOOL)isImage:(NSString *)extension;
+ (BOOL)isAudio:(NSString *)extension;
+ (BOOL)isDoc:(NSString *)extension;
+ (BOOL)isVideo:(NSString *)extension;
@end
