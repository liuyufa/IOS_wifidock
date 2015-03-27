//
//  WFLocalViewController.m
//  WiFiDock
//
//  Created by apple on 14-12-3.
//  Copyright (c) 2014年 cn.hualu.WiFiDock. All rights reserved.
//

#import "WFLocalViewController.h"
#import "WFFileCell.h"
#import "WFPreviewController.h"
#import "WFFileUtil.h"


@interface WFLocalViewController ()<UITableViewDataSource>
@property(nonatomic,strong)WFFile *file;

@property(nonatomic,assign)NSInteger index;
@end

@implementation WFLocalViewController

-(WFFile *)file
{
    if (!_file) {
        _file = [[WFFile alloc]init];
    }
    return _file;
}


-(instancetype)initWithFile:(WFFile *)file
{
    self = [super init];
    
    if (self) {
        
        self.file = file;
        
    }
    
    return self;
}


-(BOOL)prefersStatusBarHidden
{
    return YES;
}

- (id)init
{
    self = [super initWithStyle:UITableViewStyleGrouped];
    
    
    return self;
}

- (id)initWithStyle:(UITableViewStyle)style
{
    return [super initWithStyle:UITableViewStyleGrouped];
}


- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    self.tableView.rowHeight = 70;
    
    
  
    
}



#pragma 获取相册中资源文件
/*
- (void)getDateFromAssetsLibrary:(NSString *)fileType
{
    dispatch_queue_t q = dispatch_queue_create("WFDOCK", DISPATCH_QUEUE_SERIAL);
    dispatch_async(q, ^{
        
        ALAssetsLibrary *library = self.library;
        
        [library enumerateGroupsWithTypes:ALAssetsGroupSavedPhotos usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
            if (group) {
                if ([fileType isEqualToString:@"photo"]) {
                    
                    [group setAssetsFilter:[ALAssetsFilter allPhotos]];
                    
                }else if([fileType isEqualToString:@"video"]){
                    
                    [group setAssetsFilter:[ALAssetsFilter allVideos]];
                    
                }
                
                [group enumerateAssetsUsingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {
                    if (result) {
                        
                        WFFile *fileItem = [[WFFile alloc]initWithId:result withType:fileType];
                        
                        [self.datasource addObject:fileItem];
                        
                    }
                }];
                
                [self.tableView reloadData];
            }
            
        } failureBlock:^(NSError *error) {
            NSLog(@"open photo Failed.");
        }];
    });
}

*/
- (void)getDataFromDocument:(NSString *)filePath
{
    
    NSString *tmpFile = filePath;
    NSLog(@"tmpFile = %@",tmpFile);
    dispatch_queue_t queue = dispatch_queue_create("WFDOCK", DISPATCH_QUEUE_SERIAL);
    dispatch_async(queue, ^{
        
        NSFileManager* manager = [NSFileManager defaultManager];
        NSError *err=nil;
        if (![manager fileExistsAtPath:tmpFile])
            return ;
        
        NSArray *directoryContent = [manager contentsOfDirectoryAtPath:tmpFile error:&err];
        
        if (err) return;
        
        for(NSString *fileName in directoryContent) {
            
            NSString *tmppath = [filePath stringByAppendingPathComponent:fileName];
            
            
            NSDictionary *fileAttributes = [manager attributesOfItemAtPath:tmppath error:nil];
            
            if (!fileAttributes) return ;
            
            WFFile *fileItem = [[WFFile alloc]initWithPath:tmppath WithName:fileName withDic:fileAttributes];
            
            [self.datasource addObject:fileItem];
            
            [self.tableView reloadData];
        }
    });
    
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.datasource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    WFFileCell *cell = [WFFileCell cellWithTableView:tableView];
    
    cell.file = self.datasource[indexPath.row];
    
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    WFFile *file = self.datasource[indexPath.row];
    
    self.index = indexPath.row;
    
    NSLog(@"file.path = %@",file.filePath);
    NSLog(@"file.fileType = %@",file.fileType);
    
    if ([file.fileType isEqualToString:@"photo"]) {
        
        if ([file.ID isKindOfClass:[ALAsset class]]) {
            
            [self fileWithUrl:file.filePath withFileName:file.fileName];
            
        }else {
            
            NSMutableArray *images = [NSMutableArray array];
            NSLog(@"self.datasource = %@",self.datasource);
            for (WFFile *file in [self.datasource copy]) {
                NSLog(@"file.fileName = %@",[file.fileName pathExtension]);
                if ([WFFileUtil isImage:[file.fileName pathExtension]]) {
                    
                    [images addObject:file];
                }
            }
            NSLog(@"images.count = %d",images.count);
            WFPreviewController *preview = [[WFPreviewController alloc]initWithURL:file.filePath query:[images copy] index:self.index];
            
            [self.parentViewController presentViewController:preview animated:YES completion:^{
                
                NSLog(@"hello");
            }];
 
        }
   
    }
    
}


-(void)fileWithUrl:(NSURL *)url withFileName:(NSString *)fileName
{
 
    NSString *tmpFilePath = [KWFFileUtilTempPath stringByAppendingPathComponent:fileName];
    
    NSFileManager *manage = [NSFileManager defaultManager];
    
    if([manage fileExistsAtPath:tmpFilePath]){
        [manage removeItemAtPath:tmpFilePath error:nil];
    }
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0),^{
        ALAssetsLibrary *assetLibrary = [[ALAssetsLibrary alloc]init];
        [assetLibrary assetForURL:url resultBlock:^(ALAsset *asset) {
            NSLog(@"url = %@",url);
            ALAssetRepresentation *rep = [asset defaultRepresentation];
            NSString *filePath = [KWFFileUtilTempPath stringByAppendingPathComponent:fileName];
            
            char const *cfilePath = [filePath UTF8String];
            FILE *file = fopen(cfilePath, "a+");
            
            if (rep.size == 0) return ;
            
            if (file) {
                const int buffersize = 1024*1024;
                Byte *buffer = (Byte*)malloc(buffersize);
                NSUInteger read = 0,offset = 0, written = 0;
                NSError *err = nil;
                do{
                    read = [rep getBytes:buffer fromOffset:offset length:buffersize error:&err];
                    written = fwrite(buffer, sizeof(char), read, file);
                    offset +=read;
                    
                }while (read != 0 && !err);
                
                
                free(buffer);
                buffer = NULL;
                fclose(file);
                file = NULL;
                
                [self performSelectorOnMainThread:@selector(setTmp:) withObject:filePath waitUntilDone:NO];
            }
        } failureBlock:nil];
    });
    
}

- (void)setTmp:(NSString *)filePath
{
    WFPreviewController *preview = [[WFPreviewController alloc]initWithURL:[NSURL fileURLWithPath:filePath] query:[self.datasource copy] index:self.index];
    
    [self.parentViewController presentViewController:preview animated:YES completion:^{
        
        NSLog(@"hello");
    }];
}



-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5* NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        if (self.datasource) {
            
            [self.tableView reloadData];
        }
        
        
    });
    
}

-(void)dealloc
{
    NSLog(@"self--->");
}

-(void)back
{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)getMore
{
    [self dismissViewControllerAnimated:YES completion:^{
        NSLog(@"go home");
    }];
}

@end
