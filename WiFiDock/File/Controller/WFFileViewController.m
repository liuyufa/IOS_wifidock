//
//  WFFileViewController.m
//  WiFiDock
//
//  Created by apple on 14-12-2.
//  Copyright (c) 2014年 cn.hualu.WiFiDock. All rights reserved.
//

#import "WFFileViewController.h"
#import "WFFile.h"
#import "WFPreviewController.h"
#import "IGLSMBProvier.h"
#import "AppDelegate.h"

@interface WFFileViewController ()
@property(nonatomic,assign)BOOL loop;
@end

@implementation WFFileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = NSLocalizedString(@"Document",nil);
}

- (void)tabBar:(WFTabBar *)tabBar didSelectedButtonFrom:(WFTabBarButton*)from to:(WFTabBarButton*)to
{
    if ([from.item.title isEqualToString:to.item.title]) return;
    
    if ([to.item.title isEqualToString:NSLocalizedString(@"Local",nil)]) {
        
        [MBProgressHUD showMessage:NSLocalizedString(@"Loading data......",nil)];
        
        [self getDateWithPath:to.item.dirPath fileType:@"document"];
        
        
    }else {
        
        [MBProgressHUD showMessage:NSLocalizedString(@"Loading data......",nil)];
        [[IGLSMBProvier sharedSmbProvider] setIsCanle:NO];
        
        WFDataSource *data = [WFDataSource dataSourceWithRootPath:to.item.dirPath fileType:@"document"];
        [data loading];
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            
            [MBProgressHUD hideHUD];
            
            if (to.item.dirPath == self.rootSambaDockPath) {
                self.dockDatasource = data.datasource;
            }else if(to.item.dirPath == self.rootSambaTFPath){
                self.tfDatasource = data.datasource;
            }else if (to.item.dirPath == self.rootSambaUSBPath){
                self.usbDatasource = data.datasource;
            }
            
            [self.datasource removeAllObjects];
            
            if (to.item.dirPath == self.rootSambaDockPath) {
                
                self.datasource = self.dockDatasource;
                
            }else if(to.item.dirPath == self.rootSambaTFPath){
                
                self.datasource = self.tfDatasource;
                
            }else if (to.item.dirPath == self.rootSambaUSBPath){
                
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
    
    
    if (!self.tableView.editing) {
        
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        
        AppDelegate *delegate=(AppDelegate*)[[UIApplication sharedApplication]delegate];
        
        if (delegate.isLogin == NO){
            
            return;
            
        }else{
            
            WFFile *fileItem  = self.datasource[indexPath.row];
            
            self.index = indexPath.row;
            
            if ([fileItem.ID isKindOfClass:[ALAsset class]]) {
                
//                [self fileWithUrl:fileItem.filePath withFileName:fileItem.fileName];
                
            }else if([fileItem.ID isKindOfClass:[IGLSMBItem class]]){
                
                self.loop = NO;
               
                NSString *despath = [KWFFileUtilTempPath stringByAppendingPathComponent:[[fileItem.filePath lastPathComponent] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];

                NSString *sourcePath = fileItem.filePath;

                [[IGLSMBProvier sharedSmbProvider] copySMBPath:sourcePath localPath:despath overwrite:YES block:^(id result) {
                    self.loop = YES;
                }];
                
                while(!self.loop){
                    
                    [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
                }
                
                NSMutableArray *array = [NSMutableArray array];
                [array addObject:fileItem];
                WFPreviewController *preview = [[WFPreviewController alloc]initWithURL:[NSURL fileURLWithPath:despath] query:[array copy] index:self.index];
                
               [self presentViewController:preview animated:YES completion:nil];
                
            }else{
                
                NSURL *url = [NSURL fileURLWithPath:[fileItem.filePath  stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
                
                WFPreviewController *preview = [[WFPreviewController alloc]initWithURL:url query:[self.datasource copy] index:self.index];
                
                [self presentViewController:preview animated:YES completion:nil];
                
            }
            
        }
    }
}
@end
