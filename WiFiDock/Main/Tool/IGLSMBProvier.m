//
//  IGLSMBProvier.m
//  IGL004
//
//  Created by apple on 2014/03/28.
//  Copyright (c) 2014年 hualu. All rights reserved.
//

#import "IGLSMBProvier.h"
#import "libsmbclient.h"
#include "pinyin.h"
#import "WFFile.h"
#import "WFFileUtil.h"
NSString * const IGLSMBErrorDomain = @"iguor.com.IGLOO4";

static NSString * IGLSMBErrorMessage (IGLSMBError errorCode)
{
    switch (errorCode) {
        case IGLSMBErrorUnknown:             return NSLocalizedString(@"SMB Error", nil);
        case IGLSMBErrorInvalidArg:          return NSLocalizedString(@"SMB Invalid argument", nil);
        case IGLSMBErrorInvalidProtocol:     return NSLocalizedString(@"SMB Invalid protocol", nil);
        case IGLSMBErrorOutOfMemory:         return NSLocalizedString(@"SMB Out of memory", nil);
        case IGLSMBErrorPermissionDenied:    return NSLocalizedString(@"SMB Permission denied", nil);
        case IGLSMBErrorInvalidPath:         return NSLocalizedString(@"SMB No such file or directory", nil);
        case IGLSMBErrorPathIsNotDir:        return NSLocalizedString(@"SMB Not a directory", nil);
        case IGLSMBErrorPathIsDir:           return NSLocalizedString(@"SMB Is a directory", nil);
        case IGLSMBErrorWorkgroupNotFound:   return NSLocalizedString(@"SMB Workgroup not found", nil);
        case IGLSMBErrorShareDoesNotExist:   return NSLocalizedString(@"SMB Share does not exist", nil);
        case IGLSMBErrorItemAlreadyExists:   return NSLocalizedString(@"SMB Item already exists", nil);
        case IGLSMBErrorDirNotEmpty:         return NSLocalizedString(@"SMB Directory not empty", nil);
        case IGLSMBErrorFileIO:              return NSLocalizedString(@"SMB File I/O failure", nil);
    }
}

