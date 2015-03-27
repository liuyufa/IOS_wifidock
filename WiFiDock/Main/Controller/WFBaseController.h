//
//  WFTabBarController.h
//  WiFiDock
//
//  Created by apple on 14-12-2.
//  Copyright (c) 2014年 cn.hualu.WiFiDock. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "WFPasteBar.h"
#import "WFSelectBar.h"
#import "WFTabBar.h"
#import "WFEditBar.h"

#import <AssetsLibrary/AssetsLibrary.h>
#import "MBProgressHUD+WF.h"
#import "WFDataSource.h"
#import "IGLSMBProvier.h"
#import "QBPopupMenu.h"
#import "PAPasscodeViewController.h"
#import "ZipFile.h"
#import "FileInZipInfo.h"
#import "ZipReadStream.h"
#import "ZipWriteStream.h"

typedef enum {
    CurrentViewDockMode,
    CurrentViewTFMode,
    CurrentViewUSBMode,
    CurrentViewLoaclMode
} CurrentViewMode;



@interface WFBaseController : UITableViewController<WFTabBarDelegate,UIGestureRecognizerDelegate,WFEditBarDelegate,PAPasscodeViewControllerDelegate,WFPasteBarDelegate,WFSelectBarDelegate>

@property (nonatomic, strong)WFTabBar *customTabBar;
@property (nonatomic, strong)WFPasteBar *pasteTabBar;
@property (nonatomic, strong)WFEditBar *editbtn;
@property (nonatomic, strong)WFSelectBar *selectbtn;

@property (nonatomic, assign) NSInteger selectedIndex;
@property (nonatomic, assign)NSInteger row;
@property (nonatomic, strong) QBPopupMenu *popupMenu;
@property (nonatomic, strong) NSMutableArray *datasource;

@property (nonatomic, strong)ALAssetsLibrary *library;
@property (nonatomic, copy)NSString *dirPath;
@property (nonatomic, copy)NSString *rootLocalPicturePath;
@property (nonatomic, copy)NSString *rootLocalVideoPath;
@property (nonatomic, copy)NSString *rootWifiDockPath;
@property (nonatomic, copy)NSString *rootSambaDockPath;
@property (nonatomic, copy)NSString *rootSambaTFPath;
@property (nonatomic, copy)NSString *rootSambaUSBPath;
@property (nonatomic, copy)NSString *rootLocalPath;

@property (nonatomic, assign)NSInteger index;
@property (nonatomic, assign)BOOL stop;
@property (nonatomic, assign)BOOL selected;
@property (nonatomic, assign)BOOL flag;

@property (nonatomic, copy)NSString *passcode;
@property (nonatomic, assign)BOOL isEncrypt;
@property (nonatomic, assign)BOOL encryptFlag;
@property (nonatomic, assign)BOOL deleteFlag;
@property (nonatomic, strong)NSMutableArray *dockDatasource;
@property (nonatomic, strong)NSMutableArray *tfDatasource;
@property (nonatomic, strong)NSMutableArray *usbDatasource;
@property (nonatomic, strong)NSMutableArray *localDatasource;

@property (nonatomic, strong)NSMutableArray *selectedArray;
@property (nonatomic, strong)NSArray *selectedRows;

- (void)getDateWithPath:(NSString *)filePath fileType:(NSString *)fileType;
//- (void)getDateFromSmbPath:(NSString *)filePath fileType:(NSString *)fileType;
- (void)getDataFromDocument:(NSString *)filePath;
- (void)getDateFromAssetsLibrary:(NSString *)fileType;
- (void)getMore;
- (void)setupTabBar;
- (void)setupMore;
- (void)statusView;
- (void)selectAllFile;
- (void)back;
- (CurrentViewMode)getCurrentViewMode;
- (void)setupEditBar;
-(void)zip;
- (void)cancel;
-(NSString*)currentViewPath;
-(void)copyOverNotification;
@end
