//
//  IGLSMBProvier.h
//  IGL004
//
//  Created by apple on 2014/03/28.
//  Copyright (c) 2014年 hualu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "libsmbclient.h"

#define SAMBA_DEBUG_LEVEL 2

extern NSString * const IGLSMBErrorDomain;

typedef enum {
    IGLSMBErrorUnknown,
    IGLSMBErrorInvalidArg,
    IGLSMBErrorInvalidProtocol,
    IGLSMBErrorOutOfMemory,
    IGLSMBErrorPermissionDenied,
    IGLSMBErrorInvalidPath,
    IGLSMBErrorPathIsNotDir,
    IGLSMBErrorPathIsDir,
    IGLSMBErrorWorkgroupNotFound,
    IGLSMBErrorShareDoesNotExist,
    IGLSMBErrorItemAlreadyExists,
    IGLSMBErrorDirNotEmpty,
    IGLSMBErrorFileIO,
    
} IGLSMBError;

typedef enum {
    
    IGLSMBItemTypeUnknown,
    IGLSMBItemTypeWorkgroup,
    IGLSMBItemTypeServer,
    IGLSMBItemTypeFileShare,
    IGLSMBItemTypePrinter,
    IGLSMBItemTypeComms,
    IGLSMBItemTypeIPC,
    IGLSMBItemTypeDir,
    IGLSMBItemTypeFile,
    IGLSMBItemTypeLink,
    
} IGLSMBItemType;

@class IGLSMBItem;

typedef void (^IGLSMBBlock)(id result);
typedef void (^IGLSMBBlockProgress)(IGLSMBItem *item, unsigned long long transferred);
typedef BOOL (^IGLSMBCancelBlock)();

@interface IGLSMBItemStat : NSObject
@property(readonly, nonatomic, strong) NSDate *createTime;
@property(readonly, nonatomic, strong) NSDate *lastModified;
@property(readonly, nonatomic, strong) NSDate *lastAccess;
@property(readonly, nonatomic, assign) long long size;
@property(readonly, nonatomic, assign) long mode;
@property(readonly, nonatomic, strong)IGLSMBItem *item;
@end

@interface IGLSMBItem : NSObject
- (id) initWithType: (IGLSMBItemType) type
               path: (NSString *) path
               stat: (IGLSMBItemStat *)stat;
@property(readonly, nonatomic, assign) IGLSMBItemType type;
@property(readonly, nonatomic, strong) NSString *path;
@property(readonly, nonatomic, strong) IGLSMBItemStat *stat;
@property(readonly, nonatomic, copy) NSString *name;
@property(readonly, nonatomic, copy) NSString *sortname;
@end

@class IGLSMBItemFile;

@interface IGLSMBItemTree : IGLSMBItem
- (void) fetchItems: (IGLSMBBlock) block;
- (id) fetchItems;
- (void) createFileWithName:(NSString *) name overwrite:(BOOL)overwrite block: (IGLSMBBlock) block;
- (id) createFileWithName:(NSString *) name overwrite:(BOOL)overwrite;
- (void) removeWithName: (NSString *) name block: (IGLSMBBlock) block;
- (id) removeWithName: (NSString *) name;
@end

@interface IGLSMBItemFile : IGLSMBItem

- (void) close;

- (void)readDataOfLength:(NSUInteger)length block:(IGLSMBBlock) block;
- (id)readDataOfLength:(NSUInteger)length;

- (void)readDataToEndOfFile:(IGLSMBBlock) block;
- (id)readDataToEndOfFile;

- (void)seekToFileOffset:(off_t)offset whence:(NSInteger)whence block:(IGLSMBBlock) block;
- (id)seekToFileOffset:(off_t)offset whence:(NSInteger)whence;

- (void)writeData:(NSData *)data block:(IGLSMBBlock) block;
- (id)writeData:(NSData *)data;

@end

@interface IGLSMBAuth : NSObject
@property (readwrite, nonatomic, copy) NSString *workgroup;
@property (readwrite, nonatomic, copy) NSString *username;
@property (readwrite, nonatomic, copy) NSString *password;

+ (id) smbAuthWorkgroup: (NSString *)workgroup
               username: (NSString *)username
               password: (NSString *)password;
@end

@protocol IGLSMBProviderDelegate <NSObject>
- (IGLSMBAuth *) smbAuthForServer: (NSString *) server
                       withShare: (NSString *) share;
@end