static NSError * mkIGLSMBError(IGLSMBError error, NSString *format, ...)
{
    NSDictionary *userInfo = nil;
    NSString *reason = nil;
    if (format) {
        va_list args;
        va_start(args, format);
        reason = [[NSString alloc] initWithFormat:format arguments:args];
        va_end(args);
    }
    if (reason) {
        userInfo = @{
                     NSLocalizedDescriptionKey : IGLSMBErrorMessage(error),
                     NSLocalizedFailureReasonErrorKey : reason
                     };
        
    } else {
        userInfo = @{ NSLocalizedDescriptionKey : IGLSMBErrorMessage(error) };
    }
    
    return [NSError errorWithDomain:IGLSMBErrorDomain
                               code:error
                           userInfo:userInfo];
}
static IGLSMBError errnoToSMBErr(int err)
{
    switch (err) {
        case EINVAL:    return IGLSMBErrorInvalidArg;
        case ENOMEM:    return IGLSMBErrorOutOfMemory;
        case EACCES:    return IGLSMBErrorPermissionDenied;
        case ENOENT:    return IGLSMBErrorInvalidPath;
        case ENOTDIR:   return IGLSMBErrorPathIsNotDir;
        case EISDIR:    return IGLSMBErrorPathIsDir;
        case EPERM:     return IGLSMBErrorWorkgroupNotFound;
        case ENODEV:    return IGLSMBErrorShareDoesNotExist;
        case EEXIST:    return IGLSMBErrorItemAlreadyExists;
        case ENOTEMPTY: return IGLSMBErrorDirNotEmpty;
        default:        return IGLSMBErrorUnknown;
    }
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////

@implementation IGLSMBAuth

+ (id) smbAuthWorkgroup: (NSString *)workgroup
               username: (NSString *)username
               password: (NSString *)password
{
    IGLSMBAuth *auth = [[IGLSMBAuth alloc] init];
    auth.workgroup = workgroup;
    auth.username = username;
    auth.password = password;
    return auth;
}

@end

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////

@interface IGLSMBItemStat ()
@property(readwrite, nonatomic, strong) NSDate *createTime;
@property(readwrite, nonatomic, strong) NSDate *lastModified;
@property(readwrite, nonatomic, strong) NSDate *lastAccess;
@property(readwrite, nonatomic, assign) long long size;
@property(readwrite, nonatomic, assign) long mode;
@property(readwrite, nonatomic, assign) BOOL canWrite;
@property(readwrite, nonatomic, assign) BOOL canRead;
@property(readwrite, nonatomic, assign) BOOL isHidden;
@end

@implementation IGLSMBItemStat
@end

@implementation IGLSMBItem

- (id) initWithType: (IGLSMBItemType) type
               path: (NSString *) path
               stat: (IGLSMBItemStat *)stat
{
    self = [super init];
    if (self) {
        _type = type;
        _path = path;
        _stat = stat;
        _name = [path lastPathComponent];
        _sortname = [[NSString stringWithFormat:@"%c",pinyinFirstLetter([_name characterAtIndex:0])] uppercaseString];
    }
    return self;
}

- (NSString *) description
{
    NSString *stype = @"";
    
    switch (_type) {
            
        case IGLSMBItemTypeUnknown:   stype = @"?"; break;
        case IGLSMBItemTypeWorkgroup: stype = @"group"; break;
        case IGLSMBItemTypeServer:    stype = @"server"; break;
        case IGLSMBItemTypeFileShare: stype = @"fileshare"; break;
        case IGLSMBItemTypePrinter:   stype = @"printer"; break;
        case IGLSMBItemTypeComms:     stype = @"comms"; break;
        case IGLSMBItemTypeIPC:       stype = @"ipc"; break;
        case IGLSMBItemTypeDir:       stype = @"dir"; break;
        case IGLSMBItemTypeFile:      stype = @"file"; break;
        case IGLSMBItemTypeLink:      stype = @"link"; break;
    }
    
    return [NSString stringWithFormat:@"<smb %@ '%@' %lld>",
            stype, _path, _stat.size];
}

@end

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////

static void my_smbc_get_auth_data_fn(const char *srv,
                                     const char *shr,
                                     char *workgroup, int wglen,
                                     char *username, int unlen,
                                     char *password, int pwlen);

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////


@interface IGLSMBItemFile()
- (id) createFile:(BOOL)overwrite;
@end

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////

static IGLSMBProvier *gSmbProvider;
static SMBCCTX *gSmbContext;
static dispatch_once_t onceToken;
@interface IGLSMBProvier ()



@end

@implementation IGLSMBProvier {
    dispatch_queue_t    _dispatchQueue;
    
}



#pragma mark - OK
- (id) initOnce
{
    NSAssert(!gSmbProvider, @"singleton object");
    self = [super init];
    if (self) {
        _dispatchQueue  = dispatch_queue_create("IGLSMBProvier", DISPATCH_QUEUE_SERIAL);
    }
    return self;
}
+ (void) clearSmbProvider{
    gSmbProvider = nil;
    if(gSmbContext){
        smbc_free_context(gSmbContext, NO);
        gSmbContext = nil;
    }
    onceToken = 0;
}
#pragma mark - OK
+ (id) sharedSmbProvider
{
    dispatch_once(&onceToken, ^{
        gSmbProvider = [[IGLSMBProvier alloc] initOnce];
        gSmbContext =[IGLSMBProvier openSmbContext];
    });
    return gSmbProvider;
}
#pragma mark - OK
- (void) dealloc
{
    if (_dispatchQueue) {
#if __IPHONE_OS_VERSION_MIN_REQUIRED < 60000
        dispatch_release(_dispatchQueue);
#endif
        _dispatchQueue = NULL;
    }
    if(gSmbContext){
        if (gSmbContext) {
            smbc_getFunctionPurgeCachedServers(gSmbContext)(gSmbContext);
            smbc_free_context(gSmbContext, NO);
        }
        gSmbContext = NULL;
    }
}
#pragma mark - OK
+ (void) restartSmbContext
{
    if(gSmbContext){
        smbc_free_context(gSmbContext, NO);
        gSmbContext = nil;
    }
    gSmbContext = [self openSmbContext];
}
+ (void) setSmbProvider:(IGLSMBProvier*)p{
    gSmbProvider = p;
}
#pragma mark - OK
+ (SMBCCTX *) openSmbContext
{
    if(gSmbContext){
        return gSmbContext;
    }
    SMBCCTX *smbContext = smbc_new_context();
	if (!smbContext)
		return NULL;
    smbc_setDebug(smbContext, 0);
	smbc_setTimeout(smbContext, 5000);
    smbc_setOptionOneSharePerServer(smbContext, false);
    smbc_setFunctionAuthData(smbContext, my_smbc_get_auth_data_fn);
	if (!smbc_init_context(smbContext)) {
		smbc_free_context(smbContext, NO);
		return NULL;
	}
    gSmbContext = smbContext;
    smbc_set_context(gSmbContext);
    return gSmbContext;
}
#pragma mark - OK
- (BOOL) canConnectSamba:(NSString*)sambaPath{
    __block BOOL result = NO;
    dispatch_sync(_dispatchQueue, ^{
        result = [IGLSMBProvier canConnectSamba:sambaPath];
    });
    return result;
}
+ (BOOL) canConnectSamba:(NSString*)sambaPath
{
    SMBCCTX *smbContext = [self openSmbContext];
    if (!smbContext) {
        return NO;
    }
    struct stat st;
    int r = smbc_getFunctionStat(smbContext)(smbContext, [sambaPath UTF8String], &st);
    if (r < 0) {
        return NO;
    }
    return YES;
}
#pragma mark - OK
- (BOOL) isExistsAtPath: (NSString *) path{
    NSParameterAssert(path);
    __block BOOL result = NO;
    dispatch_sync(_dispatchQueue, ^{
        result = [IGLSMBProvier isExistsAtPath: path];
    });
    return result;
}
+ (BOOL) isExistsAtPath: (NSString *) path
{
    NSParameterAssert(path);
    SMBCCTX *smbContext = [self openSmbContext];
    if (!smbContext) {
        return NO;
    }
    struct stat st;
    int r = smbc_getFunctionStat(smbContext)(smbContext, [path UTF8String], &st);
    if (r < 0) {
        return NO;
    }
    return YES;
}
+ (id) fetchTreeAtPath: (NSString *) path
{
    NSParameterAssert(path);
    
    SMBCCTX *smbContext = [self openSmbContext];
    if (!smbContext) {
        const int err = errno;
        return mkIGLSMBError(errnoToSMBErr(err),
                            NSLocalizedString(@"Unable init SMB context (errno:%d)", nil), err);
    }
    
    id result = nil;
    SMBCFILE *smbFile = smbc_getFunctionOpendir(smbContext)(smbContext, path.UTF8String);
    if (smbFile) {
        
        NSMutableArray *ma = [NSMutableArray array];
        IGLSMBItem *item;
        
        struct smbc_dirent *dirent;
        
        smbc_readdir_fn readdirFn = smbc_getFunctionReaddir(smbContext);
        
        while((dirent = readdirFn(smbContext, smbFile)) != NULL) {
            
            if (!dirent->name) continue;
            if (!strlen(dirent->name)) continue;
            if (dirent->name[0] == '.') continue;
            if (!strcmp(dirent->name, "IPC$")) continue;
            
            NSString *name = [NSString stringWithUTF8String:dirent->name];
            
            NSString *itemPath;
            if ([path characterAtIndex:path.length-1] == '/')
                itemPath = [path stringByAppendingString:name] ;
            else
                itemPath = [NSString stringWithFormat:@"%@/%@", path, name];
            
            IGLSMBItemStat *stat = nil;
            
            if (dirent->smbc_type != SMBC_WORKGROUP &&
                dirent->smbc_type != SMBC_SERVER) {
                
                id r = [self fetchStat:smbContext atPath:itemPath];
                if ([r isKindOfClass:[IGLSMBItemStat class]]) {
                    stat = r;
                }
            }
            
            switch(dirent->smbc_type)
            {
                case SMBC_WORKGROUP:
                case SMBC_SERVER:
                    item = [[IGLSMBItemTree alloc] initWithType:dirent->smbc_type
                                                          path:[NSString stringWithFormat:@"smb://%@", name]
                                                          stat:nil];
                    [ma addObject:item];
                    break;
                    
                case SMBC_FILE_SHARE:
                case SMBC_IPC_SHARE:
                case SMBC_DIR:
                    item = [[IGLSMBItemTree alloc] initWithType:dirent->smbc_type
                                                          path:itemPath
                                                          stat:stat];
                    [ma addObject:item];
                    break;
                    
                case SMBC_FILE:
                    item = [[IGLSMBItemFile alloc] initWithType:IGLSMBItemTypeFile
                                                          path:itemPath
                                                          stat:stat];
                    [ma addObject:item];
                    break;
                    
                    
                case SMBC_PRINTER_SHARE:
                case SMBC_COMMS_SHARE:
                case SMBC_LINK:
                    item = [[IGLSMBItem alloc] initWithType:dirent->smbc_type
                                                      path:itemPath
                                                      stat:stat];
                    [ma addObject:item];
                    break;
            }
        }
        
        smbc_getFunctionClose(smbContext)(smbContext, smbFile);
        result = [ma copy];
        
    } else {
        
        const int err = errno;
        result = mkIGLSMBError(errnoToSMBErr(err),
                              NSLocalizedString(@"Unable open dir:%@ (errno:%d)", nil), path, err);
    }
    
    smbc_getFunctionClosedir(smbContext);
    return result;
}

-(id)fetchStatWithPath:(NSString *)path
{
     NSParameterAssert(path);
    
    SMBCCTX *smbContext = [IGLSMBProvier openSmbContext];
    
    WFstat *wstat = [[WFstat alloc]init];
    
    if (!smbContext) {
        const int err = errno;
        return mkIGLSMBError(errnoToSMBErr(err),
                             NSLocalizedString(@"Unable init SMB context (errno:%d)", nil), err);
    }
    
    
    SMBCFILE *smbFile = smbc_getFunctionOpendir(smbContext)(smbContext, path.UTF8String);
    
    if (smbFile) {
 
        IGLSMBItem *item;
        struct smbc_dirent *dirent;
        
        smbc_readdir_fn readdirFn = smbc_getFunctionReaddir(smbContext);
        
        dirent = readdirFn(smbContext, smbFile);
        
        if (dirent) {
            
            NSString *name = [NSString stringWithUTF8String:dirent->name];
            NSString *itemPath;
            if ([path characterAtIndex:path.length-1] == '/')
                itemPath = [path stringByAppendingString:name] ;
            else
                itemPath = [NSString stringWithFormat:@"%@/%@", path, name];
            IGLSMBItemStat *stat = nil;
            
            id r = [IGLSMBProvier fetchStat:smbContext atPath:itemPath];
            
            if ([r isKindOfClass:[IGLSMBItemStat class]]) wstat.stat = r;
            
            switch(dirent->smbc_type){
                    
                case SMBC_WORKGROUP:
                case SMBC_SERVER:
                    item = [[IGLSMBItemTree alloc] initWithType:dirent->smbc_type
                                                           path:[NSString stringWithFormat:@"smb://%@", name]
                                                           stat:nil];
                    break;
                case SMBC_FILE_SHARE:
                case SMBC_IPC_SHARE:
                case SMBC_DIR:
                    wstat.item = [[IGLSMBItemTree alloc] initWithType:dirent->smbc_type
                                                           path:itemPath
                                                           stat:stat];
                    
                    break;
                    
                case SMBC_FILE:
                    wstat.item = [[IGLSMBItemFile alloc] initWithType:IGLSMBItemTypeFile
                                                           path:itemPath
                                                           stat:stat];
                    break;
                    
                    
                case SMBC_PRINTER_SHARE:
                case SMBC_COMMS_SHARE:
                case SMBC_LINK:
                    item = [[IGLSMBItem alloc] initWithType:dirent->smbc_type
                                                       path:itemPath
                                                       stat:stat];
                    break;
            }
            
        }
       
        smbc_getFunctionClose(smbContext)(smbContext, smbFile);
        
    }
    
    smbc_getFunctionClosedir(smbContext);
    
    return wstat;
}




+ (id) fetchStat: (SMBCCTX *) smbContext
          atPath: (NSString *) path
{
    NSParameterAssert(smbContext);
    NSParameterAssert(path);
    
    struct stat st;
    int r = smbc_getFunctionStat(gSmbContext)(gSmbContext, [path UTF8String], &st);
    if (r < 0) {
        
        const int err = errno;
        return mkIGLSMBError(errnoToSMBErr(err),
                            NSLocalizedString(@"Unable get stat:%@ (errno:%d)", nil), path, err);
    }
    
    IGLSMBItemStat *stat = [[IGLSMBItemStat alloc] init];
    stat.lastModified = [NSDate dateWithTimeIntervalSince1970: st.st_mtime];
    stat.createTime = [NSDate dateWithTimeIntervalSince1970: st.st_ctime];
    stat.lastAccess = [NSDate dateWithTimeIntervalSince1970: st.st_atime];
    stat.size = st.st_size;
    stat.mode = st.st_mode;
    return stat;
    
}
+ (id) fetchFStat: (SMBCCTX *) smbContext
             file: (SMBCFILE *) file
{
    NSParameterAssert(smbContext);
    NSParameterAssert(file);
    
    struct stat st;
    int r = smbc_getFunctionFstat(smbContext)(smbContext, file, &st);
    if (r < 0) {
        const int err = errno;
        return mkIGLSMBError(errnoToSMBErr(err),
                            NSLocalizedString(@"Unable get stat:%@ (errno:%d)", nil), @"", err);
    }
    IGLSMBItemStat *stat = [[IGLSMBItemStat alloc] init];
    stat.lastModified = [NSDate dateWithTimeIntervalSince1970: st.st_mtime];
    stat.createTime = [NSDate dateWithTimeIntervalSince1970: st.st_ctime];
    stat.lastAccess = [NSDate dateWithTimeIntervalSince1970: st.st_atime];
    stat.size = st.st_size;
    stat.mode = st.st_mode;
    return stat;
    
}

+ (NSMutableArray *) fetchAllFileAtPathForDownload: (NSString *) path
{
    
    NSParameterAssert(path);
    NSMutableArray *items = [NSMutableArray array];
    SMBCCTX *smbContext = [self openSmbContext];
    if (!smbContext) {
        return items;
    }
    id result = [self fetchStat:smbContext atPath:path];
    if ([result isKindOfClass:[IGLSMBItemStat class]]) {
        IGLSMBItemStat *stat = result;
        if (S_ISDIR(stat.mode)) {
            IGLSMBItemTree * itemF = [[IGLSMBItemTree alloc] initWithType:IGLSMBItemTypeDir
                                                                     path:path
                                                                     stat:stat];
            [items addObject:itemF];
            result =  [self fetchTreeAtPath:path];
            if([result isKindOfClass:[NSArray class]]){
                for (IGLSMBItem *item in result) {
                    [items addObjectsFromArray:[self fetchAllFileAtPath:item.path]];
                }
            }
        } else if (S_ISREG(stat.mode)) {
            IGLSMBItemFile * item = [[IGLSMBItemFile alloc] initWithType:IGLSMBItemTypeFile
                                                                    path:path
                                                                    stat:stat];
            [items addObject:item];
        } else {
        }
    }
    return items;
}

+ (NSMutableArray *) fetchAllFileAtPath: (NSString *) path
{

    NSParameterAssert(path);
    NSMutableArray *items = [NSMutableArray array];
    /*??
    if([[IGLSMBProvier sharedSmbProvider] isCanle]){
        return items;
    }*/
    
    SMBCCTX *smbContext = [self openSmbContext];
    if (!smbContext) {
        return items;
    }
    id result = [self fetchStat:smbContext atPath:path];
    if ([result isKindOfClass:[IGLSMBItemStat class]]) {
        IGLSMBItemStat *stat = result;
        if (S_ISDIR(stat.mode)) {
            IGLSMBItemTree * itemF = [[IGLSMBItemTree alloc] initWithType:IGLSMBItemTypeDir
                                                                   path:path
                                                                   stat:stat];
            [items addObject:itemF];
            result =  [self fetchTreeAtPath:path];
            if([result isKindOfClass:[NSArray class]]){
                for (IGLSMBItem *item in result) {
                    [items addObjectsFromArray:[self fetchAllFileAtPath:item.path]];
                }
            }
        } else if (S_ISREG(stat.mode)) {
            IGLSMBItemFile * item = [[IGLSMBItemFile alloc] initWithType:IGLSMBItemTypeFile
                                                                  path:path
                                                                  stat:stat];
            [items addObject:item];
        } else {
        }
    }
    return items;
}
+ (id) fetchAtPath: (NSString *) path
{
    NSParameterAssert(path);
    
    if (![path hasPrefix:@"smb://"]) {
        return mkIGLSMBError(IGLSMBErrorInvalidProtocol,
                            NSLocalizedString(@"Path:%@", nil), path);
    }
    
    NSString *sPath = [path substringFromIndex:@"smb://".length];
    
    if (!sPath.length)
        return [self fetchTreeAtPath:path];
    
    if ([sPath hasSuffix:@"/"])
        sPath = [sPath substringToIndex:sPath.length - 1];
    
    if (sPath.pathComponents.count == 1) {
        
        // smb:// or smb://server/ or smb://workgroup/
        return [self fetchTreeAtPath:path];
    }
    
    id result = nil;
    
    SMBCCTX *smbContext = [self openSmbContext];
    if (!smbContext) {
        const int err = errno;
        return mkIGLSMBError(errnoToSMBErr(err),
                            NSLocalizedString(@"Unable init SMB context (errno:%d)", nil), err);
    }
    
    result = [self fetchStat:smbContext atPath:path];
    
    if ([result isKindOfClass:[IGLSMBItemStat class]]) {
        
        IGLSMBItemStat *stat = result;
        
        if (S_ISDIR(stat.mode)) {
            
            result =  [self fetchTreeAtPath:path];
            
        } else if (S_ISREG(stat.mode)) {
            
            result = [[IGLSMBItemFile alloc] initWithType:IGLSMBItemTypeFile
                                                    path:path
                                                    stat:stat];
            
        } else {
            
            result = [[IGLSMBItem alloc] initWithType:S_ISLNK(stat.mode) ? IGLSMBItemTypeLink : IGLSMBItemTypeUnknown
                                                path:path
                                                stat:stat];
        }
    }
    return result;
}
+ (id) fetchAtFile: (NSString *) filepath
{
    NSParameterAssert(filepath);
    
    if (![filepath hasPrefix:@"smb://"]) {
        return mkIGLSMBError(IGLSMBErrorInvalidProtocol,
                            NSLocalizedString(@"Path:%@", nil), filepath);
    }
    SMBCCTX *smbContext = [self openSmbContext];
    if (!smbContext) {
        const int err = errno;
        return mkIGLSMBError(errnoToSMBErr(err),
                            NSLocalizedString(@"Unable init SMB context (errno:%d)", nil), err);
    }
    
    SMBCFILE *_file = smbc_getFunctionOpen(smbContext)(smbContext,
                                                       filepath.UTF8String,
                                                       O_RDONLY,
                                                       0);
    
    if (!_file) {
        const int err = errno;
        return mkIGLSMBError(errnoToSMBErr(err),
                            NSLocalizedString(@"Unable open file:%@ (errno:%d)", nil), filepath, err);
    }
    id result = nil;
    result = [self fetchFStat:smbContext file:_file];
    
    if ([result isKindOfClass:[IGLSMBItemStat class]]) {
        
        IGLSMBItemStat *stat = result;
        if (S_ISREG(stat.mode)) {
            return [[IGLSMBItemFile alloc] initWithType:IGLSMBItemTypeFile
                                                  path:filepath
                                                  stat:stat];
            
        } else {
            const int err = errno;
            return mkIGLSMBError(errnoToSMBErr(err),
                                NSLocalizedString(@"Unable open file:%@ (errno:%d)", nil), filepath, err);
        }
    }
    return nil;
}

+ (id) removeAtPath: (NSString *) path
{
    NSParameterAssert(path);
    
    if (![path hasPrefix:@"smb://"]) {
        return mkIGLSMBError(IGLSMBErrorInvalidProtocol,
                            NSLocalizedString(@"Path:%@", nil), path);
    }
    
    SMBCCTX *smbContext = [self openSmbContext];
    if (!smbContext) {
        const int err = errno;
        return mkIGLSMBError(errnoToSMBErr(err),
                            NSLocalizedString(@"Unable init SMB context (errno:%d)", nil), err);
    }
    
    id result;
    
    int r = smbc_getFunctionUnlink(smbContext)(smbContext, path.UTF8String);
    if (r < 0) {
        
        int err = errno;
        if (err == EISDIR) {
            
            r = smbc_getFunctionRmdir(smbContext)(smbContext, path.UTF8String);
            if (r < 0) {
                
                err = errno;
                result =  mkIGLSMBError(errnoToSMBErr(err),
                                       NSLocalizedString(@"Unable rmdir file:%@ (errno:%d)", nil), path, err);
            }
            
        } else {
            
            result =  mkIGLSMBError(errnoToSMBErr(err),
                                   NSLocalizedString(@"Unable unlink file:%@ (errno:%d)", nil), path, err);
            
        }
        
    }
    return result;
}
#pragma mark - OK
-(BOOL)isSuccessCreateFolderAtPath: (NSString *) path{
    NSParameterAssert(path);
    __block BOOL result = NO;
    dispatch_sync(_dispatchQueue, ^{
        result = [IGLSMBProvier isSuccessCreateFolderAtPath: path];
    });
    return result;
}
+(BOOL)isSuccessCreateFolderAtPath: (NSString *) path
{
    id result = [IGLSMBProvier createFolderAtPath:path];
    if([result isKindOfClass:[NSError class]]){
        return NO;
    }else{
        return YES;
    }
}
+ (id) createFolderAtPath: (NSString *) path
{
    NSParameterAssert(path);
    
    if (![path hasPrefix:@"smb://"]) {
        return mkIGLSMBError(IGLSMBErrorInvalidProtocol,
                            NSLocalizedString(@"Path:%@", nil), path);
    }
    
    SMBCCTX *smbContext = [self openSmbContext];
    if (!smbContext) {
        const int err = errno;
        return mkIGLSMBError(errnoToSMBErr(err),
                            NSLocalizedString(@"Unable init SMB context (errno:%d)", nil), err);
    }
    
    id result;
    
    int r = smbc_getFunctionMkdir(smbContext)(smbContext, path.UTF8String, 0);
    if (r < 0) {
        
        const int err = errno;
        result =  mkIGLSMBError(errnoToSMBErr(err),
                               NSLocalizedString(@"Unable mkdir:%@ (errno:%d)", nil), path, err);
        
    } else {
        
        id stat = [self fetchStat:smbContext atPath: path];
        if ([stat isKindOfClass:[IGLSMBItemStat class]]) {
            
            result = [[IGLSMBItemTree alloc] initWithType:IGLSMBItemTypeDir
                                                    path:path
                                                    stat:stat];
            
        } else {
            
            result = stat;
        }
    }
    return result;
}
+ (id) createFileAtPath:(NSString *) path overwrite:(BOOL)overwrite
{
    NSParameterAssert(path);
    
    if (![path hasPrefix:@"smb://"]) {
        return mkIGLSMBError(IGLSMBErrorInvalidProtocol,
                            NSLocalizedString(@"Path:%@", nil), path);
    }
    
    IGLSMBItemFile *itemFile =  [[IGLSMBItemFile alloc] initWithType:IGLSMBItemTypeFile
                                                              path:path
                                                              stat:nil];
    id result = [itemFile createFile:overwrite];
    if ([result isKindOfClass:[NSError class]]) {
        return result;
    }
    return itemFile;
}
+ (NSError *) ensureLocalFolderExists:(NSString *)folderPath{
    NSFileManager *fm = [[NSFileManager alloc] init];
    BOOL isDir;
    if ([fm fileExistsAtPath:folderPath isDirectory:&isDir]) {
        
        if (!isDir) {
            
            return mkIGLSMBError(IGLSMBErrorFileIO,
                                NSLocalizedString(@"Cannot overwrite file %@", nil),
                                folderPath);
        }
        
    } else {
        
        NSError *error;
        if (![fm createDirectoryAtPath:folderPath
           withIntermediateDirectories:NO
                            attributes:nil
                                 error:&error]) {
            
            return error;
            
        }
    }
    return nil;
}

+ (NSFileHandle *) createLocalFile:(NSString *)path
                         overwrite:(BOOL) overwrite
                             error:(NSError **)outError{
    NSFileManager *fm = [[NSFileManager alloc] init];
    
    if ([fm fileExistsAtPath:path]) {
        
        if (overwrite) {
            
            if (![fm removeItemAtPath:path error:outError]) {
                return nil;
            }
            
        } else {
            
            return nil;
        }
    }
    
    NSString *folder = path.stringByDeletingLastPathComponent;
    
    if (![fm fileExistsAtPath:folder] &&
        ![fm createDirectoryAtPath:folder
       withIntermediateDirectories:YES
                        attributes:nil
                             error:outError]) {
            return nil;
        }
    
    if (![fm createFileAtPath:path
                     contents:nil
                   attributes:nil]) {
        
        if (outError) {
            *outError = mkIGLSMBError(IGLSMBErrorFileIO,
                                     NSLocalizedString(@"Unable create file", nil),
                                     path.lastPathComponent);
        }
        return nil;
    }
    
    return [NSFileHandle fileHandleForWritingToURL:[NSURL fileURLWithPath:path]
                                             error:outError];
}
+ (void) readSMBFile:(IGLSMBItemFile *)smbFile
          fileHandle:(NSFileHandle *)fileHandle
            progress:(IGLSMBBlockProgress)progress
               block:(IGLSMBBlock)block
            iscancel:(IGLSMBCancelBlock)iscancel
{
    if(iscancel()){
        [smbFile close];
        [fileHandle closeFile];
        block(@(YES));
        return;
    }
    [smbFile readDataOfLength:COPY_BUFFER_SIZE_SUB*COPY_BUFFER_SIZE_SUB
                        block:^(id result)
     {
         if ([result isKindOfClass:[NSData class]]) {
             
             NSData *data = result;
             if (data.length) {
                 
                 [fileHandle writeData:data];
                 
                 if (progress) {
                     progress(smbFile, data.length);
                 }
                 
                 [self readSMBFile:smbFile
                        fileHandle:fileHandle
                          progress:progress
                             block:block iscancel:iscancel];
                 
             } else {
                 
                 [fileHandle closeFile];
                 [smbFile close];
                 block(@(YES)); // complete
             }
             
             return;
         }
         [fileHandle closeFile];
         block([result isKindOfClass:[NSError class]] ? result : nil);
     }];
    
}

//- (void) readSMBFileFromSMBFile:(IGLSMBItemFile *)smbFile
//                       smbFile2:(IGLSMBItemFile *)smbFile2
//                       progress:(IGLSMBBlockProgress)progress
//                          block:(IGLSMBBlock)block
//                       iscancel:(IGLSMBCancelBlock)iscancel{
//    dispatch_sync(_dispatchQueue, ^{
//        [IGLSMBProvier readSMBFileFromSMBFile:smbFile smbFile2:smbFile2 progress:^(IGLSMBItem *item, long transferred) {
//            dispatch_async(dispatch_get_main_queue(), ^{
//                progress(item,transferred);
//            });
//        } block:^(id result) {
//            dispatch_async(dispatch_get_main_queue(), ^{
//                block(result);
//            });
//        } iscancel:^BOOL{
//            return iscancel();
//        }];
//    });
//}
+ (void) readSMBFileFromSMBFile:(IGLSMBItemFile *)smbFile
                       smbFile2:(IGLSMBItemFile *)smbFile2
                       progress:(IGLSMBBlockProgress)progress
                          block:(IGLSMBBlock)block
                       iscancel:(IGLSMBCancelBlock)iscancel
{
    if(iscancel()){
        [smbFile close];
        [smbFile2 close];
        block(@(YES));
        return;
    }
    [smbFile readDataOfLength:COPY_BUFFER_SIZE_SUB*COPY_BUFFER_SIZE_SUB
                        block:^(id result)
     {
         if ([result isKindOfClass:[NSData class]]) {
             NSData *data = result;
             if (data.length) {
                 
                 id result2 = [smbFile2 writeData:result];
                 if([result2 isKindOfClass:[NSError class]]){
                     block(@(NO));
                 }else{
                     if (progress) {
                         progress(smbFile, [data length]);
                     }
                     [self readSMBFileFromSMBFile:smbFile
                                         smbFile2:smbFile2
                                         progress:progress
                                            block:block iscancel:iscancel];
                 }
             }else{
                 block(@(YES));
             }
         }else{
             block([result isKindOfClass:[NSError class]] ? result : nil);
         }
     }];
    
}

//- (void) copySMBFile:(IGLSMBItemFile *)smbFile
//           localPath:(NSString *)localPath
//           overwrite:(BOOL)overwrite
//            progress:(IGLSMBBlockProgress)progress
//               block:(IGLSMBBlock)block
//            iscancel:(IGLSMBCancelBlock)iscancel{
//    dispatch_sync(_dispatchQueue, ^{
//        [IGLSMBProvier copySMBFile:smbFile localPath:localPath overwrite:overwrite progress:^(IGLSMBItem *item, long transferred) {
//            dispatch_async(dispatch_get_main_queue(), ^{
//                progress(item,transferred);
//            });
//        } block:^(id result) {
//            dispatch_async(dispatch_get_main_queue(), ^{
//                block(result);
//            });
//        } iscancel:^BOOL{
//            return iscancel();
//        }];
//    });
//}
+ (void) copySMBFile:(IGLSMBItemFile *)smbFile
           localPath:(NSString *)localPath
           overwrite:(BOOL)overwrite
            progress:(IGLSMBBlockProgress)progress
               block:(IGLSMBBlock)block
            iscancel:(IGLSMBCancelBlock)iscancel
{
    if(iscancel()){
        [smbFile close];
        block(@(YES));
        return;
    }
    NSError *error = nil;
    NSFileHandle *fileHandle = [self createLocalFile:localPath overwrite:overwrite error:&error];
    if (fileHandle) {
        
        [self readSMBFile:smbFile
               fileHandle:fileHandle
                 progress:progress
                    block:block iscancel:iscancel];
        
    } else {
        
        if (!error) {
            
            error = mkIGLSMBError(IGLSMBErrorFileIO,
                                 NSLocalizedString(@"Cannot overwrite file %@", nil),
                                 localPath.lastPathComponent);
        }
        
        block(error);
    }
}
//- (void) copySMBFileToSMB:(IGLSMBItemFile *)smbFile
//                toSMBpath:(NSString *)toSMBpath
//                overwrite:(BOOL)overwrite
//                 progress:(IGLSMBBlockProgress)progress
//                    block:(IGLSMBBlock)block
//                 iscancel:(IGLSMBCancelBlock)iscancel{
//    dispatch_sync(_dispatchQueue, ^{
//        [IGLSMBProvier copySMBFileToSMB:smbFile toSMBpath:toSMBpath overwrite:overwrite progress:^(IGLSMBItem *item, long transferred) {
//            dispatch_async(dispatch_get_main_queue(), ^{
//                progress(item,transferred);
//            });
//        } block:^(id result) {
//            dispatch_async(dispatch_get_main_queue(), ^{
//                block(result);
//            });
//        } iscancel:^BOOL{
//            return iscancel();
//        }];
//    });
//}
+ (void) copySMBFileToSMB:(IGLSMBItemFile *)smbFile
                toSMBpath:(NSString *)toSMBpath
                overwrite:(BOOL)overwrite
                 progress:(IGLSMBBlockProgress)progress
                    block:(IGLSMBBlock)block
                 iscancel:(IGLSMBCancelBlock)iscancel
{
    NSError *error = nil;
    id result= [self createFileAtPath:toSMBpath overwrite:YES];
    if (![result isKindOfClass:[NSError class]]) {
        [self readSMBFileFromSMBFile:smbFile
                            smbFile2:result
                            progress:progress
                               block:block iscancel:iscancel];
    } else {
        if (!error) {
            error = result;
        }
        
        block(error);
    }
}
//- (void) enumerateSMBFolders:(NSArray *)folders
//                       items:(NSMutableArray *)items
//                       block:(IGLSMBBlock)block{
//    dispatch_sync(_dispatchQueue, ^{
//        [IGLSMBProvier enumerateSMBFolders:folders items:items block:^(id result) {
//            dispatch_async(dispatch_get_main_queue(), ^{
//                block(result);
//            });
//
//        }];
//    });
//}
+ (void) enumerateSMBFolders:(NSArray *)folders
                       items:(NSMutableArray *)items
                       block:(IGLSMBBlock)block
{
    IGLSMBItemTree *folder = folders[0];
    NSMutableArray *mfolders = [folders mutableCopy];
    [mfolders removeObjectAtIndex:0];
    
    [folder fetchItems:^(id result)
     {
         if ([result isKindOfClass:[NSArray class]]) {
             
             for (IGLSMBItem *item in result ) {
                 
                 if ([item isKindOfClass:[IGLSMBItemFile class]]) {
                     
                     [items addObject:item];
                     
                 } else if ([item isKindOfClass:[IGLSMBItemTree class]] &&
                            (item.type == IGLSMBItemTypeDir ||
                             item.type == IGLSMBItemTypeFileShare ||
                             item.type == IGLSMBItemTypeServer))
                 {
                     [mfolders addObject:item];
                     [items addObject:item];
                 }
             }
             
             if (mfolders.count) {
                 
                 [self enumerateSMBFolders:mfolders items:items block:block];
                 
             } else {
                 
                 block(items);
             }
             
         } else {
             
             block([result isKindOfClass:[NSError class]] ? result : nil);
         }
     }];
}

//- (void) copySMBItems:(NSArray *)smbItems
//            smbFolder:(NSString *)smbFolder
//          localFolder:(NSString *)localFolder
//            overwrite:(BOOL)overwrite
//             progress:(IGLSMBBlockProgress)progress
//                block:(IGLSMBBlock)block
//             iscancel:(IGLSMBCancelBlock)iscancel{
//    dispatch_sync(_dispatchQueue, ^{
//        [IGLSMBProvier copySMBItems:smbItems smbFolder:smbFolder localFolder:localFolder overwrite:overwrite progress:^(IGLSMBItem *item, long transferred) {
//            dispatch_async(dispatch_get_main_queue(), ^{
//                progress(item,transferred);
//            });
//        } block:^(id result) {
//            dispatch_async(dispatch_get_main_queue(), ^{
//                block(result);
//            });
//        } iscancel:^BOOL{
//            return iscancel();
//        }];
//    });
//}

+ (void) copySMBItems:(NSArray *)smbItems
            smbFolder:(NSString *)smbFolder
          localFolder:(NSString *)localFolder
            overwrite:(BOOL)overwrite
             progress:(IGLSMBBlockProgress)progress
                block:(IGLSMBBlock)block
             iscancel:(IGLSMBCancelBlock)iscancel
{
    if(iscancel()){
        block(@(YES));
        return;
    }
    IGLSMBItem *item = smbItems[0];
    if (smbItems.count > 1) {
        smbItems = [smbItems subarrayWithRange:NSMakeRange(1, smbItems.count - 1)];
    } else {
        smbItems = nil;
    }
    
    if ([item isKindOfClass:[IGLSMBItemFile class]]) {
        
        NSString *destPath = localFolder;
        NSString *itemFolder = item.path.stringByDeletingLastPathComponent;
        if (itemFolder.length > smbFolder.length) {
            NSString *relPath = [itemFolder substringFromIndex:smbFolder.length];
            destPath = [destPath stringByAppendingPathComponent:relPath];
        }
        destPath = [destPath stringByAppendingSMBPathComponent:item.path.lastPathComponent];
        
        [self copySMBFile:(IGLSMBItemFile *)item
                localPath:destPath
                overwrite:overwrite
                 progress:progress
                    block:^(id result)
         {
             if ([result isKindOfClass:[NSError class]]) {
                 
                 block(result);
                 
             } else {
                 
                 if (smbItems.count) {
                     
                     [self copySMBItems:smbItems
                              smbFolder:smbFolder
                            localFolder:localFolder
                              overwrite:overwrite
                               progress:progress
                                  block:block iscancel:iscancel];
                     
                 } else {
                     
                     block(@(YES)); // complete
                 }
             }
         } iscancel:iscancel];
        
    } else if ([item isKindOfClass:[IGLSMBItemTree class]]) {
        
        NSString *destPath = localFolder;
        NSString *itemFolder = item.path;
        if (itemFolder.length > smbFolder.length) {
            NSString *relPath = [itemFolder substringFromIndex:smbFolder.length];
            destPath = [destPath stringByAppendingPathComponent:relPath];
        }
        
        NSError *error = [self ensureLocalFolderExists:destPath];
        if (error) {
            block(error);
            return;
        }
        
        if (smbItems.count) {
            
            [self copySMBItems:smbItems
                     smbFolder:smbFolder
                   localFolder:localFolder
                     overwrite:overwrite
                      progress:progress
                         block:block iscancel:iscancel];
            
        } else {
            
            block(@(YES)); // complete
        }
    }
}
- (void) copySMBItems:(NSArray *)smbItems
            smbFolder:(NSString *)smbFolder
              smbPath:(NSString *)smbpath
            overwrite:(BOOL)overwrite
             progress:(IGLSMBBlockProgress)progress
                block:(IGLSMBBlock)block
             iscancel:(IGLSMBCancelBlock)iscancel{
    dispatch_sync(_dispatchQueue, ^{
        [IGLSMBProvier copySMBItems:smbItems smbFolder:smbFolder smbPath:smbpath overwrite:overwrite progress:^(IGLSMBItem *item, unsigned long long transferred) {
            dispatch_async(dispatch_get_main_queue(), ^{
                progress(item,transferred);
            });
        } block:^(id result) {
            dispatch_async(dispatch_get_main_queue(), ^{
                block(result);
            });
        } iscancel:^BOOL{
            return iscancel();
        }];
    });
}
+ (void) copySMBItems:(NSArray *)smbItems
            smbFolder:(NSString *)smbFolder
              smbPath:(NSString *)smbpath
            overwrite:(BOOL)overwrite
             progress:(IGLSMBBlockProgress)progress
                block:(IGLSMBBlock)block
             iscancel:(IGLSMBCancelBlock)iscancel
{
    if (iscancel()) {
        block(@(YES));
        return;
    }
    IGLSMBItem *item = smbItems[0];
    if (smbItems.count > 1) {
        smbItems = [smbItems subarrayWithRange:NSMakeRange(1, smbItems.count - 1)];
    } else {
        smbItems = nil;
    }
    
    if ([item isKindOfClass:[IGLSMBItemFile class]]) {
        
        NSString *destPath = smbpath;
        NSString *itemFolder = [item.path stringByDeletingSMBLastPathComponent];
        if (itemFolder.length > smbFolder.length) {
            NSString *relPath = [itemFolder substringFromIndex:smbFolder.length];
            destPath = [destPath stringByAppendingSMBPathComponent:relPath];
        }
        destPath = [destPath stringByAppendingSMBPathComponent:item.path.lastPathComponent];
        
        [self copySMBFileToSMB:(IGLSMBItemFile*)item toSMBpath:destPath overwrite:overwrite progress:progress
                         block:^(id result)
         {
             if ([result isKindOfClass:[NSError class]]) {
                 
                 block(result);
                 
             } else {
                 
                 if (smbItems.count) {
                     
                     [self copySMBItems:smbItems
                              smbFolder:smbFolder
                                smbPath:smbpath
                              overwrite:overwrite
                               progress:progress
                                  block:block iscancel:iscancel];
                     
                 } else {
                     
                     block(@(YES)); // complete
                 }
             }
         } iscancel:iscancel];
        
    } else if ([item isKindOfClass:[IGLSMBItemTree class]]) {
        
        NSString *destPath = smbpath;
        NSString *itemFolder = item.path;
        if (itemFolder.length > smbFolder.length) {
            NSString *relPath = [itemFolder substringFromIndex:smbFolder.length];
            destPath = [destPath stringByAppendingSMBPathComponent:relPath];
        }
        BOOL isexist = [self isExistsAtPath:destPath];
        if (!isexist) {
            id r = [self createFolderAtPath:destPath];
            if([r isKindOfClass:[NSError class]]){
                return;
            }
        }
        if (smbItems.count) {
            [self copySMBItems:smbItems
                     smbFolder:smbFolder
                       smbPath:smbpath
                     overwrite:overwrite
                      progress:progress
                         block:block iscancel:iscancel];
            
        } else {
            block(@(YES)); // complete
        }
    }
}

///

//- (void) writeSMBFile:(IGLSMBItemFile *)smbFile
//           fileHandle:(NSFileHandle *)fileHandle
//             progress:(IGLSMBBlockProgress)progress
//                block:(IGLSMBBlock)block
//             iscancel:(IGLSMBCancelBlock)iscancel{
//    dispatch_sync(_dispatchQueue, ^{
//        [IGLSMBProvier writeSMBFile:smbFile fileHandle:fileHandle progress:^(IGLSMBItem *item, long transferred) {
//            dispatch_async(dispatch_get_main_queue(), ^{
//                progress(item,transferred);
//            });
//        } block:^(id result) {
//            dispatch_async(dispatch_get_main_queue(), ^{
//                block(result);
//            });
//        } iscancel:^BOOL{
//            return iscancel();
//        }];
//    });
//}

+ (void) writeSMBFile:(IGLSMBItemFile *)smbFile
           fileHandle:(NSFileHandle *)fileHandle
             progress:(IGLSMBBlockProgress)progress
                block:(IGLSMBBlock)block
             iscancel:(IGLSMBCancelBlock)iscancel
{
    NSData *data;
    
    if(iscancel()){
        [smbFile close];
        block(mkIGLSMBError(IGLSMBErrorUnknown, @"CANCELED"));
        return;
    }
    @try {
        
        data = [fileHandle readDataOfLength:COPY_BUFFER_SIZE*COPY_BUFFER_SIZE];
    }
    @catch (NSException *exception) {
        
        [fileHandle closeFile];
        block(mkIGLSMBError(IGLSMBErrorFileIO, [exception description]));
        return;
    }
    
    if (data.length) {
        
        [smbFile writeData:data block:^(id result) {
            
            if ([result isKindOfClass:[NSNumber class]]) {
                
                if (progress) {
                    progress(smbFile, fileHandle.offsetInFile);
                }
                
                [self  writeSMBFile:smbFile
                         fileHandle:fileHandle
                           progress:progress
                              block:block iscancel:iscancel];
                
                return;
            }
            
            block([result isKindOfClass:[NSError class]] ? result : nil);
        }];
        
    } else {
        
        [fileHandle closeFile];
        [smbFile close];
        block(smbFile);
    }
}
- (void) copyLocalFile:(NSString *)localPath
               smbPath:(NSString *)smbPath
             overwrite:(BOOL)overwrite
              progress:(IGLSMBBlockProgress)progress
                 block:(IGLSMBBlock)block
              iscancel:(IGLSMBCancelBlock)iscancel{
    dispatch_sync(_dispatchQueue, ^{
        [IGLSMBProvier copyLocalFile:localPath smbPath:smbPath overwrite:overwrite progress:^(IGLSMBItem *item, unsigned long long transferred) {
            dispatch_async(dispatch_get_main_queue(), ^{
                progress(item,transferred);
            });
        } block:^(id result) {
            dispatch_async(dispatch_get_main_queue(), ^{
                block(result);
            });
        } iscancel:^BOOL{
            return iscancel();
        }];
    });
}
+ (void) copyLocalFile:(NSString *)localPath
               smbPath:(NSString *)smbPath
             overwrite:(BOOL)overwrite
              progress:(IGLSMBBlockProgress)progress
                 block:(IGLSMBBlock)block
              iscancel:(IGLSMBCancelBlock)iscancel
{
    if(iscancel()){
        block(mkIGLSMBError(IGLSMBErrorUnknown, @"CANCELED"));
        return;
    }
    IGLSMBProvier *provider = [IGLSMBProvier sharedSmbProvider];
    [provider createFileAtPath:smbPath
                     overwrite:overwrite
                         block:^(id result)
     {
         if ([result isKindOfClass:[IGLSMBItemFile class]]) {
             
             NSError *error = nil;
             NSFileHandle *fileHandle;
             NSURL *url =[NSURL fileURLWithPath:localPath];
             fileHandle = [NSFileHandle fileHandleForReadingFromURL:url error:&error];
             
             if (fileHandle) {
                 
                 [self writeSMBFile:result
                         fileHandle:fileHandle
                           progress:progress
                              block:block iscancel:iscancel];
                 
             } else {
                 
                 block(error);
             }
             
         } else {
             
             block([result isKindOfClass:[NSError class]] ? result : nil);
         }
     }];
}
#pragma mark - OK
- (void) uploadData:(NSData *)data
            smbPath:(NSString *)smbPath
          overwrite:(BOOL)overwrite
              block:(IGLSMBBlock)block{
    //dispatch_sync(_dispatchQueue, ^{
        [IGLSMBProvier uploadData:data smbPath:smbPath overwrite:overwrite block:^(id result) {
            dispatch_async(dispatch_get_main_queue(), ^{
                block(result);
            });
        }];
    //});
}
+ (void) uploadData:(NSData *)data
            smbPath:(NSString *)smbPath
          overwrite:(BOOL)overwrite
              block:(IGLSMBBlock)block
{
    IGLSMBProvier *provider = [IGLSMBProvier sharedSmbProvider];
    [provider createFileAtPath:smbPath
                     overwrite:overwrite
                         block:^(id result)
     {
         if ([result isKindOfClass:[IGLSMBItemFile class]]) {
             
             IGLSMBItemFile *smbFile = result;
             if (data.length) {
                 [smbFile writeData:data block:^(id result) {
                     if ([result isKindOfClass:[NSNumber class]]) {
                         block(smbFile);
                         return;
                     }
                     block([result isKindOfClass:[NSError class]] ? result : nil);
                 }];
             }
         } else {
             
             block([result isKindOfClass:[NSError class]] ? result : nil);
         }
     }];
}
//- (void) copyLocalFiles:(NSDirectoryEnumerator *)enumerator
//            localFolder:(NSString *)localFolder
//              smbFolder:(IGLSMBItemTree *)smbFolder
//              overwrite:(BOOL)overwrite
//               progress:(IGLSMBBlockProgress)progress
//                  block:(IGLSMBBlock)block
//               iscancel:(IGLSMBCancelBlock)iscancel{
//    dispatch_sync(_dispatchQueue, ^{
//        [IGLSMBProvier copyLocalFiles:enumerator localFolder:localFolder smbFolder:smbFolder overwrite:overwrite progress:^(IGLSMBItem *item, long transferred) {
//            dispatch_async(dispatch_get_main_queue(), ^{
//                progress(item,transferred);
//            });
//        } block:^(id result) {
//            dispatch_async(dispatch_get_main_queue(), ^{
//                block(result);
//            });
//        } iscancel:^BOOL{
//            return iscancel();
//        }];
//    });
//}
+ (void) copyLocalFiles:(NSDirectoryEnumerator *)enumerator
            localFolder:(NSString *)localFolder
              smbFolder:(IGLSMBItemTree *)smbFolder
              overwrite:(BOOL)overwrite
               progress:(IGLSMBBlockProgress)progress
                  block:(IGLSMBBlock)block
               iscancel:(IGLSMBCancelBlock)iscancel
{
    if(iscancel()){
        block(mkIGLSMBError(IGLSMBErrorUnknown, @"CANCELED"));
        return;
    }
    NSString *path = [enumerator nextObject];
    if (path) {
        
        if (path.length && [path characterAtIndex:0] != '.') {
            
            NSDictionary *attr = [enumerator fileAttributes];
            if ([[attr fileType] isEqualToString:NSFileTypeDirectory]) {
                
                IGLSMBProvier *provider = [IGLSMBProvier sharedSmbProvider];
                [provider createFolderAtPath:[smbFolder.path stringByAppendingSMBPathComponent:path]
                                       block:^(id result)
                 {
                     if ([result isKindOfClass:[NSError class]]) {
                         
                         block(result);
                         
                     } else {
                         
                         [self copyLocalFiles:enumerator
                                  localFolder:localFolder
                                    smbFolder:smbFolder
                                    overwrite:overwrite
                                     progress:progress
                                        block:block iscancel:iscancel];
                     }
                 }];
                
                return;
                
            } else if ([[attr fileType] isEqualToString:NSFileTypeRegular]) {
                
                NSString *destFolder = smbFolder.path;
                NSString *fileFolder = path.stringByDeletingLastPathComponent;
                if (fileFolder.length)
                    destFolder = [destFolder stringByAppendingSMBPathComponent:fileFolder];
                
                [self copyLocalFile:[localFolder stringByAppendingPathComponent:path]
                            smbPath:[destFolder stringByAppendingSMBPathComponent:path.lastPathComponent]
                          overwrite:overwrite
                           progress:progress
                              block:^(id result)
                 {
                     if ([result isKindOfClass:[NSError class]]) {
                         
                         block(result);
                         
                     } else {
                         
                         [self copyLocalFiles:enumerator
                                  localFolder:localFolder
                                    smbFolder:smbFolder
                                    overwrite:overwrite
                                     progress:progress
                                        block:block iscancel:iscancel];
                     }
                 } iscancel:iscancel];
                
                return;
            }
        }
        
        [self copyLocalFiles:enumerator
                 localFolder:localFolder
                   smbFolder:smbFolder
                   overwrite:overwrite
                    progress:progress
                       block:block iscancel:iscancel];
        
    } else {
        
        block(smbFolder);
    }
}

///
//- (void) removeSMBItems:(NSArray *)smbItems
//                  block:(IGLSMBBlock)block{
//    dispatch_sync(_dispatchQueue, ^{
//        [IGLSMBProvier removeSMBItems:smbItems block:^(id result) {
//            dispatch_async(dispatch_get_main_queue(), ^{
//                block(result);
//            });
//        }];
//    });
//}
+ (void) removeSMBItems:(NSArray *)smbItems
                  block:(IGLSMBBlock)block
{
    IGLSMBItem *item = smbItems[0];
    if (smbItems.count > 1) {
        smbItems = [smbItems subarrayWithRange:NSMakeRange(1, smbItems.count - 1)];
    } else {
        smbItems = nil;
    }
    
    IGLSMBProvier *provider = [IGLSMBProvier sharedSmbProvider];
    [provider removeAtPath:item.path block:^(id result) {
        
        if ([result isKindOfClass:[NSError class]]) {
            
            block(result);
            
        } else if (smbItems.count) {
            
            [self removeSMBItems:smbItems block:block];
            
        } else {
            
            block(@(YES));
        }
    }];
}
//- (id) renameAtPath:(NSString *)oldPath
//            newPath:(NSString *)newPath{
//    __block id result;
//    dispatch_sync(_dispatchQueue, ^{
//        result = [IGLSMBProvier renameAtPath:oldPath newPath:newPath];
//    });
//    return result;
//}
+ (id) renameAtPath:(NSString *)oldPath
            newPath:(NSString *)newPath
{
    NSParameterAssert(oldPath);
    NSParameterAssert(newPath);
    
    if (![oldPath hasPrefix:@"smb://"]) {
        return mkIGLSMBError(IGLSMBErrorInvalidProtocol,
                            NSLocalizedString(@"Path:%@", nil), oldPath);
    }
    
    if (![newPath hasPrefix:@"smb://"]) {
        return mkIGLSMBError(IGLSMBErrorInvalidProtocol,
                            NSLocalizedString(@"Path:%@", nil), newPath);
    }
    
    SMBCCTX *smbContext = [self openSmbContext];
    if (!smbContext) {
        const int err = errno;
        return mkIGLSMBError(errnoToSMBErr(err),
                            NSLocalizedString(@"Unable init SMB context (errno:%d)", nil), err);
    }
    
    id result;
    
    int r = smbc_getFunctionRename(smbContext)(smbContext, oldPath.UTF8String, smbContext, newPath.UTF8String);
    if (r < 0) {
        
        const int err = errno;
        result =  mkIGLSMBError(errnoToSMBErr(err),
                               NSLocalizedString(@"Unable rename file:%@ (errno:%d)", nil), oldPath, err);
        
    } else {
        
        result = [self fetchStat:smbContext atPath: newPath];
        if ([result isKindOfClass:[IGLSMBItemStat class]]) {
            
            IGLSMBItemStat *stat = result;
            
            if (S_ISDIR(stat.mode)) {
                
                result = [[IGLSMBItemTree alloc] initWithType:IGLSMBItemTypeDir path:newPath stat:stat];
                
            } else if (S_ISREG(stat.mode)) {
                
                result = [[IGLSMBItemFile alloc] initWithType:IGLSMBItemTypeFile path:newPath stat:stat];
                
            } else {
                
                result = nil;
            }
        }
    }
    return result;
}
#pragma mark - OK
- (BOOL) renameAtPath:(NSString *)path
               rename:(NSString *)rename{
    NSParameterAssert(path);
    __block BOOL result = NO;
    dispatch_sync(_dispatchQueue, ^{
        result = [IGLSMBProvier renameAtPath:path  rename:rename];
    });
    return result;
}

+ (BOOL) renameAtPath:(NSString *)path
               rename:(NSString *)rename
{
    NSParameterAssert(path);
    NSParameterAssert(rename);
    BOOL result = YES;
    if (![path hasPrefix:@"smb://"]) {
        result = NO;
    }
    
    SMBCCTX *smbContext = [self openSmbContext];
    if (!smbContext) {
        result =  NO;
    }
    int r = smbc_getFunctionRename(smbContext)(smbContext, path.UTF8String, smbContext, [[path stringByDeletingSMBLastPathComponent] stringByAppendingSMBPathComponent:rename].UTF8String);
    if (r < 0) {
        result =  NO;
    }
    return result;
}


#pragma mark - internal methods

- (void) dispatchSync: (dispatch_block_t) block
{
    dispatch_sync(_dispatchQueue, block);
}

- (void) dispatchAsync: (dispatch_block_t) block
{
    dispatch_async(_dispatchQueue, block);
}

#pragma mark - OK
- (void) fetchAtPath: (NSString *) path
               block: (IGLSMBBlock) block
{
    NSParameterAssert(path);
    NSParameterAssert(block);
    
    dispatch_async(_dispatchQueue, ^{
        
        id result = [IGLSMBProvier fetchAtPath: path.length ? path : @"smb://"];
        dispatch_async(dispatch_get_main_queue(), ^{
            block(result);
        });
    });
}
#pragma mark - OK
- (id) fetchAtPath: (NSString *) path
{
    NSParameterAssert(path);
    
    __block id result = nil;
    dispatch_sync(_dispatchQueue, ^{
        
        result = [IGLSMBProvier fetchAtPath: path.length ? path : @"smb://"];
    });
    return result;
}
- (id) fetchFoldorAtPath: (NSString *) path
{
    NSParameterAssert(path);
    
    __block id result = nil;
    dispatch_sync(_dispatchQueue, ^{
        
        result = [IGLSMBProvier fetchFoldorAtPath: path.length ? path : @"smb://"];
    });
    return result;
}

+ (id) fetchFoldorAtPath: (NSString *) path
{
    NSParameterAssert(path);
    NSMutableArray *items = [NSMutableArray array];
    SMBCCTX *smbContext = [self openSmbContext];
    if (!smbContext) {
        return items;
    }
    id  result =  [self fetchTreeAtPath:path];
    if([result isKindOfClass:[NSArray class]]){
        return result;
    }
    return items;
}
#pragma mark - OK
- (NSMutableArray*) fetchAllFileAtPath: (NSString *) path
{
    NSParameterAssert(path);
    
    __block NSMutableArray* result = [NSMutableArray array];
    dispatch_sync(_dispatchQueue, ^{
        result = [IGLSMBProvier fetchAllFileAtPath: path.length ? path : @"smb://"];
    });
    return result;
}

- (void) fetchAllFileAtPathForSearch: (NSString *) path
                               block: (IGLSMBBlock) block
{
    NSParameterAssert(path);
    NSParameterAssert(block);
    
    dispatch_async(_dispatchQueue, ^{
        [IGLSMBProvier fetchAllFileAtPathForSearch: path.length ? path : @"smb://" block:^(id result) {
            if([[IGLSMBProvier sharedSmbProvider] isCanle]){
                return;
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                block(result);
            });
        }];
    });
}

