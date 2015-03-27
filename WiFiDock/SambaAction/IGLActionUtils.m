//
//  IGLActionUtils.m
//  IGL004
//
//  Created by apple on 2014/05/23.
//  Copyright (c) 2014年 hualu. All rights reserved.
//

#import "IGLActionUtils.h"
#include <sys/param.h>
#include <sys/mount.h>
#import "WFFileUtil.h"
#import "NSDate+Ex.h"
@implementation IGLActionUtils : NSObject
+(BOOL)haveSameName:(IGLActionItem*)item{
    NSString *path = [item.toPath stringByAppendingSMBPathComponent:[item.fromPath lastPathComponent]];
    if([path hasPrefix:SAMBA_URL]){
        return [[IGLSMBProvier sharedSmbProvider] isExistsAtPath:path];
    }
    if([path hasPrefix:[WFFileUtil getDocumentPath]]){
        return [WFFileUtil isExistsAtPath:path];
    }
    return NO;
}
+(BOOL)canPaste:(IGLActionItem*)item{
    if(!item.isFolder){
        return YES;
    }
    if([[item toPath] hasPrefix:[item fromPath]]){
        return NO;
    }
    return YES;
}
+(BOOL)isExistsAtPath:(NSString*)path{
    if([path hasPrefix:SAMBA_URL]){
        return [[IGLSMBProvier sharedSmbProvider] isExistsAtPath:path];
    }
    if([path hasPrefix:[WFFileUtil getDocumentPath]]){
        return [WFFileUtil isExistsAtPath:path];
    }
    return NO;
}
+(BOOL)removeFileAtPath:(NSString*)path{
    if(![self isExistsAtPath:path]){
        return YES;
    }
    if([path hasPrefix:SAMBA_URL]){
        return [[IGLSMBProvier sharedSmbProvider] removeAtPathIsSuccess:path];
    }
    if([path hasPrefix:[WFFileUtil getDocumentPath]]){
        return [WFFileUtil removeFileAtPaht:path];
    }
    return NO;
}
+(BOOL)renameFileAtPaht:(NSString*)path rename:rename{
    if([path hasPrefix:SAMBA_URL]){
        return [[IGLSMBProvier sharedSmbProvider] renameAtPath:path rename:rename];
    }
    if([path hasPrefix:[WFFileUtil getDocumentPath]]){
        return [WFFileUtil renameFileAtPaht:path rename:rename];
    }
    return NO;
}
+ (long long) freeDiskSpaceInBytes{
    struct statfs buf;
    long long freespace = -1;
    if(statfs("/var", &buf) >= 0){
        freespace = (long long)(buf.f_bsize * buf.f_bfree);
    }
    return freespace;
}
+(BOOL)createAtPaht:(NSString*)path{
    if([path hasPrefix:SAMBA_URL]){
        return [[IGLSMBProvier sharedSmbProvider] isSuccessCreateFolderAtPath:path];
    }
    if([path hasPrefix:[WFFileUtil getDocumentPath]]){
        return [WFFileUtil createFolderAtPaht:path];
    }
    return NO;
}
+(NSString*)buildUploadImageName:(NSString*)baseDir{
    return [baseDir stringByAppendingSMBPathComponent:[NSString stringWithFormat:@"%@.jpg",[[NSDate date] stringWithDefaultFormat]]];
}
+(NSString*)buildUploadVideoName:(NSString*)baseDir{
    return [baseDir stringByAppendingSMBPathComponent:[NSString stringWithFormat:@"%@.mov",[[NSDate date] stringWithDefaultFormat]]];
}
@end
