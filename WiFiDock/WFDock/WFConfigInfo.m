//
//  WFConfigInfo.m
//  IGL004
//
//  Created by apple on 14-10-24.
//  Copyright (c) 2014年 hualu. All rights reserved.
//

#import "WFConfigInfo.h"
#import "WFDiskInfo.h"
#import "IGLSMBProvier.h"


@interface WFConfigInfo()

@property(nonatomic, copy) NSString * dess;

@end

@implementation WFConfigInfo

-(NSString *)readConfigFilefromLocal:(NSString *)fileName{
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    NSArray *Paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    
    NSString *documentsDirector = [Paths objectAtIndex:0];
    
    [fileManager changeCurrentDirectoryPath:[documentsDirector stringByExpandingTildeInPath]];
    
    NSString *filepath = [documentsDirector stringByAppendingPathComponent:fileName];
    
    NSData *reader = [NSData dataWithContentsOfFile:filepath];
    
    return [[NSString alloc]initWithData:reader encoding:NSUTF8StringEncoding];
}

-(void)getConfigInfoFromSmb:(NSString *)remoteUrl {
    
    
    int fd = smbc_open([remoteUrl UTF8String], O_RDONLY, 0666);
    
    if (fd < 0) {
        NSLog(@"open the config file failed");
        return;
    }
    
    char *dessPath = malloc(10);
    memset(dessPath, 0, 0);
    
    ssize_t bytes = smbc_read(fd, dessPath, 10);
    if (bytes < 0) {
        NSLog(@"read the config file failed!");
        return ;
    }
    
    [self writeConfigFileToLocal:[NSString stringWithCString:dessPath encoding:NSUTF8StringEncoding]];
    
    smbc_close(fd);
    free(dessPath);
    dessPath = NULL;
    
}

- (void) writeConfigFileToLocal:(NSString *)flagDate{

    NSFileManager *fileManager = [NSFileManager defaultManager];
    
//    NSString *tmpPath = NSTemporaryDirectory();
   
    NSArray*  paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    
    NSString* documentDirectory = [paths objectAtIndex:0];
    
    [fileManager changeCurrentDirectoryPath:[documentDirectory stringByExpandingTildeInPath]];
    
    [fileManager removeItemAtPath:@".config" error:nil];
    
    
    NSString *path = [documentDirectory stringByAppendingPathComponent:@".config"];
   
    NSMutableData  *writer = [[NSMutableData alloc] init];
    
    [writer appendData:[flagDate dataUsingEncoding:NSUTF8StringEncoding]];
   
    [writer writeToFile:path atomically:YES];
    
}

-(NSString *)getConfigInfo:(NSString *)dessFlag{
    int flags = [dessFlag intValue];
    switch (flags) {
        case 0:
            self.dess = @"WiFiDock";
            break;
        case 1:
            self.dess = @"SD";
            break;
        case 2:
            self.dess = @"USB";
            break;
            
        default:
            break;
    }
    
    return _dess;
}

-(void)deleteConfigFileFromLocal:(NSString *)pathFile{

    NSFileManager *fileManager = [NSFileManager defaultManager];
    
//    NSString *tmpPath = NSTemporaryDirectory();

    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    
    NSString *documentDirectory = [paths objectAtIndex:0];
    
    
    NSString *filepath = [documentDirectory stringByAppendingPathComponent:pathFile];
    
    if ([[NSFileManager defaultManager]fileExistsAtPath:filepath]) {
        [fileManager removeItemAtPath:pathFile error:nil];
    }
    

}


@end