- (void) fetchAllFileAtPathForDisplay: (NSString *) path
               block: (IGLSMBBlock) block
{
    NSParameterAssert(path);
    NSParameterAssert(block);
    
    dispatch_async(_dispatchQueue, ^{
        [IGLSMBProvier fetchAllFileAtPathForDisplay: path.length ? path : @"smb://" block:^(id result) {
            if([[IGLSMBProvier sharedSmbProvider] isCanle]){
                return;
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                block(result);
            });
        }];
    });
}


#pragma mark add code 

- (id) fetchTreeAtPath: (NSString *) path
{
    SMBCCTX *smbContext = [IGLSMBProvier openSmbContext];
    
    if (!smbContext) return nil;
    
    id result = nil;
    
    SMBCFILE *smbFile = smbc_getFunctionOpendir(smbContext)(smbContext, path.UTF8String);
    if (!smbFile) return nil;
    
    NSMutableArray *ma = [NSMutableArray array];
    IGLSMBItem *item;
    
    struct smbc_dirent *dirent;
    
    smbc_readdir_fn readdirFn = smbc_getFunctionReaddir(smbContext);
    
    while((dirent = readdirFn(smbContext, smbFile)) != NULL) {
        
        if (!dirent->name) continue;
        if (!strlen(dirent->name)) continue;
        if (dirent->name[0] == '.') continue;
        if (!strcmp(dirent->name, "IPC$")) continue;
        
        NSString *name = [NSString stringWithUTF8String:dirent->name];
        
        NSString *itemPath;
        if ([path characterAtIndex:path.length-1] == '/')
            itemPath = [path stringByAppendingString:name] ;
        else
            itemPath = [NSString stringWithFormat:@"%@/%@", path, name];
        
        IGLSMBItemStat *stat = [[IGLSMBItemStat alloc]init];
        
        if (dirent->smbc_type != SMBC_WORKGROUP &&
            dirent->smbc_type != SMBC_SERVER) {
            
            id r = [IGLSMBProvier fetchStat:gSmbContext atPath:itemPath];
            
            if ([r isKindOfClass:[IGLSMBItemStat class]])  stat = r;
            
        }
        
        switch(dirent->smbc_type)
        {
            case SMBC_WORKGROUP:
            case SMBC_SERVER:
                item = [[IGLSMBItemTree alloc] initWithType:dirent->smbc_type
                                                       path:[NSString stringWithFormat:@"smb://%@", name]
                                                       stat:nil];
                [ma addObject:item];
                break;
                
            case SMBC_FILE_SHARE:
            case SMBC_IPC_SHARE:
            case SMBC_DIR:
                item = [[IGLSMBItemTree alloc] initWithType:dirent->smbc_type
                                                       path:itemPath
                                                       stat:stat];
                [ma addObject:item];
                break;
                
            case SMBC_FILE:
                item = [[IGLSMBItemFile alloc] initWithType:IGLSMBItemTypeFile
                                                      path:itemPath
                                                      stat:stat];
                [ma addObject:item];
                break;
                
                
            case SMBC_PRINTER_SHARE:
            case SMBC_COMMS_SHARE:
            case SMBC_LINK:
                item = [[IGLSMBItemFile alloc] initWithType:dirent->smbc_type
                                                      path:itemPath
                                                      stat:stat];
                [ma addObject:item];
                break;
        }
    }
    
    smbc_getFunctionClose(smbContext)(smbContext, smbFile);
    smbc_getFunctionClosedir(smbContext);
    result = [ma copy];
    
    return result;
}

