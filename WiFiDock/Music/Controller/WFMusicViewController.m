//
//  WFMusicViewController.m
//  WiFiDock
//
//  Created by apple on 14-12-2.
//  Copyright (c) 2014年 cn.hualu.WiFiDock. All rights reserved.
//

#import "WFMusicViewController.h"
#import "WFFile.h"
#import "KxMovieViewController.h"
#import "AppDelegate.h"

@interface WFMusicViewController ()

@end

@implementation WFMusicViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = NSLocalizedString(@"Music",nil);
}

- (void)tabBar:(WFTabBar *)tabBar didSelectedButtonFrom:(WFTabBarButton*)from to:(WFTabBarButton*)to
{
    if ([from.item.title isEqualToString:to.item.title]) return;
    
    if ([to.item.title isEqualToString:NSLocalizedString(@"Local",nil)]) {
        
        [MBProgressHUD showMessage:NSLocalizedString(@"Loading data......",nil)];
        
        [self getDateWithPath:to.item.dirPath fileType:@"music"];
        

        
    }else {
        
        [MBProgressHUD showMessage:NSLocalizedString(@"Loading data......",nil)];
        
        [[IGLSMBProvier sharedSmbProvider] setIsCanle:NO];
        WFDataSource *data = [WFDataSource dataSourceWithRootPath:to.item.dirPath fileType:@"music"];
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
            
            WFFile *fileItem = self.datasource[indexPath.row];
            
            self.index = indexPath.row;
            
            if ([fileItem.ID isKindOfClass:[ALAsset class]]) {
                
//                [self fileWithUrl:fileItem.filePath withFileName:fileItem.fileName];
                
            }else if([fileItem.ID isKindOfClass:[IGLSMBItem class]]){
                NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
                
                NSString *url = [NSString stringWithFormat:@"%@:%d%@",LOCAL_HTTP_PATH,LOCAL_HTTP_PORT,[fileItem.filePath stringByReplacingOccurrencesOfString:SAMBA_URL withString:@""]];

                url = [url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
                if ([url.pathExtension isEqualToString:@"wmv"])
                    parameters[KxMovieParameterMinBufferedDuration] = @(5.0);
                
                if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
                    parameters[KxMovieParameterDisableDeinterlacing] = @(YES);
                KxMovieViewController *vc = [KxMovieViewController movieViewControllerWithContent:[self.datasource copy] current:url parameters:parameters withIndex:self.index];
                [self presentViewController:vc animated:NO completion:nil];
                
                
            }else{
                
                NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
                parameters[KxMovieParameterMinBufferedDuration] = @(5.0);
                if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
                    parameters[KxMovieParameterDisableDeinterlacing] = @(YES);
                
                KxMovieViewController *vc = [KxMovieViewController movieViewControllerWithContent:[self.datasource copy] current:fileItem.filePath parameters:parameters withIndex:self.index];
                [self presentViewController:vc animated:NO completion:nil];
                
            }
            
        }
    }

}


@end
