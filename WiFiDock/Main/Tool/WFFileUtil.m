//
//  WFFileUtil.m
//  WiFiDock
//
//  Created by apple on 14-12-6.
//  Copyright (c) 2014年 cn.hualu.WiFiDock. All rights reserved.
//

#import "WFFileUtil.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import <UIKit/UIKit.h>
#import "WFFile.h"
#import "UIImage+IW.h"


#define WFLocalPath [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject]

@interface WFFileUtil ()



@end
@implementation WFFileUtil


#pragma mark 函数还需要改动
+ (BOOL)fileCopyWithItem:(id)item destPath:(NSString *)destPath
{
    
    BOOL result = NO;
    WFFile *file = (WFFile*)item;
    
    if ([file.ID isKindOfClass:ALAsset.class]) {
        
        result = [[self alloc]fileCopyWithALAsset:(ALAsset*)file.ID destPath:destPath];
        
    }else{
        
        
    }
    
    return result;
  
}



- (BOOL)fileCopyWithALAsset:(ALAsset *)asset destPath:(NSString *)destPath
{
    
    ALAssetRepresentation *representation =[asset defaultRepresentation];
    
    NSString *filePath = [destPath stringByAppendingPathComponent:[representation filename]];
    
    NSFileManager *manage = [NSFileManager defaultManager];
    if([manage fileExistsAtPath:filePath]){
        [manage removeItemAtPath:filePath error:nil];
    }
    
    char const *cfilePath = [filePath UTF8String];
    
    FILE *tfile = fopen(cfilePath, "a+");
    
    if (!tfile) return NO;
    if (!representation.size ) return NO;
    
    if (tfile) {
        const int buffersize = 1024*1024;
        Byte *buffer = (Byte*)malloc(buffersize);
        NSUInteger read = 0,offset = 0, written = 0;
        NSError *err = nil;
        do{
            read = [representation getBytes:buffer fromOffset:offset length:buffersize error:&err];
            written = fwrite(buffer, sizeof(char), read, tfile);
            offset +=read;
            
        }while (read != 0 && !err);
        
        free(buffer);
        buffer = NULL;
        fclose(tfile);
    }
    
    return YES;

}


+(NSString *) getDocumentPath {
    
    return WFLocalPath;
}

+(BOOL)isExistsAtPath:(NSString*) path{
    
    NSFileManager* manager = [NSFileManager defaultManager];
    
    return [manager fileExistsAtPath:path];
}

+ (BOOL)createFolderAtPaht:(NSString *)path{
    
    NSFileManager* manager = [NSFileManager defaultManager];
    
    if ([manager fileExistsAtPath:path]) return NO;
    
    NSError *err=nil;
    
    [manager createDirectoryAtPath:path withIntermediateDirectories:NO attributes:nil error:&err];
    if(err) return NO;
    
    return YES;
}

+(UIImage *)getFileIcon:(NSString *)extension
{
    if ([self isImage:extension]) {
        
        return [UIImage imageWithName:@"imageicon"];
        
    }else if ([self isAudio:extension]){
        
        return [UIImage imageWithName:@"musicicon"];
        
    }else if ([self isVideo:extension]){
        
        return [UIImage imageWithName:@"videoicon"];
        
    }else{
        
        if ([[extension lowercaseString] isEqualToString:@"pdf"]) {
            
            return [UIImage imageWithName:@"icon_pdf"];
            
        }else if([[extension lowercaseString] hasPrefix:@"doc"]){
            
            return [UIImage imageWithName:@"icon_doc"];
            
        }else if ([[extension lowercaseString] hasPrefix:@"ppt"]){
        
            return [UIImage imageWithName:@"icon_ppt"];
            
        }else if ([[extension lowercaseString] hasPrefix:@"txt"]){
        
            return [UIImage imageWithName:@"icon_text"];
        }else if ([[extension lowercaseString] hasPrefix:@"xls"]){
        
            return [UIImage imageWithName:@"icon_xls"];
        }else if ([[extension lowercaseString] hasPrefix:@"xml"]){
           
            return [UIImage imageWithName:@"icon_xml"];
            
        }else if ([[extension lowercaseString] hasPrefix:@"zip"]||[[extension lowercaseString] hasPrefix:@"rar"]){
            
            return [UIImage imageWithName:@"icon_zip"];
            
        }else if ([[extension lowercaseString] hasPrefix:@"icon_apk"]){
        
            return [UIImage imageWithName:@"icon_apk"];
            
        }else if ([[extension lowercaseString] hasPrefix:@"bin"]){
        
            return [UIImage imageWithName:@"icon_bin"];
        }else if([[extension lowercaseString] hasPrefix:@"lock"]){
            
            return [UIImage imageWithName:@"icon_lock"];
            
        }else {
        
           return [UIImage imageWithName:@"icon_unknow"];
        }
    }
    return nil;
}

+(BOOL)isImage:(NSString *)extension{
    
    return [WFImageType containsObject:[extension lowercaseString]];
}

+(BOOL)isAudio:(NSString *)extension{
    
    return [WFAudioType containsObject:[extension lowercaseString]];
}

+(BOOL)isDoc:(NSString *)extension{
    
    return [WFDocType containsObject:[extension lowercaseString]];
}

+(BOOL)isVideo:(NSString *)extension{
    
    return [WFMovieType containsObject:[extension lowercaseString]];
}

+(long long) folderSizeAtPath:(NSString*) folderPath{
    
    NSFileManager* manager = [NSFileManager defaultManager];
    if (![manager fileExistsAtPath:folderPath]) return 0;
    NSEnumerator *childFilesEnumerator = [[manager subpathsAtPath:folderPath] objectEnumerator];
    NSString* fileName;
    long long folderSize = 0;
    while ((fileName = [childFilesEnumerator nextObject]) != nil){
        NSString* fileAbsolutePath = [folderPath stringByAppendingPathComponent:fileName];
        folderSize += [self fileSizeAtPath:fileAbsolutePath];
    }
    return folderSize;
}

+ (long long) fileSizeAtPath:(NSString*) filePath{
    NSFileManager* manager = [NSFileManager defaultManager];
    if ([manager fileExistsAtPath:filePath]){
        return [[manager attributesOfItemAtPath:filePath error:nil] fileSize];
    }
    return 0;
}

+(BOOL)isFolder:(NSString*) path{
    NSFileManager* manager = [NSFileManager defaultManager];
    BOOL is;
    if([manager fileExistsAtPath:path isDirectory:&is]&&is){
        return YES;
    }
    return NO;
}

+(BOOL)removeFileAtPaht:(NSString*)filePath{
    NSFileManager* manager = [NSFileManager defaultManager];
    if ([manager fileExistsAtPath:filePath]){
        NSError *err=nil;
        [manager removeItemAtPath:filePath error:&err];
        if(err){
            return NO;
        }
    }
    return YES;
}

+(BOOL)renameFileAtPaht:(NSString*)filePath rename:(NSString*)rename{
    NSFileManager* manager = [NSFileManager defaultManager];
    if ([manager fileExistsAtPath:filePath]){
        NSError *err=nil;
        NSString *newPath = [[filePath stringByDeletingLastPathComponent] stringByAppendingPathComponent:rename];
        [manager moveItemAtPath:filePath toPath:newPath error:&err];
        if(err){
            return NO;
        }
    }
    return YES;
}

@end