- (NSMutableArray *)fetchFileFromDirectory:(NSString *)path fileType:(NSString *)fileType
{
    NSParameterAssert(path);
    IGLSMBProvier *smbTool = [IGLSMBProvier sharedSmbProvider];
    if (!smbTool) return nil;
    SMBCCTX *smbContext = [IGLSMBProvier openSmbContext];
    if (!smbContext) return nil;
    
    id result = [smbTool fetchTreeAtPath:path];
    
    if (!result) return nil;
    
    NSMutableArray *items = [NSMutableArray array];
    for (IGLSMBItem *item in result) {
        WFFile *file = [[WFFile alloc]initWithSmbItem:item fileType:fileType];
        [items addObject:file];
    }
    
    return items;
    
}



- (void) fetchAllFileWithPath: (NSString *) path fileType:(NSString *)fileType useBlock: (IGLSMBBlock) block
{
    NSParameterAssert(path);
    NSParameterAssert(block);
    
    dispatch_group_t group = dispatch_group_create();
    
    //    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    
    dispatch_group_async(group, _dispatchQueue, ^{
        
        [self fetchAllFileWithRootPath: path fileType:fileType block:^(id result) {
            
            if([[IGLSMBProvier sharedSmbProvider] isCanle]){
                return;
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                block(result);
            });
            
        }];
        
        
    });
    
    dispatch_group_notify(group, _dispatchQueue, ^{
        
        dispatch_async(dispatch_get_main_queue(), ^{
            BOOL stop = YES;
            block(@(stop));
        });
        
    });
}

