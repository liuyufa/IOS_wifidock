//
//  WFDataSource.m
//  WiFiDock
//
//  Created by apple on 14-12-28.
//  Copyright (c) 2014年 cn.hualu.WiFiDock. All rights reserved.
//

#import "WFDataSource.h"
#import "IGLSMBProvier.h"
#import "AppDelegate.h"
#import "WFFile.h"
@interface WFDataSource ()
@property(nonatomic,copy)NSString *dirPath;
@property(nonatomic,copy)NSString *fileType;

@end

@implementation WFDataSource

-(NSMutableArray *)datasource
{
    if (!_datasource) {
        _datasource = [NSMutableArray array];
    }
    return _datasource;
}



-(instancetype)initWithRootPath:(NSString *)dirPath fileType:(NSString *)fileType
{
    self = [super init];
    if (self) {
        self.dirPath = dirPath;
        self.fileType = fileType;
        
    }
    return self;
}

+(instancetype)dataSourceWithRootPath:(NSString *)dirPath fileType:(NSString *)fileType
{
    return [[self alloc]initWithRootPath:dirPath fileType:fileType];
}



- (void)loading
{
    
    IGLSMBProvier *provier = [IGLSMBProvier sharedSmbProvider];
    
    
    [provier fetchAllFileWithPath:self.dirPath fileType: self.fileType useBlock:^(id result) {
        
        NSMutableArray *datasource = [NSMutableArray array];
        
        AppDelegate *delegate=(AppDelegate*)[[UIApplication sharedApplication]delegate];
        
        if ([result isEqual:@(YES)]) {
            
            
            delegate.isLogin = YES;
            
            [[NSNotificationCenter defaultCenter]postNotificationName:kLoadingFinsish object:nil];
            
            
        }else {
            
            if(![result isKindOfClass:[NSArray class]]) return ;
            
            delegate.isLogin = NO;
            
            [datasource addObjectsFromArray:result];
            
            [self.datasource addObjectsFromArray:datasource];
            
        
        }
        
    }];
 
}

- (void)loadDirectoryData
{
    IGLSMBProvier *smbTool = [IGLSMBProvier sharedSmbProvider];
    
    self.datasource = [smbTool fetchFileFromDirectory:self.dirPath fileType:self.fileType];
}

- (void)tableView:(UITableView*)tableView getDataFromDocument:filePath
{

    NSString *tmpFile = [filePath stringByAppendingString:@"/"];
    
    dispatch_queue_t queue = dispatch_queue_create("WFDOCK", DISPATCH_QUEUE_SERIAL);
    dispatch_async(queue, ^{
       
        NSFileManager* manager = [NSFileManager defaultManager];
        NSError *err=nil;
        if (![manager fileExistsAtPath:tmpFile]) return ;
        
        NSArray *directoryContent = [manager contentsOfDirectoryAtPath:tmpFile error:&err];
        
        if (err) return;
        
        for(NSString *fileName in directoryContent) {
            
            WFFile *fileItem = [[WFFile alloc]initWithName:fileName filePath:tmpFile withType:nil];
            
            [self.datasource addObject:fileItem];
            
        }
        
    
    });

}

@end
