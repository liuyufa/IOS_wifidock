//
//  WFFile.m
//  WiFiDock
//
//  Created by apple on 14-12-5.
//  Copyright (c) 2014年 cn.hualu.WiFiDock. All rights reserved.
//

#import "WFFile.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "WFFileUtil.h"
#import "IGLSMBProvier.h"
@implementation WFFile

- (id)initWithId:(id)idItem withType:(NSString *)fileType
{
    if (self = [super init]) {
        
        if ([idItem isKindOfClass:ALAsset.class]) {
            
            ALAsset *asset= (ALAsset*)idItem;
            
            ALAssetRepresentation *representation = [asset defaultRepresentation];
            
            self.fileName = [representation filename];
            self.icon = [UIImage imageWithCGImage:[asset thumbnail]];
            
            self.fileSize = [NSString stringWithFormat:@"%lld",representation.size];
           
            self.type = File;
            self.fileType = fileType;
            self.flag = YES;
            self.filePath = [[representation url] relativeString];
            NSDate* data = [asset valueForProperty:ALAssetPropertyDate];
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateFormat:@"yyyy－MM－dd"];
            self.createData = [dateFormatter stringFromDate:data];
            
            //data = 2014-05-21 00:49:02 +0000
            
//            NSDictionary *dic = [representation metadata];
//            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
//            [dateFormatter setDateFormat:@"yyyy:MM:dd"];
            
//            id data = [[dic  objectForKey:@"{TIFF}"]objectForKey:@"DateTime"];
            
//            if (data!=nil) {
//                
//                NSArray *time = [data componentsSeparatedByCharactersInSet:
//                                 
//                                 [NSCharacterSet whitespaceCharacterSet]];
//                
//                id dateStr = [time objectAtIndex:0];
//                
//                NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
//                [dateFormatter setDateFormat:@"yyyy:MM:dd"];
//        
//                NSDate *dataTime = [dateFormatter dateFromString:dateStr];
//                [dateFormatter setDateFormat:@"yyyy-MM-dd"];
//                self.createData = [dateFormatter stringFromDate:dataTime];
//                
//            }else{
//                
//                self.createData =NSLocalizedString(@"Unknow",nil);
//                
//            }
            
            
            self.ID = idItem;
        }
    }
    
    return self;
}

- (instancetype)initWithSmbItem:(IGLSMBItem *)smbItem fileType:(NSString *)fileType
{
    self = [super init];
    if (self) {
        
        self.fileName = smbItem.name;
        
        self.filePath = smbItem.path;
        
        self.fileSize = [NSString stringWithFormat:@"%lld",smbItem.stat.size];
        if (smbItem.type == IGLSMBItemTypeDir ) {
            
            self.icon = [UIImage imageNamed:@"foldericon"];
            self.type =  FileDir;
            
        }else{
            
            if ([[smbItem.name pathExtension] isEqualToString:@"lock"]) {
                self.icon = [UIImage imageNamed:@"icon_lock"];
                
            }else{
                self.icon = [WFFileUtil getFileIcon:[smbItem.name pathExtension]];
            }
 
            self.type =  File;
        }

        self.ID = smbItem;
        id dataTime = smbItem.stat.createTime;

        if (dataTime != nil) {
            
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
            [dateFormatter setTimeStyle:NSDateFormatterNoStyle];
        
            //zh-Hans en
            NSString *dataString = [dateFormatter stringFromDate:dataTime];

            
            if ([[self getPreferredLanguage] isEqualToString:@"zh-Hans"]) {
                NSDate *data = [dateFormatter dateFromString:dataString];
                [dateFormatter setDateFormat:@"yyyy-MM-dd"];
                self.createData = [dateFormatter stringFromDate:data];
                
            }else{
                
                self.createData = dataString;
                
            }
            

        }
        
        id time = smbItem.stat.lastModified;
        
        if (time != nil) {
            
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
            [dateFormatter setTimeStyle:NSDateFormatterNoStyle];
            
            NSString *dataString = [dateFormatter stringFromDate:dataTime];
            [dateFormatter setDateFormat:@"yyyy年MM月dd日"];
            NSDate *data = [dateFormatter dateFromString:dataString];
            [dateFormatter setDateFormat:@"yyyy-MM-dd"];
            self.modifyData = [dateFormatter stringFromDate:data];
            //            NSLog(@"self.createData = %@",self.createData);
        }
        
    }
    return self;
}
- (instancetype)initWithName:(NSString *)fileName filePath:(NSString *)filePath withType:(NSString *)fileType
{
    if (self = [super init]){
        
        NSFileManager* manager = [NSFileManager defaultManager];
    
        NSString *path = [filePath stringByAppendingPathComponent:fileName];
        
        NSDictionary *fileAttributes = [manager attributesOfItemAtPath:path error:nil];
       
        if (!fileAttributes) return nil;
        
        NSString *fileType = [fileAttributes objectForKey:NSFileType];
        
        if([fileType isEqualToString:NSFileTypeDirectory]){
            
            self.type = FileDir;
            
            self.fileSize = @"";
            
            self.icon = [UIImage imageNamed:@"foldericon"];
            
        }else{
            
            self.type = File;
            
            self.fileSize = [fileAttributes objectForKey:NSFileSize];
            if ([[fileName pathExtension] isEqualToString:@"lock"]) {
                self.icon = [UIImage imageNamed:@"icon_lock"];
                
            }else{
                self.icon = [WFFileUtil getFileIcon:[fileName pathExtension]];
            }
            
        }
        
        self.flag = NO;
 
        id dataTime = [fileAttributes objectForKey:NSFileCreationDate];
        
        if (dataTime != nil) {

            self.createData = [self timeFormat:dataTime];
            
        }
        
        id modifyTime = [fileAttributes objectForKey:NSFileModificationDate];
        
        if (modifyTime != nil) {
            
            self.modifyData = [self timeFormat:modifyTime];
        }
      
        self.filePath = path;
        
        self.fileName = fileName;
        
        self.fileType = fileType;
        
        self.ID = nil;

    
    }
    
    return self;
}