- (void) fetchAllFileWithRootPath: (NSString *) path fileType:(NSString *)fileType block: (IGLSMBBlock) block
{
    NSParameterAssert(path);
    
    if([[IGLSMBProvier sharedSmbProvider] isCanle]){
        
        return;
    }
    
    IGLSMBProvier *smbTool = [IGLSMBProvier sharedSmbProvider];
    
    if (!smbTool) return;
    
    SMBCCTX *smbContext = [IGLSMBProvier openSmbContext];
    if (!smbContext) return;
    
    id result =  [smbTool fetchTreeAtPath:path];
    
    
    if (!result) return;
    
    if ([fileType isEqualToString:@"all"]) {
        
        NSMutableArray *items = [NSMutableArray array];
        
        for (IGLSMBItem *item in result) {
            WFFile *file = [[WFFile alloc]initWithSmbItem:item fileType:fileType];
            [items addObject:file];
        }
        
        block(items);
        
    }else {
        
        NSMutableArray *folders = [NSMutableArray array];
        NSMutableArray *files = [NSMutableArray array];
        
        for (IGLSMBItem *item in result) {
            
            if (item.type == IGLSMBItemTypeFile) {
                NSString *extension = [[item.name pathExtension]lowercaseString];
                
                if ([fileType isEqual:@"photo"]&&[WFFileUtil isImage:extension]) {
                    
                    WFFile *file = [[WFFile alloc]initWithSmbItem:item fileType:fileType];
                    
                    [files addObject:file];
                }else if ([fileType isEqual:@"video"]&&[WFFileUtil isVideo:extension]){
                    WFFile *file = [[WFFile alloc]initWithSmbItem:item fileType:fileType];
                    [files addObject:file];
                }else if ([fileType isEqual:@"music"]&&[WFFileUtil isAudio:extension]){
                    WFFile *file = [[WFFile alloc]initWithSmbItem:item fileType:fileType];
                    [files addObject:file];
                }else if ([fileType isEqual:@"document"]&&[WFFileUtil isDoc:extension]){
                    WFFile *file = [[WFFile alloc]initWithSmbItem:item fileType:fileType];
                    [files addObject:file];
                }
                
                
                
            }else if(item.type == IGLSMBItemTypeDir){
                
                [folders addObject:item];
                //            [self fetchAllFileWithRootPath:item.path block:block];
                
            }
        }
        
        block(files);
        
        
        
        for (IGLSMBItem *item in folders) {
            
            if([[IGLSMBProvier sharedSmbProvider] isCanle]){
                break;
            }
            
            [self fetchAllFileWithRootPath:item.path fileType:fileType block:block];
        }
    }
    
}


