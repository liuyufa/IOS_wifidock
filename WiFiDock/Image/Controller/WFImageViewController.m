//
//  WFImageViewController.m
//  WiFiDock
//
//  Created by apple on 14-12-2.
//  Copyright (c) 2014年 cn.hualu.WiFiDock. All rights reserved.
//

#import "WFImageViewController.h"
#import "WFPreviewController.h"
#import "WFFileUtil.h"
#import "WFFile.h"
#import "WFFileCell.h"
#import "UIImage+IW.h"
#import "IGLSMBProvier.h"
#import "AppDelegate.h"

@interface WFImageViewController ()


@property(nonatomic,assign)BOOL loop;



@end

@implementation WFImageViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    self.navigationItem.title = NSLocalizedString(@"Image",nil);
    
    self.stop = NO;
}

- (void)setupDatasource
{
    NSString *filePath = [WFFileUtil getDocumentPath];
    [self getDateWithPath:filePath fileType:@"photo"];

}

- (void)tabBar:(WFTabBar *)tabBar didSelectedButtonFrom:(WFTabBarButton*)from to:(WFTabBarButton*)to
{
    if ([from.item.title isEqualToString:to.item.title]) return;
    
    if ([to.item.title isEqualToString:NSLocalizedString(@"Local",nil)]) {
        
        [MBProgressHUD showMessage:NSLocalizedString(@"Loading data......",nil)];
//        [self.datasource removeAllObjects];
        
        [self getDateWithPath:to.item.dirPath fileType:@"photo"];
        
        
        
    }else {
        
        [[IGLSMBProvier sharedSmbProvider] setIsCanle:NO];
        
        [MBProgressHUD showMessage:NSLocalizedString(@"Loading data......",nil)];
        

        WFDataSource *data = [WFDataSource dataSourceWithRootPath:to.item.dirPath fileType:@"photo"];
        
        [data loading];

        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            
            [MBProgressHUD hideHUD];
            
            [self.datasource removeAllObjects];
 
            if (to.item.dirPath == self.rootSambaDockPath) {
                
                
                self.dockDatasource = data.datasource;
                self.datasource = self.dockDatasource;
                
            }else if(to.item.dirPath == self.rootSambaTFPath){
                self.tfDatasource = data.datasource;
                self.datasource = self.tfDatasource;
            }else if (to.item.dirPath == self.rootSambaUSBPath){
               
                self.usbDatasource = data.datasource;
                self.datasource = self.usbDatasource;

            }
            
            [self.tableView reloadData];
            
        });
//    [self getDateFromSmbPath:to.item.dirPath fileType:@"photo"];    
  
    }
  
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [super tableView:tableView didSelectRowAtIndexPath:indexPath];
    
    if (self.tableView.editing) return;
    
    if (!self.tableView.editing) {
       
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        
        AppDelegate *delegate=(AppDelegate*)[[UIApplication sharedApplication]delegate];
    
        if (delegate.isLogin == NO){
            
            return;
      
        }else{
    
            WFFile *fileItem = self.datasource[indexPath.row];
            
            self.index = indexPath.row;
     
            if ([fileItem.ID isKindOfClass:[ALAsset class]]) {
                
                NSURL *url =[[NSURL alloc]initWithString:fileItem.filePath];
               
                [self fileWithUrl:url withFileName:fileItem.fileName];
                
            }else if([fileItem.ID isKindOfClass:[IGLSMBItem class]]){
                
                self.loop = NO;
                NSString *despath = [KWFFileUtilTempPath stringByAppendingPathComponent:[fileItem.filePath lastPathComponent]];
                
                NSString *sourcePath = fileItem.filePath ;
                [[IGLSMBProvier sharedSmbProvider] copySMBPath:sourcePath localPath:despath overwrite:YES block:^(id result) {
                    self.loop = YES;
                }];
                
                while(!self.loop){
                    
                    [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
                }

                NSURL *url = [NSURL fileURLWithPath:despath ];
                WFPreviewController *preview = [[WFPreviewController alloc]initWithURL:url query:[self.datasource copy] index:self.index];
                
                [self presentViewController:preview animated:YES completion:nil];
//                [self.navigationController pushViewController:preview animated:YES];
                
//                [self.parentViewController presentViewController:preview animated:YES completion:^{
//                    
//                    NSLog(@"hello");
//                }];
                
            }else{

                NSURL *url = [NSURL fileURLWithPath:fileItem.filePath];
                WFPreviewController *preview = [[WFPreviewController alloc]initWithURL:url query:[self.datasource copy] index:self.index];
                
                [self presentViewController:preview animated:YES completion:nil];
//                [self.navigationController pushViewController:preview animated:YES];

            }
         
        }
    }
}

//- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
//{
//    if (buttonIndex == 0) return;
//    
//}



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
    
    [self presentViewController:preview animated:YES completion:nil];
//    [self.navigationController pushViewController:preview animated:YES];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
}



-(void)dealloc
{
    NSLog(@"++++++++++++");
    NSLog(@"WFImageViewController.h----->");
}
@end