- (NSString *)getFileType:(NSString *)fileName
{
    NSString *extension = [fileName pathExtension];
    
    if ([WFFileUtil isImage:extension]) {
        
        return @"photo";
        
    }else if([WFFileUtil isAudio:extension]){
    
    }
    
    return nil;
}

- (id)initWithPath:(NSString *)filePath WithName:(NSString *)fileName withDic:(NSDictionary*)dic
{
    self = [super init];
    
    if (self) {
        
        NSString *type = [dic objectForKey:NSFileType];
        
        
        if ([type isEqual:NSFileTypeDirectory]) {
            
            self.type = FileDir;
            
            self.fileSize = @"";
            
            self.icon = [UIImage imageNamed:@"foldericon"];
            
        }else{
            
            self.type = File;
            
            self.fileSize = [dic objectForKey:NSFileSize];
            
            self.icon = [WFFileUtil getFileIcon:[fileName pathExtension]];
            
        }
        self.flag = NO;
        
        id dataTime = [dic objectForKey:NSFileCreationDate];
        
        if (dataTime != nil) {
            
            self.createData = [self timeFormat:dataTime];
        }
        
        id modifyTime = [dic objectForKey:NSFileModificationDate];
        
        if (modifyTime != nil) {
            
            self.modifyData = [self timeFormat:modifyTime];
            
        }
        
        self.filePath = filePath;
        
        self.fileName = fileName;
        
        self.fileType = [self getFileType:fileName];
        
    }
    
    return self;
}

- (instancetype)initWithFile:(WFFile *)file witthPath:(NSString *)destPath
{
    self = [super init];
    if (self) {
        
        NSDictionary *fileAttributes = [self getFileAttributes:destPath];
        
        NSString *fileType = [fileAttributes objectForKey:NSFileType];
        
        self.fileType = fileType;
        
        self.fileName = file.fileName;
        self.filePath = destPath;
        self.fileSize = [fileAttributes objectForKey:NSFileSize];
       
        self.createData = [self getCurrentTime];
        self.modifyData = [self getCurrentTime];
        
        if (file.type == File) {
            
            self.icon = [WFFileUtil getFileIcon:[file.fileName pathExtension]];
        }else {
            
            self.icon = [UIImage imageNamed:@"foldericon"];
        }
        
    }
    
    return self;
}

- (NSString *)timeFormat:(id)dataTime
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
    [dateFormatter setTimeStyle:NSDateFormatterNoStyle];
    
    NSString *dataString = [dateFormatter stringFromDate:dataTime];
    [dateFormatter setDateFormat:@"yyyy年MM月dd日"];
    NSDate *data = [dateFormatter dateFromString:dataString];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    
    return [dateFormatter stringFromDate:data];
}