- (BOOL)copySmbItemfrom:(NSString *)from to:(NSString *)to
{
    NSFileManager *maneger = [NSFileManager defaultManager];
    
    [maneger createFileAtPath:to contents:nil attributes:nil];
    if (![maneger fileExistsAtPath:to]) return NO;
    
    int result = [self writeFrom:from to:to];
    
    return result;
}

-(NSData*)writeFrom:(NSString *)from
{
    SMBCCTX *smbContext = [IGLSMBProvier openSmbContext];
    if (!smbContext) return nil;
    SMBCFILE *file = smbc_getFunctionOpen(smbContext)(smbContext,from.UTF8String,O_RDONLY,0);
    
    
    if (!file) return nil;
    Byte buffer[4096];
    memset(buffer, 0, 4096);
    
    smbc_read_fn readFn = smbc_getFunctionRead(smbContext);
    NSMutableData *data = [NSMutableData data];
    
    ssize_t value = readFn(smbContext, file, buffer, sizeof(buffer));
    if (value < 0) return nil;
    
    while(value > 0){
        
        [data appendBytes:buffer length:value];
        
        memset(buffer, 0, 4096);
        
        value = readFn(smbContext, file, buffer, sizeof(buffer));
        
    }

    return data;
}

- (NSData *)dataWithPath:(NSString *)filePath
{
    NSData *data = [self writeFrom:filePath];
    return data;
}



- (BOOL)writeFrom:(NSString *)from to:(NSString *)destPath
{
    SMBCCTX *smbContext = [IGLSMBProvier openSmbContext];
    if (!smbContext) return NO;
    
    SMBCFILE *file = smbc_getFunctionOpen(smbContext)(smbContext,from.UTF8String,O_RDONLY,0);
    if (!file) return NO;
    
    
    
    NSFileHandle *handle = [NSFileHandle fileHandleForWritingAtPath:destPath];
    if (!handle) return NO;
    
    Byte buffer[4096];
    memset(buffer, 0, 4096);
    
    smbc_read_fn readFn = smbc_getFunctionRead(smbContext);
    
    NSMutableData *data = [NSMutableData data];
    
    ssize_t value = readFn(smbContext, file, buffer, sizeof(buffer));
    if (value < 0) return NO;
    
    while(value > 0){
        
        [data appendBytes:buffer length:value];
        [handle writeData:[NSData dataWithBytes:buffer length:value]];
        
        memset(buffer, 0, 4096);
        
        value = readFn(smbContext, file, buffer, sizeof(buffer));
        
    }
    
    return YES;
    
}



#pragma mark add code over


+ (void) fetchAllFileAtPathForDisplay: (NSString *) path block: (IGLSMBBlock) block
{
    
    NSParameterAssert(path);
    NSMutableArray *items = [NSMutableArray array];
    if([[IGLSMBProvier sharedSmbProvider] isCanle]){
        block (items);
    }
    SMBCCTX *smbContext = [self openSmbContext];
    if (!smbContext) {
        block (items);
    }
    id result =  [self fetchTreeAtPath:path];
    if([result isKindOfClass:[NSArray class]]){
        block(result);
    }else{
        block(items);
    }
}

+ (BOOL) fetchAllFileAtPathForSearch: (NSString *) path block: (IGLSMBBlock) block
{
    NSLog(@"iglsmbprovider  fetchAllFileAtPathForSearch %@",path);
    NSParameterAssert(path);
    if([[IGLSMBProvier sharedSmbProvider] isCanle]){
        block = nil;
        return YES;
    }
    NSMutableArray *items = [NSMutableArray array];
    SMBCCTX *smbContext = [self openSmbContext];
    if (!smbContext) {
        block = nil;
        return YES;
    }
    id result =  [self fetchTreeAtPath:path];
    if([result isKindOfClass:[NSArray class]]){
        
        NSMutableArray *folder = [NSMutableArray array];
        for (IGLSMBItem *item in result) {
            
            if(S_ISREG(item.stat.mode)){
                [items addObject:item];
            }
            if (S_ISDIR(item.stat.mode)) {
                [folder addObject:item];
            }
        }
        block(items);
        for (IGLSMBItem *item in folder) {
            if([[IGLSMBProvier sharedSmbProvider] isCanle]){
                break;
            }
            if([self fetchAllFileAtPathForSearch:item.path block:block]){
                break;
            }
        }
    }else{
        block(items);
    }
    return NO;
}

- (void) fetchAllFileAtPath: (NSString *) path
                      block: (IGLSMBBlock) block
{
    NSParameterAssert(path);
    NSParameterAssert(block);
    
    dispatch_async(_dispatchQueue, ^{
        
        id result = [IGLSMBProvier fetchAllFileAtPathForDownload: path.length ? path : @"smb://"];
        dispatch_async(dispatch_get_main_queue(), ^{
            block(result);
        });
    });
}