@interface IGLSMBProvier : NSObject
@property (nonatomic,assign) BOOL isCanle;
- (id) initOnce;
+ (id) sharedSmbProvider;
+ (void) setSmbProvider:(IGLSMBProvier*)p;
+ (void) clearSmbProvider;
+ (void) restartSmbContext;
+ (SMBCCTX *) openSmbContext;
- (void) dispatchSync: (dispatch_block_t) block;
- (void) dispatchAsync: (dispatch_block_t) block;
- (BOOL) canConnectSamba:(NSString*)sambaPath;
- (void) fetchAtPath: (NSString *) path block: (IGLSMBBlock) block;
- (id) fetchAtPath: (NSString *) path;
- (id) fetchFoldorAtPath: (NSString *) path;
- (BOOL) isExistsAtPath: (NSString *) path;
- (long long) filesizeAtPath: (NSString *) path;
-(BOOL)isSuccessCreateFolderAtPath: (NSString *) path;
- (NSMutableArray*) fetchAllFileAtPath: (NSString *) path;
- (void) fetchAllFileAtPath: (NSString *) path
                      block: (IGLSMBBlock) block;

- (void) fetchAllFileAtPathForSearch: (NSString *) path
                                block: (IGLSMBBlock) block;

- (void) fetchAllFileAtPathForDisplay: (NSString *) path
                                block: (IGLSMBBlock) block;

- (void) createFileAtPath:(NSString *) path overwrite:(BOOL)overwrite block: (IGLSMBBlock) block;
- (id) createFileAtPath:(NSString *) path overwrite:(BOOL)overwrite;
+ (id) createFileAtPath:(NSString *) path overwrite:(BOOL)overwrite;

- (void) createFolderAtPath:(NSString *) path block: (IGLSMBBlock) block;
- (id) createFolderAtPath:(NSString *) path;

- (void) removeAtPath: (NSString *) path block: (IGLSMBBlock) block;
- (id) removeAtPath: (NSString *) path;
-(BOOL) removeAtPathIsSuccess: (NSString *) path;
- (void) copySMBPath:(NSString *)smbPath
           localPath:(NSString *)localPath
           overwrite:(BOOL)overwrite
               block:(IGLSMBBlock)block;

- (void) copyLocalPath:(NSString *)localPath
               smbPath:(NSString *)smbPath
             overwrite:(BOOL)overwrite
                 block:(IGLSMBBlock)block;

- (void) copySMBPath:(NSString *)smbPath
           localPath:(NSString *)localPath
           overwrite:(BOOL)overwrite
            progress:(IGLSMBBlockProgress)progress
               block:(IGLSMBBlock)block
            iscancel:(IGLSMBCancelBlock)iscancel;

- (void) copyLocalPath:(NSString *)localPath
               smbPath:(NSString *)smbPath
             overwrite:(BOOL)overwrite
              progress:(IGLSMBBlockProgress)progress
                 block:(IGLSMBBlock)block
              iscancel:(IGLSMBCancelBlock)iscancel;

- (void) removeFolderAtPath:(NSString *) path
                      block:(IGLSMBBlock)block;

- (void) renameAtPath:(NSString *)oldPath
              newPath:(NSString *)newPath
                block:(IGLSMBBlock)block;
- (BOOL) renameAtPath:(NSString *)path
               rename:(NSString *)rename;
- (void) copySMBPathToSMB:(NSString *)smbPath
                toSmbPath:(NSString *)toSmbPaht
                overwrite:(BOOL)overwrite
                 progress:(IGLSMBBlockProgress)progress
                    block:(IGLSMBBlock)block
                 iscancel:(IGLSMBCancelBlock)iscancel;

- (void) uploadData:(NSData *)data
            smbPath:(NSString *)smbPath
          overwrite:(BOOL)overwrite
              block:(IGLSMBBlock)block;


#pragma add code

- (NSMutableArray *)fetchFileFromDirectory:(NSString *)path fileType:(NSString *)fileType;

- (void) fetchAllFileWithPath: (NSString *) path fileType:(NSString *)fileType useBlock: (IGLSMBBlock) block;
- (BOOL)copySmbItemfrom:(NSString *)from to:(NSString *)to;
-(NSData*)writeFrom:(NSString *)from;
-(id)fetchStatWithPath: (NSString *) path;
- (NSData *)dataWithPath:(NSString *)filePath;


@end

@interface WFstat : NSObject
@property(nonatomic,strong)IGLSMBItemStat *stat;
@property(nonatomic,strong)IGLSMBItem *item;
@end