- (instancetype)initWithName:(NSString *)fileName filePath:(NSString *)filePath isEncrypt:(BOOL)flag
{
    self = [super init];

    if (self) {
        
        
        if ([filePath hasPrefix:@"smb:"]) {
            
            id result = [[IGLSMBProvier alloc]fetchStatWithPath:filePath];
            if (![result isKindOfClass:[WFstat class]]) return nil;
            
            WFstat *stat = result;
            self.fileName = [filePath lastPathComponent];
            self.filePath = filePath;
            long long filesize = stat.stat.size;
            
            self.ID = stat.item;
            self.createData = [self getCurrentTime];
            self.modifyData = [self getCurrentTime];
            
            
            if ([self.ID isKindOfClass:[IGLSMBItemTree class]]) {
                
                self.icon = [UIImage imageNamed:@"foldericon"];
                self.type =  FileDir;
                self.fileSize = nil;
                
            }else{
                
                self.icon = [WFFileUtil getFileIcon:[self.fileName pathExtension]];
                self.type =  File;
                self.fileSize = [NSString stringWithFormat:@"%lld",filesize];
            }
        }else{
            
            self.fileName = fileName;
            self.filePath = filePath;
            
            self.modifyData = [self getCurrentTime];
            self.createData = [self getCurrentTime];
        
            NSDictionary *fileAttributes = [self getFileAttributes:filePath];
            
            NSString *fileType = [fileAttributes objectForKey:NSFileType];
            
            self.fileType = fileType;
            
            if ([fileType isEqual:NSFileTypeDirectory]) {
                
                self.type = FileDir;
                
                self.fileSize = @"";
                
                self.icon = [UIImage imageNamed:@"foldericon"];
                
            }else{
                
                self.type = File;
                
                self.fileSize = [fileAttributes objectForKey:NSFileSize];
                
                if (flag) {
                    
                    self.icon = [UIImage imageNamed:@"icon_lock"];
                    
                }else{
                    
                    self.icon = [WFFileUtil getFileIcon:[fileName pathExtension]];
                }
                
            }
        }
        
       
        
    }
    
    return self;
    
}

- (NSDictionary *)getFileAttributes:(NSString *)filePath
{
    NSFileManager *manager = [NSFileManager defaultManager];
    NSDictionary *fileAttributes = [manager attributesOfItemAtPath:filePath error:nil];
   
    
    return fileAttributes;
    
}

- (instancetype)initWithPath:(NSString *)filePath file:(WFFile *)file
{
    self = [super init];
    if (self) {
        
        if ([filePath hasPrefix:@"smb"]) {
   
            self.fileName = file.fileName;
            self.filePath = filePath;
            self.fileSize = file.fileSize;
            self.ID = file.ID;
            self.createData = [self getCurrentTime];
            self.modifyData = [self getCurrentTime];
            self.icon = file.icon;
            self.type = file.type;
            self.fileType = file.fileType;
    
        }else{
            
            NSDictionary *fileAttributes = [self getFileAttributes:filePath];
            
            NSString *fileType = [fileAttributes objectForKey:NSFileType];
            
            self.fileName = [filePath lastPathComponent];
            
            self.filePath = filePath;
            self.fileSize = [fileAttributes objectForKey:NSFileSize];
            
            self.createData = [self getCurrentTime];
            self.modifyData = [self getCurrentTime];
            
            if (fileType ==  NSFileTypeDirectory) {
                
                self.icon = [UIImage imageNamed:@"foldericon"];
                self.fileType = NSFileTypeDirectory;
                
            }else {
                
                if ([[file.fileName pathExtension] isEqualToString:@"lock"]) {
                    self.icon = [UIImage imageNamed:@"icon_lock"];
                }else{
                    self.icon = [WFFileUtil getFileIcon:[self.fileName pathExtension]];
                }
                self.fileType = NSFileTypeRegular;
            }
        
        }
  
    }
    
    return self;

}

- (instancetype)initWithPath:(NSString *)filePath
{
    self = [super init];
    if (self) {
        
        id result = [[IGLSMBProvier alloc]fetchStatWithPath:filePath];
        if (![result isKindOfClass:[WFstat class]]) return nil;
        
        WFstat *stat = result;
        self.fileName = [filePath lastPathComponent];
        self.filePath = filePath;
        long long filesize = stat.stat.size;
        
        self.ID = stat.item;
        self.createData = [self getCurrentTime];
        self.modifyData = [self getCurrentTime];

        
        if ([self.ID isKindOfClass:[IGLSMBItemTree class]]) {
   
            self.icon = [UIImage imageNamed:@"foldericon"];
            self.type =  FileDir;
            self.fileSize = nil;
            
        }else{
            
            self.icon = [WFFileUtil getFileIcon:[self.fileName pathExtension]];
            self.type =  File;
            self.fileSize = [NSString stringWithFormat:@"%lld",filesize];
        }
        
        
    }
    return self;
}


- (NSString *)getCurrentTime
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    [formatter setDateFormat:@"yyyy-MM-dd"];
    NSString *dataTime = [formatter stringFromDate:[NSDate date]];
    return dataTime;
}

- (NSString *)getPreferredLanguage
{
    NSUserDefaults* defs = [NSUserDefaults standardUserDefaults];

    NSArray* languages = [defs objectForKey:@"AppleLanguages"];
    NSString* preferredLang = [languages objectAtIndex:0];
    
    return preferredLang;

}
@end