#pragma mark - OK
- (void) createFileAtPath:(NSString *) path overwrite:(BOOL)overwrite block:(IGLSMBBlock) block
{
    NSParameterAssert(path);
    NSParameterAssert(block);
    
    dispatch_sync(_dispatchQueue, ^{
        
        id result = [IGLSMBProvier createFileAtPath:path overwrite:overwrite];
        dispatch_async(dispatch_get_main_queue(), ^{
            block(result);
        });
    });
}
#pragma mark - OK
- (id) createFileAtPath:(NSString *) path overwrite:(BOOL)overwrite
{
    NSParameterAssert(path);
    
    __block id result = nil;
    dispatch_sync(_dispatchQueue, ^{
        
        result = [IGLSMBProvier createFileAtPath:path overwrite:overwrite];
    });
    return result;
}
#pragma mark - OK
- (void) removeAtPath: (NSString *) path block: (IGLSMBBlock) block
{
    NSParameterAssert(path);
    NSParameterAssert(block);
    
    dispatch_async(_dispatchQueue, ^{
        
        id result = [IGLSMBProvier removeAtPath:path];
        dispatch_async(dispatch_get_main_queue(), ^{
            block(result);
        });
    });
}
#pragma mark - OK
- (id) removeAtPath: (NSString *) path
{
    NSParameterAssert(path);
    
    __block id result = nil;
    dispatch_sync(_dispatchQueue, ^{
        
        result = [IGLSMBProvier removeAtPath:path];
    });
    return result;
}
#pragma mark - OK
-(BOOL) removeAtPathIsSuccess: (NSString *) path{
    NSParameterAssert(path);
    __block BOOL result = NO;
    dispatch_sync(_dispatchQueue, ^{
        result = [IGLSMBProvier removeAtPathIsSuccess:path];
    });
    return result;
}
+(BOOL) removeAtPathIsSuccess: (NSString *) path{
    
    id target = [self fetchAtPath:path];
    SMBCCTX *smbContext = [self openSmbContext];
    if (!smbContext) {
        return NO;
    }
    BOOL result = YES;
    if ([target isKindOfClass:[NSArray class]]){
        
        for (IGLSMBItem *item in (NSArray*)target) {
            if(item.type == IGLSMBItemTypeFile){
                int r = smbc_getFunctionUnlink(smbContext)(smbContext, item.path.UTF8String);
                if (r < 0) {
                    result =  NO;
                }
            }
            if(item.type == IGLSMBItemTypeDir){
                result = [self removeAtPathIsSuccess:item.path];
            }
        }
        int r = smbc_getFunctionRmdir(smbContext)(smbContext, path.UTF8String);
        if (r < 0) {
            result =  NO;
        }
    }else{
        int r = smbc_getFunctionUnlink(smbContext)(smbContext, path.UTF8String);
        if (r < 0) {
            result =  NO;
        }
    }
    return result;
}
#pragma mark - OK
- (void) createFolderAtPath:(NSString *) path block: (IGLSMBBlock) block
{
    NSParameterAssert(path);
    NSParameterAssert(block);
    
    dispatch_async(_dispatchQueue, ^{
        
        id result = [IGLSMBProvier createFolderAtPath:path];
        dispatch_async(dispatch_get_main_queue(), ^{
            block(result);
        });
    });
}
#pragma mark - OK
- (id) createFolderAtPath:(NSString *) path
{
    NSParameterAssert(path);
    
    __block id result = nil;
    dispatch_sync(_dispatchQueue, ^{
        
        result = [IGLSMBProvier createFolderAtPath:path];
    });
    return result;
}
#pragma mark - OK
- (void) copySMBPath:(NSString *)smbPath
           localPath:(NSString *)localPath
           overwrite:(BOOL)overwrite
               block:(IGLSMBBlock)block
{
    [self copySMBPath:smbPath localPath:localPath overwrite:overwrite progress:nil block:block iscancel:^BOOL{
        return NO;
    }];;
}
#pragma mark - OK
- (void) copyLocalPath:(NSString *)localPath
               smbPath:(NSString *)smbPath
             overwrite:(BOOL)overwrite
                 block:(IGLSMBBlock)block
{
    [self copyLocalPath:localPath smbPath:smbPath overwrite:overwrite progress:nil block:block iscancel:^BOOL{
        return NO;
    }];
}
#pragma mark - OK
- (void) copySMBPath:(NSString *)smbPath
           localPath:(NSString *)localPath
           overwrite:(BOOL)overwrite
            progress:(IGLSMBBlockProgress)progress
               block:(IGLSMBBlock)block
            iscancel:(IGLSMBCancelBlock)iscancel
{
    [self fetchAtPath:smbPath block:^(id result) {
        
        if ([result isKindOfClass:[IGLSMBItemFile class]]) {
            
            [IGLSMBProvier copySMBFile:result
                             localPath:localPath
                             overwrite:overwrite
                              progress:progress
                                 block:block iscancel:iscancel];
            
        } else if ([result isKindOfClass:[NSArray class]]) {
            
            NSError *error = [IGLSMBProvier ensureLocalFolderExists:localPath];
            if (error) {
                block(error);
                return;
            }
            
            NSMutableArray *folders = [NSMutableArray array];
            NSMutableArray *items = [NSMutableArray array];
            
            for (IGLSMBItem *item in result ) {
                
                if ([item isKindOfClass:[IGLSMBItemFile class]]) {
                    
                    [items addObject:item];
                    
                } else if ([item isKindOfClass:[IGLSMBItemTree class]] &&
                           (item.type == IGLSMBItemTypeDir ||
                            item.type == IGLSMBItemTypeFileShare ||
                            item.type == IGLSMBItemTypeServer))
                {
                    [items addObject:item];
                    [folders addObject:item];
                }
            }
            
            if (folders.count) {
                
                [IGLSMBProvier enumerateSMBFolders:folders
                                             items:items
                                             block:^(id result)
                 {
                     if(iscancel()){
                         block(@(YES));
                         return;
                     }
                     if ([result isKindOfClass:[NSArray class]]) {
                         
                         NSArray *items = result;
                         if (items.count) {
                             
                             [IGLSMBProvier copySMBItems:items
                                               smbFolder:smbPath
                                             localFolder:localPath
                                               overwrite:overwrite
                                                progress:progress
                                                   block:block iscancel:iscancel];
                             
                         } else {
                             
                             block(@(YES));
                         }
                         
                     } else {
                         
                         block(result);
                     }
                 }];
                
            } else if (items.count) {
                
                [IGLSMBProvier copySMBItems:items
                                  smbFolder:smbPath
                                localFolder:localPath
                                  overwrite:overwrite
                                   progress:progress
                                      block:block iscancel:iscancel];
                
            }  else {
                
                block(@(YES));
                return;
            }
            
        } else {
            
            block([result isKindOfClass:[NSError class]] ? result : nil);
        }
    }];
}

#pragma mark - OK
- (void) copySMBPathToSMB:(NSString *)smbPath
                toSmbPath:(NSString *)toSmbPath
                overwrite:(BOOL)overwrite
                 progress:(IGLSMBBlockProgress)progress
                    block:(IGLSMBBlock)block
                 iscancel:(IGLSMBCancelBlock)iscancel
{
    [self fetchAtPath:smbPath block:^(id result) {
        if ([result isKindOfClass:[IGLSMBItemFile class]]) {
            [IGLSMBProvier copySMBFileToSMB:result toSMBpath:toSmbPath overwrite:overwrite progress:progress block:block iscancel:iscancel];
        } else if ([result isKindOfClass:[NSArray class]]) {
            BOOL isexist = [IGLSMBProvier isExistsAtPath:toSmbPath];
            if (!isexist) {
                id r = [self createFolderAtPath:toSmbPath];
                if([r isKindOfClass:[NSError class]]){
                    return;
                }
            }
            
            NSMutableArray *folders = [NSMutableArray array];
            NSMutableArray *items = [NSMutableArray array];
            
            for (IGLSMBItem *item in result ) {
                
                if ([item isKindOfClass:[IGLSMBItemFile class]]) {
                    
                    [items addObject:item];
                    
                } else if ([item isKindOfClass:[IGLSMBItemTree class]] &&
                           (item.type == IGLSMBItemTypeDir ||
                            item.type == IGLSMBItemTypeFileShare ||
                            item.type == IGLSMBItemTypeServer))
                {
                    [items addObject:item];
                    [folders addObject:item];
                }
            }
            
            if (folders.count) {
                
                [IGLSMBProvier enumerateSMBFolders:folders
                                             items:items
                                             block:^(id result)
                 {
                     if ([result isKindOfClass:[NSArray class]]) {
                         
                         NSArray *items = result;
                         if (items.count) {
                             
                             [IGLSMBProvier copySMBItems:items
                                               smbFolder:smbPath
                                                 smbPath:toSmbPath
                                               overwrite:overwrite
                                                progress:progress
                                                   block:block iscancel:iscancel];
                             
                         } else {
                             
                             block(@(YES));
                         }
                         
                     } else {
                         
                         block(result);
                     }
                 }];
                
            } else if (items.count) {
                
                [IGLSMBProvier copySMBItems:items
                                  smbFolder:smbPath
                                    smbPath:toSmbPath
                                  overwrite:overwrite
                                   progress:progress
                                      block:block iscancel:iscancel];
                
            }  else {
                
                block(@(YES));
                return;
            }
            
        } else {
            
            block([result isKindOfClass:[NSError class]] ? result : nil);
        }
    }];
}

#pragma mark - OK
- (void) copyLocalPath:(NSString *)localPath
               smbPath:(NSString *)smbPath
             overwrite:(BOOL)overwrite
              progress:(IGLSMBBlockProgress)progress
                 block:(IGLSMBBlock)block
              iscancel:(IGLSMBCancelBlock)iscancel
{
    NSFileManager *fm = [[NSFileManager alloc] init];
    BOOL isDir;
    if (![fm fileExistsAtPath:localPath isDirectory:&isDir]) {
        
        block(mkIGLSMBError(IGLSMBErrorFileIO,
                           NSLocalizedString(@"File '%@' is not exist", nil),
                           localPath.lastPathComponent));
        return;
    }
    
    if (isDir) {
        
        [self createFolderAtPath:smbPath
                           block:^(id result)
         {
             if ([result isKindOfClass:[IGLSMBItemTree class]]) {
                 
                 [IGLSMBProvier copyLocalFiles:[fm enumeratorAtPath:localPath]
                                   localFolder:localPath
                                     smbFolder:result
                                     overwrite:overwrite
                                      progress:progress
                                         block:block iscancel:iscancel];
             } else {
                 
                 block([result isKindOfClass:[NSError class]] ? result : nil);
             }
         }];
        
    } else {
        [IGLSMBProvier copyLocalFile:localPath
                             smbPath:smbPath
                           overwrite:overwrite
                            progress:progress
                               block:block iscancel:iscancel];
    }
}
#pragma mark - OK
- (long long) filesizeAtPath: (NSString *) path{
    NSParameterAssert(path);
    __block long long result = 0;
    dispatch_sync(_dispatchQueue, ^{
        result = [IGLSMBProvier filesizeAtPath: path];
    });
    return result;
}
+ (long long) filesizeAtPath: (NSString *) path{
    id result= [self fetchAtPath:path];
    if([result isKindOfClass:[NSError class]]){
        return 0;
    }
    if([result isKindOfClass:[IGLSMBItemFile class]]){
        return [(IGLSMBItemFile*)result stat].size;
    }
    if([result isKindOfClass:[NSArray class]]){
        long long size = 0;
        for (IGLSMBItem *item in result) {
            if([item isKindOfClass:[IGLSMBItemFile class]]){
                size += [item stat].size;
            }
            if([item isKindOfClass:[IGLSMBItemTree class]]){
                size += [self filesizeAtPath:item.path];
            }
        }
        return size;
    }
    return 0;
}
#pragma mark - OK
- (void) removeFolderAtPath:(NSString *) path
                      block:(IGLSMBBlock)block
{
    [[IGLSMBProvier sharedSmbProvider] fetchAtPath:path
                block:^(id result)
     {
         if ([result isKindOfClass:[NSArray class]]) {
             
             NSMutableArray *folders = [NSMutableArray array];
             NSMutableArray *items = [NSMutableArray array];
             
             for (IGLSMBItem *item in result) {
                 
                 if ([item isKindOfClass:[IGLSMBItemFile class]]) {
                     
                     [items addObject:item];
                     
                 } else if ([item isKindOfClass:[IGLSMBItemTree class]] &&
                            (item.type == IGLSMBItemTypeDir ||
                             item.type == IGLSMBItemTypeFileShare ||
                             item.type == IGLSMBItemTypeServer))
                 {
                     [items addObject:item];
                     [folders addObject:item];
                 }
             }
             
             if (folders.count) {
                 
                 [IGLSMBProvier enumerateSMBFolders:folders
                                              items:items
                                              block:^(id result)
                  {
                      if ([result isKindOfClass:[NSArray class]]) {
                          
                          NSMutableArray *reversed = [NSMutableArray array];
                          for (id item in [result reverseObjectEnumerator]) {
                              [reversed addObject:item];
                          }
                          
                          [IGLSMBProvier removeSMBItems:reversed block:^(id result) {
                              
                              if ([result isKindOfClass:[NSNumber class]]) {
                                  
                                  [self removeAtPath:path block:block];
                                  
                              } else {
                                  
                                  block([result isKindOfClass:[NSError class]] ? result : nil);
                              }
                          }];
                          
                      } else {
                          
                          block([result isKindOfClass:[NSError class]] ? result : nil);
                      }
                  }];
                 
             } else if (items.count) {
                 
                 [[IGLSMBProvier sharedSmbProvider] removeSMBItems:items block:^(id result) {
                     
                     if ([result isKindOfClass:[NSNumber class]]) {
                         
                         [self removeAtPath:path block:block];
                         
                     } else {
                         
                         block([result isKindOfClass:[NSError class]] ? result : nil);
                     }
                 }];
                 
             } else {
                 
                 [[IGLSMBProvier sharedSmbProvider] removeAtPath:path block:block];
             }
             
         } else if ([result isKindOfClass:[IGLSMBItemFile class]]) {
             
             block(mkIGLSMBError(IGLSMBErrorPathIsNotDir, path));
             
         } else {
             
             block([result isKindOfClass:[NSError class]] ? result : nil);
         }
     }];
}
#pragma mark - OK
- (void) renameAtPath:(NSString *)oldPath
              newPath:(NSString *)newPath
                block:(IGLSMBBlock)block
{
    NSParameterAssert(oldPath);
    NSParameterAssert(newPath);
    NSParameterAssert(block);
    
    dispatch_async(_dispatchQueue, ^{
        
        id result = [IGLSMBProvier renameAtPath:oldPath newPath:newPath];
        dispatch_async(dispatch_get_main_queue(), ^{
            block(result);
        });
    });
}

@end

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////

@implementation IGLSMBItemTree

- (void) fetchItems: (IGLSMBBlock) block
{
    NSParameterAssert(block);
    
    NSString *path = self.path;
    IGLSMBProvier *provider = [IGLSMBProvier sharedSmbProvider];
    [provider dispatchAsync: ^{
        
        id result = [IGLSMBProvier fetchTreeAtPath:path];
        dispatch_async(dispatch_get_main_queue(), ^{
            block(result);
        });
    }];
}

- (id) fetchItems
{
    __block id result = nil;
    NSString *path = self.path;
    IGLSMBProvier *provider = [IGLSMBProvier sharedSmbProvider];
    [provider dispatchSync: ^{
        
        result = [IGLSMBProvier fetchTreeAtPath:path];
    }];
    return result;
}

- (void) createFileWithName:(NSString *) name overwrite:(BOOL)overwrite block: (IGLSMBBlock) block
{
    NSParameterAssert(name.length);
    
    if (self.type != IGLSMBItemTypeDir ||
        self.type != IGLSMBItemTypeFileShare )
    {
        block(mkIGLSMBError(IGLSMBErrorPathIsNotDir, nil));
        return;
    }
    
    [[IGLSMBProvier sharedSmbProvider] createFileAtPath:[self.path stringByAppendingSMBPathComponent:name]
                                              overwrite:overwrite
                                                  block:block];
    
}

- (id) createFileWithName:(NSString *) name overwrite:(BOOL)overwrite
{
    NSParameterAssert(name.length);
    
    if (self.type != IGLSMBItemTypeDir ||
        self.type != IGLSMBItemTypeFileShare )
    {
        return mkIGLSMBError(IGLSMBErrorPathIsNotDir, nil);
    }
    
    return [[IGLSMBProvier sharedSmbProvider] createFileAtPath:[self.path stringByAppendingSMBPathComponent:name]
                                                     overwrite:overwrite];
}

- (void) removeWithName: (NSString *) name block: (IGLSMBBlock) block
{
    if (self.type != IGLSMBItemTypeDir ||
        self.type != IGLSMBItemTypeFileShare )
    {
        block(mkIGLSMBError(IGLSMBErrorPathIsNotDir, nil));
        return;
    }
    
    [[IGLSMBProvier sharedSmbProvider] removeAtPath:[self.path stringByAppendingSMBPathComponent:name]
                                              block:block];
}

- (id) removeWithName: (NSString *) name
{
    if (self.type != IGLSMBItemTypeDir ||
        self.type != IGLSMBItemTypeFileShare )
    {
        return mkIGLSMBError(IGLSMBErrorPathIsNotDir, nil);
    }
    
    return [[IGLSMBProvier sharedSmbProvider] removeAtPath:[self.path stringByAppendingSMBPathComponent:name]];
}

@end

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////

@interface IGLSMBFileImpl : NSObject
@end

@implementation IGLSMBFileImpl {
    
    SMBCCTX *_context;
    SMBCFILE *_file;
    NSString *_path;
}

- (id) initWithPath: (NSString *) path
{
    self = [super init];
    if (self) {
        _path = path;
    }
    return self;
}

- (NSError *) openFile
{
    _context = [IGLSMBProvier openSmbContext];
    if (!_context) {
        const int err = errno;
        return mkIGLSMBError(errnoToSMBErr(err),
                            NSLocalizedString(@"Unable init SMB context (errno:%d)", nil), err);
    }
    
    _file = smbc_getFunctionOpen(_context)(_context,
                                           _path.UTF8String,
                                           O_RDONLY,
                                           0);
    
    if (!_file) {
        _context = NULL;
        const int err = errno;
        return mkIGLSMBError(errnoToSMBErr(err),
                            NSLocalizedString(@"Unable open file:%@ (errno:%d)", nil), _path, err);
    }
    return nil;
}

- (NSError *) createFile:(BOOL)overwrite
{
    _context = [IGLSMBProvier openSmbContext];
    if (!_context) {
        const int err = errno;
        return mkIGLSMBError(errnoToSMBErr(err),
                            NSLocalizedString(@"Unable init SMB context (errno:%d)", nil), err);
    }
    
    _file = smbc_getFunctionCreat(_context)(_context,
                                            _path.UTF8String,
                                            O_WRONLY|O_CREAT|(overwrite ? O_TRUNC : O_EXCL));
    
    if (!_file) {
        _context = NULL;
        const int err = errno;
        return mkIGLSMBError(errnoToSMBErr(err),
                            NSLocalizedString(@"Unable open file:%@ (errno:%d)", nil), _path, err);
    }
    return nil;
}

- (void) closeFile
{
    _context = [IGLSMBProvier openSmbContext];
    if (_file) {
        smbc_getFunctionClose(_context)(_context, _file);
        _file = NULL;
    }
    if (_context) {
        _context = NULL;
    }
}

- (id)readDataOfLength:(NSUInteger)length
{
    if (!_file) {
        
        NSError *error = [self openFile];
        if (error) return error;
    }
    
    _context = [IGLSMBProvier openSmbContext];
    
    Byte buffer[32768];
    
    smbc_read_fn readFn = smbc_getFunctionRead(_context);
    NSMutableData *md = [NSMutableData data];
    NSInteger bytesToRead = length;
    
    while (bytesToRead > 0) {
        
        int r = readFn(_context, _file, buffer, MIN(bytesToRead, sizeof(buffer)));
        
        if (r == 0)
            break;
        
        if (r < 0) {
            
            const int err = errno;
            return mkIGLSMBError(errnoToSMBErr(err),
                                NSLocalizedString(@"Unable read file:%@ (errno:%d)", nil), _path, err);
        }
        
        [md appendBytes:buffer length:r];
        bytesToRead -= r;
    }
    return md;
}

- (id)readDataToEndOfFile
{
    if (!_file) {
        
        NSError *error = [self openFile];
        if (error) return error;
    }
    
    Byte buffer[32768];
    
    smbc_read_fn readFn = smbc_getFunctionRead(_context);
    
    NSMutableData *md = [NSMutableData data];
    
    while (1) {
        
        int r = readFn(_context, _file, buffer, sizeof(buffer));
        
        if (r == 0)
            break;
        
        if (r < 0) {
            
            const int err = errno;
            return mkIGLSMBError(errnoToSMBErr(err),
                                NSLocalizedString(@"Unable read file:%@ (errno:%d)", nil), _path, err);
        }
        
        [md appendBytes:buffer length:r];
    }
    
    return md;
    
}

- (id)seekToFileOffset:(off_t)offset
                whence:(NSInteger)whence
{
    if (!_file) {
        
        NSError *error = [self openFile];
        if (error) return error;
    }
    
    off_t r = smbc_getFunctionLseek(_context)(_context, _file, offset, whence);
    if (r < 0) {
        const int err = errno;
        return mkIGLSMBError(errnoToSMBErr(err),
                            NSLocalizedString(@"Unable seek to file:%@ (errno:%d)", nil), _path, errno);
    }
    return @(r);
}

- (id)writeData:(NSData *)data
{
    if (!_file) {
        
        NSError *error = [self createFile:NO];
        if (error) return error;
    }
    
    smbc_write_fn writeFn = smbc_getFunctionWrite(_context);
    NSInteger bytesToWrite = data.length;
    const Byte *bytes = data.bytes;
    
    while (bytesToWrite > 0) {
        
        int r = writeFn(_context, _file, bytes, bytesToWrite);
        if (r == 0)
            break;
        
        if (r < 0) {
            
            const int err = errno;
            return mkIGLSMBError(errnoToSMBErr(err),
                                NSLocalizedString(@"Unable write file:%@ (errno:%d)", nil), _path, err);
        }
        
        bytesToWrite -= r;
        bytes += r;
    }
    
    return @(data.length - bytesToWrite);
}

@end

@implementation IGLSMBItemFile {
    
    IGLSMBFileImpl *_impl;
}

- (void) dealloc
{
    [self close];
}

- (void) close
{
    if (_impl) {
        
        IGLSMBFileImpl *p = _impl;
        _impl = nil;
        
        IGLSMBProvier *provider = [IGLSMBProvier sharedSmbProvider];
        [provider dispatchAsync:^{ [p closeFile]; }];
    }
}

- (void)readDataOfLength:(NSUInteger)length
                   block:(IGLSMBBlock)block
{
    NSParameterAssert(block);
    
    if (!_impl)
        _impl = [[IGLSMBFileImpl alloc] initWithPath:self.path];
    
    IGLSMBFileImpl *p = _impl;
    IGLSMBProvier *provider = [IGLSMBProvier sharedSmbProvider];
    [provider dispatchAsync:^{
        
        id result = [p readDataOfLength:length];
        dispatch_async(dispatch_get_main_queue(), ^{
            block(result);
        });
    }];
}

- (id)readDataOfLength:(NSUInteger)length
{
    __block id result = nil;
    
    if (!_impl)
        _impl = [[IGLSMBFileImpl alloc] initWithPath:self.path];
    
    IGLSMBFileImpl *p = _impl;
    IGLSMBProvier *provider = [IGLSMBProvier sharedSmbProvider];
    [provider dispatchSync:^{
        
        result = [p readDataOfLength:length];
    }];
    return result;
}

- (void)readDataToEndOfFile:(IGLSMBBlock)block
{
    NSParameterAssert(block);
    
    if (!_impl)
        _impl = [[IGLSMBFileImpl alloc] initWithPath:self.path];
    
    IGLSMBFileImpl *p = _impl;
    IGLSMBProvier *provider = [IGLSMBProvier sharedSmbProvider];
    [provider dispatchAsync:^{
        
        id result = [p readDataToEndOfFile];
        dispatch_async(dispatch_get_main_queue(), ^{
            block(result);
        });
    }];
}

- (id)readDataToEndOfFile
{
    __block id result = nil;
    
    if (!_impl)
        _impl = [[IGLSMBFileImpl alloc] initWithPath:self.path];
    
    IGLSMBFileImpl *p = _impl;
    IGLSMBProvier *provider = [IGLSMBProvier sharedSmbProvider];
    [provider dispatchSync:^{
        
        result = [p readDataToEndOfFile];
    }];
    return result;
}

- (void)seekToFileOffset:(off_t)offset
                  whence:(NSInteger)whence
                   block:(IGLSMBBlock) block
{
    NSParameterAssert(block);
    
    if (!_impl)
        _impl = [[IGLSMBFileImpl alloc] initWithPath:self.path];
    
    IGLSMBFileImpl *p = _impl;
    IGLSMBProvier *provider = [IGLSMBProvier sharedSmbProvider];
    [provider dispatchAsync:^{
        
        id result = [p seekToFileOffset:offset whence:whence];
        dispatch_async(dispatch_get_main_queue(), ^{
            block(result);
        });
    }];
}

- (id)seekToFileOffset:(off_t)offset
                whence:(NSInteger)whence
{
    __block id result = nil;
    
    if (!_impl)
        _impl = [[IGLSMBFileImpl alloc] initWithPath:self.path];
    
    IGLSMBFileImpl *p = _impl;
    IGLSMBProvier *provider = [IGLSMBProvier sharedSmbProvider];
    [provider dispatchSync:^{
        
        result = [p seekToFileOffset:offset whence:whence];
    }];
    return result;
}

- (void)writeData:(NSData *)data block:(IGLSMBBlock) block
{
    NSParameterAssert(block);
    
    if (!_impl)
        _impl = [[IGLSMBFileImpl alloc] initWithPath:self.path];
    
    IGLSMBFileImpl *p = _impl;
    IGLSMBProvier *provider = [IGLSMBProvier sharedSmbProvider];
    [provider dispatchAsync:^{
        
        id result = [p writeData:data];
        dispatch_async(dispatch_get_main_queue(), ^{
            block(result);
        });
    }];
}

- (id)writeData:(NSData *)data
{
    __block id result = nil;
    
    if (!_impl)
        _impl = [[IGLSMBFileImpl alloc] initWithPath:self.path];
    
    IGLSMBFileImpl *p = _impl;
    IGLSMBProvier *provider = [IGLSMBProvier sharedSmbProvider];
    [provider dispatchSync:^{
        
        result = [p writeData:data];
    }];
    return result;
    
}

#pragma mark - internal

- (id) createFile:(BOOL)overwrite
{
    if (!_impl)
        _impl = [[IGLSMBFileImpl alloc] initWithPath:self.path];
    return [_impl createFile:overwrite];
}

@end

@implementation WFstat


@end

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////

static void my_smbc_get_auth_data_fn(const char *srv,
                                     const char *shr,
                                     char *workgroup, int wglen,
                                     char *username, int unlen,
                                     char *password, int pwlen)
{
    IGLSMBAuth *auth = nil;
    auth = [IGLSMBAuth smbAuthWorkgroup:@""
                              username:SAMBA_USERNAME
                              password:SAMBA_PWD];
    if (auth.username.length)
        strncpy(username, auth.username.UTF8String, unlen - 1);
    else
        strncpy(username, "guest", unlen - 1);
    
    if (auth.password.length)
        strncpy(password, auth.password.UTF8String, pwlen - 1);
    else
        password[0] = 0;
    
    if (auth.workgroup.length)
        strncpy(workgroup, auth.workgroup.UTF8String, wglen - 1);
    else
        workgroup[0] = 0;
}
