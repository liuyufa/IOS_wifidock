//
//  WFTabBarController.m
//  WiFiDock
//
//  Created by apple on 14-12-2.
//  Copyright (c) 2014年 cn.hualu.WiFiDock. All rights reserved.
//
#import "WFBaseController.h"
#import "UIBarButtonItem+IW.h"
#import "UIImage+IW.h"
#import "WFTabBarButton.h"
#import "WFFile.h"
#import "WFTabBarItem.h"
#import "WFFileCell.h"
#import "WFFileUtil.h"
#import "WFNetCheckController.h"
#import "WFAction.h"
#import "WFActionTool.h"
#import "MJRefresh.h"
#import "IGLCopyAction.h"
#import "WFActionManager.h"
#import "AppDelegate.h"
#import "WFStatusViewController.h"
#import "ZipFile.h"
#import "FileInZipInfo.h"
#import "ZipReadStream.h"
#import "ZipWriteStream.h"
#import "WFPaste.h"
#import "WFTableAlert.h"
#import "WFSettingItem.h"
#import "WFSettingArrowItem.h"


#define KHorizontal ((([[[UIDevice currentDevice] model] isEqualToString:@"iPhone"])|| ([[[UIDevice currentDevice] model]isEqualToString:@"iPod touch"])) ? 32:50)
#define KVertical   ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad ? 70 : 44)


@interface WFBaseController ()<UIAlertViewDelegate>

@property (nonatomic, strong) WFTableAlert *alert;

@property(nonatomic,strong)NSMutableArray *cellArray;

@property(nonatomic, assign)CGFloat customY;

@property(nonatomic, strong)UILongPressGestureRecognizer *longPress;

@property(nonatomic, strong)WFNetCheckController *check;

@property(nonatomic, strong)NSMutableArray *longData;

@property(nonatomic, strong)NSMutableArray *lockArray;

@property(nonatomic,assign)BOOL selectedCount;
@property(nonatomic,assign)BOOL cutFlag;
@property(nonatomic,strong)NSMutableArray *pasteArray;
@property(nonatomic,strong)WFSettingItem *deciphering;
@property(nonatomic,strong)WFSettingItem *encrypt;
@property(nonatomic,strong)WFSettingItem *rename;

@property(nonatomic, assign)BOOL pasteView;
@property(nonatomic, assign)BOOL selectView;

@property(nonatomic,copy)NSString *extension;
@property(nonatomic,strong)NSIndexPath *indexpath;
@end

@implementation WFBaseController

- (id)init
{
    self = [super initWithStyle:UITableViewStyleGrouped];
    
    if (self) {
  
        self.rootLocalPath = [WFFileUtil getDocumentPath];
        
    }
    
    return self;
}

- (id)initWithStyle:(UITableViewStyle)style
{
    return [super initWithStyle:UITableViewStyleGrouped];
}

- (NSMutableArray *)longData
{
    if (!_longData) {
        
        _longData = [NSMutableArray array];
    
    }
    return _longData;
}

- (NSMutableArray*)lockArray
{

    if (!_lockArray) {
        _lockArray = [NSMutableArray array];
    }
    return _lockArray;
}

-(ALAssetsLibrary*)library
{
    if (!_library) {
        _library =  [[ALAssetsLibrary alloc] init];
    }
    
    return _library;
}

-(NSMutableArray *)pasteArray
{
    if (!_pasteArray) {
        _pasteArray = [NSMutableArray array];
    }
    return _pasteArray;
}

- (NSMutableArray *)selectedArray
{
    if (!_selectedArray) {
        _selectedArray = [NSMutableArray array];
    }
    
    return _selectedArray;
}

- (NSArray*)selectedRows
{
    if (!_selectedRows) {
        _selectedRows = [NSArray array];
    }
    return _selectedRows;
}

- (NSMutableArray *)dockDatasource
{
    if (!_dockDatasource) {
        _dockDatasource = [NSMutableArray array];
    }
    return _dockDatasource;
}

- (NSMutableArray *)tfDatasource
{
    if (!_tfDatasource) {
        _tfDatasource = [NSMutableArray array];
    }
    return _tfDatasource;
}

- (NSMutableArray *)usbDatasource
{
    if (!_usbDatasource) {
        _usbDatasource = [NSMutableArray array];
    }
    return _usbDatasource;
}

- (NSMutableArray *)localDatasource
{
    if (!_localDatasource) {
        _localDatasource = [NSMutableArray array];
    }
    return _localDatasource;
}

- (NSMutableArray *)datasource
{
    if (!_datasource) {
        _datasource = [NSMutableArray array];
    }
    return _datasource;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setupNavigationItem];
 
    [self createFilePath];
    
    [self setupTabBar];
    
    [self setupTabBarChildBtns];
    
    [self setupRefresh];
    
//    [self setupMore];
    
    [self registerEvent];

    [self addNote];
    
#pragma mark 修改编辑模式
    
    [self setupEditBar];
    
    [self setupLongData];
    
    [self setupPasteBar];
    
    [self setupSelectBar];
    
    self.pasteTabBar.hidden = YES;
    self.selectbtn.hidden = YES;
    self.editbtn.hidden = YES;
    
    self.pasteView = NO;
    self.selectView = NO;
}

- (void)setupSelectBar
{
    CGFloat editH = 60;
    
    CGFloat editY = self.view.frame.size.height-editH+20 ;//+ 20
    WFSelectBar *selectTabBar = [[WFSelectBar alloc] initWithFrame:CGRectMake(0, editY, self.view.frame.size.width, editH)];
    
    selectTabBar.delegate = self;
    [self.navigationController.view addSubview:selectTabBar];
    self.selectbtn = selectTabBar;
    self.selectbtn.autoresizingMask = UIViewAutoresizingFlexibleWidth;
}


- (void)setupPasteBar
{
    
    WFPasteBar *pasteTabBar = [[WFPasteBar alloc] init];
    
    pasteTabBar.delegate = self;
    [self.navigationController.view addSubview:pasteTabBar];
    self.pasteTabBar = pasteTabBar;
    self.pasteTabBar.autoresizingMask = UIViewAutoresizingFlexibleWidth;
}

- (void)setupNavigationItem
{

    self.view.backgroundColor = [UIColor whiteColor];
    self.tableView.rowHeight = 70;
    self.encryptFlag = NO;
    self.tableView.userInteractionEnabled = YES;
    self.navigationItem.leftBarButtonItem = [UIBarButtonItem itemWithImage:@"navigationbar_back" higlightedImage:@"navigationbar_back_highlighted" target:self action:@selector(back)];
    
     UIBarButtonItem *btn0 = [[UIBarButtonItem alloc]initWithImage:[UIImage imageWithName:@"icon_toolbar_status"] style:UIBarButtonItemStylePlain target:self action:@selector(statusView)];
    btn0.tintColor = WFColor(41, 41, 41);
    
    UIBarButtonItem *btn1 = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemCompose target:self action:@selector(getMore)];
    btn1.tintColor = WFColor(41, 41, 41);
    
    self.navigationItem.rightBarButtonItems = @[btn1,btn0];
    self.selected = YES;
    self.cutFlag = NO;
    
    [[IGLSMBProvier sharedSmbProvider] setIsCanle:NO];
}

-(void)setupLongData
{
    WFSettingItem *rename = [WFSettingArrowItem itemWithTitle:NSLocalizedString(@"rename",nil)destVcClass:nil];
    self.rename = rename;
    
    WFSettingItem *deciphering = [WFSettingArrowItem itemWithTitle:NSLocalizedString(@"deciphering",nil) destVcClass:nil];
    self.deciphering = deciphering;
    
    WFSettingItem *encrypt = [WFSettingArrowItem itemWithTitle:NSLocalizedString(@"encrypt",nil) destVcClass:nil];
    self.encrypt = encrypt;
}

-(void)addNote
{
    NSNotificationCenter *defaultCenter = [NSNotificationCenter defaultCenter];
    
    [defaultCenter addObserver:self selector:@selector(sambaStatusChange:) name:kSambaChangedNotification object:nil];
    
    [defaultCenter addObserver:self selector:@selector(copyOverNotification) name:kCopyOverNotification object:nil];
    
    [defaultCenter addObserver:self selector:@selector(loadFinish) name:kLoadingFinsish object:nil];

}

-(void)copyOverNotification
{

    for (int row = 0; row < self.datasource.count; row++) {
        NSIndexPath *index = [NSIndexPath indexPathForRow:row inSection:0];
        [self.tableView selectRowAtIndexPath:index animated:NO scrollPosition: UITableViewScrollPositionNone];
    }
    
    for (UIButton *btn in self.editbtn.subviews) {
        
        btn.selected = NO;
    }
    
    for (WFPaste *paste in self.pasteArray) {
        
        NSString *path = paste.filePath;
        WFFile *file = paste.file;

        if (([path hasPrefix:@"smb:"]&&[file.filePath hasPrefix:@"smb:"])
            ||[path hasPrefix:[WFFileUtil getDocumentPath]]) {//最终路径位smb
            
            file = [[WFFile alloc]initWithPath:path file:file];
            
        }else if([file.filePath hasPrefix:[WFFileUtil getDocumentPath]]&&[path hasPrefix:@"smb:"]){//本地－－smb
        
            file = [[WFFile alloc]initWithPath:path];
        }
        
        [self.datasource addObject:file];
    }
    
    [self.tableView reloadData];
    
}

- (void)loadFinish
{
    [self.tableView reloadData];
}

- (void)setupMore
{
    QBPopupMenuItem *item1 = [QBPopupMenuItem itemWithTitle:NSLocalizedString(@"Status",nil) target:self action:@selector(statusView)];
//    QBPopupMenuItem *item2 = [QBPopupMenuItem itemWithTitle:NSLocalizedString(@"All",nil) target:self action:@selector(selectAllFile)];
    
    QBPopupMenuItem *item3 = [QBPopupMenuItem itemWithTitle:NSLocalizedString(@"encrypt",nil) target:self action:@selector(zip)];

    NSArray *items = @[item1,item3];
    
    QBPopupMenu *popupMenu = [[QBPopupMenu alloc] initWithItems:items];
    popupMenu.highlightedColor = [[UIColor colorWithRed:0 green:0.478 blue:1.0 alpha:1.0] colorWithAlphaComponent:0.8];
    
    self.popupMenu = popupMenu;

}

- (void)setupRefresh
{
    [self.tableView addHeaderWithTarget:self action:@selector(headerRereshing)];

//    [self.tableView headerBeginRefreshing];

    [self.tableView setTableHeaderView:self.tableView.tableHeaderView];
    
    self.tableView.headerPullToRefreshText = @"下拉可以刷新了";
    self.tableView.headerReleaseToRefreshText = @"松开马上刷新了";
    self.tableView.headerRefreshingText = @"加载中......";
 
}

- (void)headerRereshing
{
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
   
        [self.tableView reloadData];
   
        [self.tableView headerEndRefreshing];
    });
}

- (void)footerRereshing
{

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
  
        [self.tableView reloadData];

        [self.tableView footerEndRefreshing];
    });
}


- (void)createFilePath
{
    NSString *documentPath = [[WFFileUtil getDocumentPath]stringByAppendingString:@"/"];
    
    self.rootLocalPicturePath = [documentPath stringByAppendingString:NSLocalizedString(@"Localtion Image",nil)];
    self.rootLocalVideoPath = [documentPath stringByAppendingString:NSLocalizedString(@"Localtion Video",nil)];
    self.rootWifiDockPath = [documentPath stringByAppendingString:NSLocalizedString(@"WiFiDock",nil)];
    
    if (![WFFileUtil isExistsAtPath:self.rootWifiDockPath]) {
        
        [WFFileUtil createFolderAtPaht:self.rootWifiDockPath];
    }
    
    if (![WFFileUtil isExistsAtPath:self.rootLocalPicturePath]) {
        
        [WFFileUtil createFolderAtPaht:self.rootLocalPicturePath];
    }
    
    if (![WFFileUtil isExistsAtPath:self.rootLocalVideoPath]) {
        
        [WFFileUtil createFolderAtPaht:self.rootLocalVideoPath];
    }
    
    NSString *filepath = [[WFFileUtil getDocumentPath] stringByAppendingPathComponent:NSLocalizedString(@"Encryption area",nil)];
    
    if (![WFFileUtil isExistsAtPath:filepath]) {
        
        [WFFileUtil createFolderAtPaht:filepath];
    }
    
    NSString *path = [[WFFileUtil getDocumentPath] stringByAppendingPathComponent:NSLocalizedString(@"Decryption area",nil)];
    
    if (![WFFileUtil isExistsAtPath:path]) {
        
        [WFFileUtil createFolderAtPaht:path];
    }

}

- (void)registerEvent
{
    UILongPressGestureRecognizer *longPress =
    [[UILongPressGestureRecognizer alloc]initWithTarget:self action: @selector(handleTableviewCellLongPressed:)];
    longPress.delegate = self;
    longPress.minimumPressDuration = 0.5;
    [self.tableView addGestureRecognizer:longPress];
    self.longPress = longPress;
}

- (void)back
{
    NSString *filePath = [[WFFileUtil getDocumentPath] stringByAppendingPathComponent:@".tmp"];
    
    if ([WFFileUtil isExistsAtPath:filePath]) {
        [WFFileUtil removeFileAtPaht:filePath];
    }
    
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[IGLSMBProvier sharedSmbProvider] setIsCanle:YES];
    self.customTabBar.hidden = YES;
    self.navigationController.navigationBar.hidden = YES;
    self.editbtn.hidden = YES;
    
    if (!self.pasteTabBar.hidden) {
        self.pasteTabBar.hidden = YES;
    }
    
    if (!self.selectbtn.hidden) {
        self.selectbtn.hidden = YES;
    }
    
    
}

- (void)getMore
{
    self.navigationItem.rightBarButtonItem =[UIBarButtonItem itemWithImage:@"icon_toolbar_cancel" higlightedImage:nil target:self action:@selector(cancel)];

    self.navigationItem.rightBarButtonItem.tintColor = WFColor(41, 41, 41);
    
#pragma mark 修改编辑模式
    
    [UIView animateWithDuration:0.25f animations:^{
        
        self.editbtn.hidden = NO;
        
    }];
    
    [self.tableView removeGestureRecognizer:self.longPress];

    [self.tableView setEditing:YES animated:YES];
   
}

- (void)cancel
{
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemCompose target:self action:@selector(getMore)];
    self.navigationItem.rightBarButtonItem.tintColor = WFColor(61, 61, 61);
    
//    [self.selectedArray removeAllObjects];
//    self.selectedRows = 0;
    
    [self registerEvent];
    
    [UIView animateWithDuration:0.25f animations:^{
        
        self.editbtn.hidden = YES;
        
        
    }];
    
    [self.tableView setEditing:NO animated:YES];
}

#pragma mark 修改编辑模式

- (void) setupEditBar
{

    WFEditBar *editTabBar = [[WFEditBar alloc] init];
    editTabBar.delegate = self;
    [self.navigationController.view addSubview:editTabBar];
    self.editbtn = editTabBar;
    self.editbtn.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    
}

#pragma 初始化tabbar
- (void)setupTabBar
{
    self.customY= self.navigationController.navigationBar.frame.size.height;
    CGFloat customX = 0;
    CGFloat customW = self.view.frame.size.width;
   
    CGFloat customH = 54;
    
    WFTabBar *customTabBar = nil;
    
    if (self.customTabBar == nil) {
        customTabBar = [[WFTabBar alloc] init];
    }
    
    customTabBar.frame = CGRectMake(customX, self.customY+20, customW, customH);
    customTabBar.delegate = self;
    [self.navigationController.view addSubview:customTabBar];
    self.customTabBar = customTabBar;
    self.customTabBar.autoresizingMask = UIViewAutoresizingFlexibleWidth ;

}


- (void) setupTabBarChildBtns
{
    
    if ([Reachability sambaStatus]) {
    
        [self getStorageStaus];
        
        if (self.rootSambaDockPath) {
           
            [self addTabBarButtonWithTitle:NSLocalizedString(@"WiFiDock",nil) imageName:@"tabbar_home" selectedImageName:@"tabbar_home_selected" dirPath:self.rootSambaDockPath];
          
        }
        if (self.rootSambaUSBPath) {
            [self addTabBarButtonWithTitle:NSLocalizedString(@"U",nil) imageName:@"tabbar_home" selectedImageName:@"tabbar_home_selected" dirPath:self.rootSambaUSBPath];
        }
        
        if (self.rootSambaTFPath) {
            
            [self addTabBarButtonWithTitle:NSLocalizedString(@"TF",nil) imageName:@"tabbar_home" selectedImageName:@"tabbar_home_selected" dirPath:self.rootSambaTFPath];
           
        }
        [self addTabBarButtonWithTitle:NSLocalizedString(@"Local",nil) imageName:@"tabbar_home" selectedImageName:@"tabbar_home_selected" dirPath:self.rootLocalPath];
        
    }else{
        
        [self addTabBarButtonWithTitle:NSLocalizedString(@"Local",nil) imageName:@"tabbar_home" selectedImageName:@"tabbar_home_selected" dirPath:self.rootLocalPath];
    }
}

- (void)getStorageStaus
{

        [[WFNetCheckController sharedNetCheck] getStorageStaus];
 
        self.rootSambaDockPath = [WFNetCheckController sharedNetCheck].dockPath;
        self.rootSambaTFPath = [WFNetCheckController sharedNetCheck].tfPath;
        self.rootSambaUSBPath =[WFNetCheckController sharedNetCheck].usbPath;
  
}

- (void)addTabBarButtonWithTitle:(NSString *)title imageName:(NSString *)imageName selectedImageName:(NSString *)selectedImageName dirPath:(NSString *)dirPath
{

    WFTabBarItem *item = [[WFTabBarItem alloc]init];
    item = [[WFTabBarItem alloc]initWithTitle:title image:[UIImage imageNamed:imageName] selectedImage:[UIImage imageNamed:selectedImageName] dirPath:dirPath];
    
    [self.customTabBar addTabBarButtonWithItem:item];
    
}


- (void)getDateFromAssetsLibrary:(NSString *)fileType
{
//    [MBProgressHUD showMessage:@"载入数据中....."];
    
    dispatch_queue_t q = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
//    dispatch_queue_t q = dispatch_queue_create("WFDOCK", DISPATCH_QUEUE_SERIAL);
    dispatch_async(q, ^{
        NSMutableArray *datasource = [NSMutableArray array];
    
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
                        
                        [datasource addObject:fileItem];
  
                    }
                    
                }];
                
            }else {
                
                [self.localDatasource addObjectsFromArray:datasource];
                self.datasource = self.localDatasource;
                dispatch_queue_t queue = dispatch_get_main_queue();
                
                dispatch_async(queue, ^{
                    
                    [MBProgressHUD hideHUD];
                    
                    [MBProgressHUD showSuccess:NSLocalizedString(@"Loading Over",nil)];
                    
                    AppDelegate *delegate=(AppDelegate*)[[UIApplication sharedApplication]delegate];
                    
                    delegate.isLogin = YES;
                    
                    [self.tableView reloadData];
                });

            }
            
        } failureBlock:^(NSError *error) {
            
            dispatch_queue_t queue = dispatch_get_main_queue();
            dispatch_async(queue, ^{
                
                [MBProgressHUD hideHUD];
                
                [MBProgressHUD showError:NSLocalizedString(@"Open Album failed",nil)];
                
                [self.tableView reloadData];
            });

        }];
        
    });
    

}

- (void)getDateWithPath:(NSString *)filePath fileType:(NSString *)fileType
{
    
    NSFileManager* manager = [NSFileManager defaultManager];
    NSError *err=nil;
    NSArray *directoryContent = [manager contentsOfDirectoryAtPath:filePath error:&err];
    if (err) return;
 
    for(NSString *fileName in directoryContent) {
        NSMutableArray *datasource = [NSMutableArray array];
        if ([fileName isEqual:NSLocalizedString(@"Localtion Image",nil)]) {
            
            if ([fileType isEqualToString:@"photo"]) {
                
                [self getDateFromAssetsLibrary:fileType];
            }
            
        }else if([fileName isEqual:NSLocalizedString(@"Localtion Video",nil)]){
            
            if([fileType isEqualToString:@"video"]){
                [self getDateFromAssetsLibrary:fileType];
            }

        }else {

            NSString *tmppath = [filePath stringByAppendingPathComponent:fileName];
            
            NSDictionary *fileAttributes = [manager attributesOfItemAtPath:tmppath error:nil];
            
            if (!fileAttributes) return ;
            
            NSString *type = [fileAttributes objectForKey:NSFileType];
            
            NSString *extension = [fileName pathExtension];
            
            if ([type isEqual:NSFileTypeDirectory]) {
                
                NSString *path = [filePath stringByAppendingPathComponent:fileName];
                
                [self getDateWithPath:path fileType:fileType];
                
            }else{
                
                if ([fileType isEqualToString:@"photo"]&&[WFFileUtil isImage:extension]) {
                    
                    WFFile *fileItem = [[WFFile alloc]initWithPath:tmppath WithName:fileName withDic:fileAttributes];
                    
                    [datasource addObject:fileItem];
                    
                } else if ([fileType isEqualToString:@"video"]&&[WFFileUtil isVideo:extension]) {
                    
                    WFFile *fileItem = [[WFFile alloc]initWithPath:tmppath WithName:fileName withDic:fileAttributes];
                    
                    [datasource addObject:fileItem];
                    
                }else if ([fileType isEqualToString:@"music"]&&[WFFileUtil isAudio:extension]) {
                    
                    WFFile *fileItem = [[WFFile alloc]initWithPath:tmppath WithName:fileName withDic:fileAttributes];
                    
                    [datasource addObject:fileItem];
                }else if ([fileType isEqualToString:@"document"]&&[WFFileUtil isDoc:extension]) {
                    
                    WFFile *fileItem = [[WFFile alloc]initWithPath:tmppath WithName:fileName withDic:fileAttributes];
              
                    [datasource addObject:fileItem];
                }

                [self.localDatasource addObjectsFromArray: datasource];
                self.datasource = self.localDatasource;
                [self.tableView reloadData];
            }
            
        }
        
    }
    
    if ([fileType isEqualToString:@"music"]||[fileType isEqualToString:@"document"]) {
        [MBProgressHUD hideHUD];
        [MBProgressHUD showSuccess:NSLocalizedString(@"Loading Over",nil)];
    }
   
}

/*
- (void)getDateFromSmbPath:(NSString *)filePath fileType:(NSString *)fileType
{
    WFSmbTool *smbTool = [WFSmbTool sharedSmbTool];
    [self.datasource removeAllObjects];
    dispatch_queue_t queue =dispatch_queue_create("WiFiDock", DISPATCH_QUEUE_SERIAL);
    dispatch_async(queue, ^{
        [smbTool fetchAllFileWithPath:filePath  fileType: fileType useBlock:^(id result) {
                
            NSMutableArray *datasource = [NSMutableArray array];
            
            if(![result isKindOfClass:[NSArray class]]) return ;
            
            [datasource addObjectsFromArray:result];
            [self.datasource addObjectsFromArray:datasource];
            
        }];
        
        dispatch_async(dispatch_get_main_queue(), ^{
          
            [self.tableView reloadData];
            
        });
    });

}
*/

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 20.0f;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 50.0f;
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
    self.row = indexPath.row;
    
    if (self.tableView.editing) {
        
        NSArray* selectedRows = [self.tableView indexPathsForSelectedRows];
        
        self.selectedRows = selectedRows;
        
        
    }
}


- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.tableView.editing) {
        
        NSArray* selectedRows = [self.tableView indexPathsForSelectedRows];
        
        self.selectedRows = selectedRows;
        
    }
}

- (void)handleTableviewCellLongPressed:(UILongPressGestureRecognizer *)gestureRecognizer
{

    CGPoint p = [gestureRecognizer locationInView:self.tableView ];
    
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:p];
    
    self.encryptFlag = YES;
    
    if (gestureRecognizer.state == UIGestureRecognizerStateBegan) {
        
        [self longPressSubview:(NSIndexPath *)indexPath];
    }
 
}

- (void)longPressSubview:(NSIndexPath *)indexPath
{
    __weak typeof(self) weakSelf = self;
    NSString *title = NSLocalizedString(@"选项",nil);
    self.alert = [WFTableAlert tableAlertWithTitle:title
                    cancelButtonTitle:NSLocalizedString(@"Cancel",nil)
    numberOfRows:^NSInteger (NSInteger section){
        
        WFFile *file = weakSelf.datasource[indexPath.row];
        
        NSMutableArray *longData = [NSMutableArray array];
        
        [longData addObject:weakSelf.rename];
        
        if ([[file.fileName pathExtension] isEqualToString:@"lock"]) {
            
            [longData addObject:weakSelf.deciphering];
            
        }else{
            
            [longData addObject:weakSelf.encrypt];
        }
        
        weakSelf.longData = longData;

        return weakSelf.longData.count;
    }
                  
    andCells:^UITableViewCell* (WFTableAlert *anAlert, NSIndexPath *indexPath){
                                              
       static NSString *CellIdentifier = @"CellIdentifier";
       UITableViewCell *cell = [anAlert.table dequeueReusableCellWithIdentifier:CellIdentifier];
       if (cell == nil)
           cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
                                          
        WFSettingItem *item = [weakSelf.longData objectAtIndex:indexPath.row];
        cell.textLabel.text = item.title;
                                          
        return cell;
    }];

    self.alert.height = 350;
    
    [self.alert configureSelectionBlock:^(NSIndexPath *selectedIndex){
        
        WFSettingItem *item =[weakSelf.longData objectAtIndex:selectedIndex.row];
        
        if ([item.title isEqualToString:NSLocalizedString(@"deciphering",nil)]) {
            
            [weakSelf deciphering:indexPath];
            
        }else if ([item.title isEqualToString:NSLocalizedString(@"rename",nil)]){
            
            [weakSelf rename:indexPath];
            
        }else if ([item.title isEqualToString:NSLocalizedString(@"encrypt",nil)]){
            
            [self encrypt:indexPath];
        }
        
    } andCompletionBlock:^{
        
    }];

    [self.alert show];

}

- (void)encrypt:(NSIndexPath *)indexPath
{
    WFFile *file = self.datasource[indexPath.row];
    
    NSMutableArray *selectedArray = [NSMutableArray array];
    [selectedArray addObject:file];
    self.selectedArray = selectedArray;
    
    PAPasscodeViewController *passcodeViewController = [[PAPasscodeViewController alloc] initForAction:PasscodeActionSet];
    passcodeViewController.delegate = self;
    
    [self presentViewController:passcodeViewController animated:YES completion:nil];
    
}

- (void)deciphering:(NSIndexPath *)indexPath
{
    
    WFFile *file = self.datasource[indexPath.row];
    NSMutableArray *selectedArray = [NSMutableArray array];
    [selectedArray addObject:file];
    self.selectedArray = selectedArray;
    
    int selectedCount = selectedArray.count;
    if (!selectedCount){
        
        [MBProgressHUD showError:NSLocalizedString(@"Please Select the file",nil)];
        
        return;
    }

    
    for (WFFile *file in self.selectedArray) {
        
        if ([file.filePath hasPrefix:@"smb:"]) {
            
            [MBProgressHUD showError:@"WiFiDock端不支持解密功能，请拷贝到本地中解密"];
            return;
        }
       
        if ([[file.fileName pathExtension]isEqualToString:@"lock"]) {
            
            PAPasscodeViewController *passcodeViewController = [[PAPasscodeViewController alloc] initForAction:PasscodeActionEnter];
            
            passcodeViewController.fileName = file.fileName;
            passcodeViewController.filePath = file.filePath;
            passcodeViewController.delegate = self;
            
            [self presentViewController:passcodeViewController animated:YES completion:nil];
    
        }

    }

}

- (void)rename:(NSIndexPath *)indexPath
{

    WFFile *file = self.datasource[indexPath.row];
    
    self.indexpath = indexPath;

    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Modify the Name",nil) message:nil delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel",nil) otherButtonTitles:NSLocalizedString(@"Done",nil), nil];
    
    alert.alertViewStyle = UIAlertViewStylePlainTextInput;
    
    [alert textFieldAtIndex:0].text = [file.fileName stringByDeletingPathExtension];

    self.extension = [file.fileName pathExtension];
    
    alert.tag = 103;
    
    [alert show];
        
    
}


-(BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

-(void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath
{
    NSUInteger fromRow = [sourceIndexPath row];
    
    NSUInteger toRow = [destinationIndexPath row];
    
    id object = [self.datasource objectAtIndex:fromRow];
    
    [self.datasource removeObjectAtIndex:fromRow];
    
    [self.datasource insertObject:object atIndex:toRow];
}

#pragma tableView 进入编辑模式

-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return true;
}

-(UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleInsert | UITableViewCellEditingStyleDelete;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    if (self.customTabBar.hidden) {
        self.customTabBar.hidden = NO;
    }
    
    self.editbtn.hidden = YES;
 
    if (self.navigationController.navigationBar.hidden == YES) {
        self.navigationController.navigationBar.hidden = NO;
    }

    [self didRotateFromInterfaceOrientation:0];

    [self.tableView reloadData];
 
}


-(void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    self.popupMenu.hidden = YES;
    
    self.popupMenu = nil;
   
    if (UIInterfaceOrientationIsLandscape(self.interfaceOrientation)) {
 
            CGFloat editH = 60;
            
            CGFloat editY = self.view.frame.size.height-editH ;
            self.editbtn.frame =CGRectMake(0, editY, self.view.frame.size.width, editH);
  
            CGFloat pasteH = editH;
            
            CGFloat pasteY = self.view.frame.size.height-pasteH ;
            self.pasteTabBar.frame =CGRectMake(0, pasteY, self.view.frame.size.width, pasteH);
        
     
            CGFloat selectH = editH;
            
            CGFloat selectY = self.view.frame.size.height-selectH ;
            self.selectbtn.frame =CGRectMake(0, selectY, self.view.frame.size.width, selectH);
        
        CGRect customTabBarF = self.customTabBar.frame;
        customTabBarF.size.width = self.view.frame.size.width;
        
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
            
            customTabBarF.origin.y = self.navigationController.navigationBar.frame.size.height+20;
            
            
        }else{
            
            customTabBarF.origin.y = self.navigationController.navigationBar.frame.size.height;
        }
        
        self.customTabBar.frame = customTabBarF;
        
        
    }else{
   
            CGFloat editH = 60;
            
            CGFloat editY = self.view.frame.size.height-editH ;//+ 20
            self.editbtn.frame =CGRectMake(0, editY, self.view.frame.size.width, editH);
 
        
            
            CGFloat pasteH = 60;
            
            CGFloat pasteY = self.view.frame.size.height-pasteH  ;
            self.pasteTabBar.frame =CGRectMake(0, pasteY, self.view.frame.size.width, pasteH);
        
        
        
            
            CGFloat selectH = 60;
            
            CGFloat selectY = self.view.frame.size.height-selectH;
            self.selectbtn.frame =CGRectMake(0, selectY, self.view.frame.size.width, selectH);
        
    }
    
    
    
    
        
//        CGRect editTabBarF = self.editbtn.frame;
//        editTabBarF.size.height = KHorizontal;
//        editTabBarF.origin.y = self.view.frame.size.height-KHorizontal;
//        editTabBarF.size.width = self.view.frame.size.width;
    
       
        if (self.editbtn.hidden == NO) {
     
            CGRect editTabBarF = self.editbtn.frame;
            editTabBarF.size.height = KHorizontal;
            editTabBarF.origin.y = self.view.frame.size.height-KHorizontal;
            editTabBarF.size.width = self.view.frame.size.width;
            
            self.editbtn.frame = editTabBarF;
            
        }
        
        if (self.pasteTabBar.hidden == NO) {
       
            CGRect pasteTabBarF = self.pasteTabBar.frame;
            pasteTabBarF.size.height = KHorizontal;
            pasteTabBarF.origin.y = self.view.frame.size.height-KHorizontal;
            pasteTabBarF.size.width = self.view.frame.size.width;
            self.pasteTabBar.frame = pasteTabBarF;
            
        }
        
        if (self.selectbtn.hidden == NO) {
            
            CGRect selectTabBarF = self.selectbtn.frame;
            selectTabBarF.size.height = KHorizontal;
            selectTabBarF.origin.y = self.view.frame.size.height-KHorizontal;
            selectTabBarF.size.width = self.view.frame.size.width;
            self.selectbtn.frame = selectTabBarF;
            
        }

    
    
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    if (UIInterfaceOrientationIsLandscape(toInterfaceOrientation)) {//横屏
 
        CGRect customTabBarF = self.customTabBar.frame;
        
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
           customTabBarF.origin.y = self.navigationController.navigationBar.frame.size.height+20;
        }else{
        
            customTabBarF.origin.y = self.navigationController.navigationBar.frame.size.height-12 ;
        }
        
        self.customTabBar.frame = customTabBarF;

        
            for (UIButton *btn in [self.editbtn subviews]) {
                
                btn.selected = NO;
            }
            
        
    }else{
        
        CGRect customTabBarF = self.customTabBar.frame;
        customTabBarF.size.height = 54;
        customTabBarF.origin.y = 64;
        self.customTabBar.frame = customTabBarF;
  
            for (UIButton *btn in [self.editbtn subviews]) {
                
                btn.selected = NO;
            }
   
    }
}

- (void)sambaStatusChange:(NSNotification*) note
{
    if (![Reachability sambaStatus]) {
        
        self.datasource = nil;
        [self.tableView reloadData];
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Warming",nil) message:NSLocalizedString(@"Abnormal netWork connnection",nil) delegate:self cancelButtonTitle:NSLocalizedString(@"Done",nil) otherButtonTitles:nil, nil];
        
        [alert show];
        
    }
    [self.customTabBar removeFromSuperview];
    [self setupTabBar];
    [self setupTabBarChildBtns];
}

- (CGFloat)getCurrentDevice
{
    BOOL result =  UIDeviceOrientationIsLandscape([UIDevice currentDevice].orientation);
    
    if (result) return KHorizontal;

    return KVertical;
    
}


- (CurrentViewMode)getCurrentViewMode
{
    WFTabBarButton *btn = self.customTabBar.selectedButton;
    
    if ([btn.item.dirPath isEqualToString:self.rootSambaDockPath]){
        
        return CurrentViewDockMode;
        
    }else if ([btn.item.dirPath isEqualToString:self.rootSambaTFPath]){
        
        return CurrentViewTFMode;
        
    }else if ([btn.item.dirPath isEqualToString:self.rootSambaUSBPath]){
        
        return CurrentViewUSBMode;
        
    }
    
    return CurrentViewLoaclMode;
}

-(NSString*)currentViewPath{
    
    CurrentViewMode  mode = [self getCurrentViewMode];

    if(mode == CurrentViewDockMode){
        
        return self.rootSambaDockPath ;
        
    }else if([self getCurrentViewMode] == CurrentViewTFMode){
        
        return self.rootSambaTFPath;
        
    }else if([self getCurrentViewMode] == CurrentViewUSBMode){
        
        return self.rootSambaUSBPath;
        
    }else{
        
        return self.rootLocalPath ;
    }
 
    return nil;
    
}

#pragma mark 复制删除等功能

- (void)pasteAction
{
    BOOL selectedCount = self.selectedRows.count > 0;
    
    if (!selectedCount){
        
        [MBProgressHUD showError:NSLocalizedString(@"Please Select the file",nil)];
        return;
    }
    
    NSString *toPath = [self currentViewPath];
    NSString *destPath = nil;
    
    if (self.dirPath == nil) {
        
        destPath = toPath;
        
    }else {
        
        destPath = self.dirPath;
    }
    
    int num = 0;
    
    NSMutableArray *pasteArray = [NSMutableArray array];
    
    for (WFFile *file in self.selectedArray){
        NSString *filePath;
        BOOL isFolder = NO;
        
        if([file.ID isKindOfClass:[IGLSMBItem class]]){
            
            filePath = file.filePath;
            
            if ([file.ID isKindOfClass:[IGLSMBItemTree class]]) {
                
                isFolder = YES;
                
            }
        }
        if ([file.ID isKindOfClass:[ALAsset class]]){
            
            NSString *tmpPath = KWFFileUtilTempPath;
            
            BOOL ressult = [WFFileUtil fileCopyWithItem:file destPath:tmpPath];
            
            if (ressult) {
                
                filePath = [tmpPath stringByAppendingPathComponent:file.fileName];
            }
            
        }else if ([file.filePath hasPrefix:self.rootLocalPath]){
            
            filePath = file.filePath;
            
            if (file.fileType == NSFileTypeDirectory) {
                
                isFolder = YES;
            }
            
        }
        
        WFAction *action = [[WFAction alloc]initWithPath:filePath to:destPath];
        action.isFolder = isFolder;
        
        if(![WFActionTool canPaste:action]){
            continue;
        }
        
        if([WFActionTool haveSameName:action]){
            
            NSString *msg = NSLocalizedString(@"The Directory has the same file",nil);
            NSString *mtitle = NSLocalizedString(@"Warming",nil);
            
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:mtitle message:msg delegate:self cancelButtonTitle:NSLocalizedString(@"Done",nil) otherButtonTitles:nil, nil];
            
            alert.tag = 101;
            [alert show];
            continue;
        }
        
        action.isCut = self.cutFlag;
        IGLCopyAction *copyAction = [WFActionManager getCopyActionWithItem:action];
        
        [copyAction startAsynchronous];
        num++;
        
        WFPaste *paste = [[WFPaste alloc]init];
        
        paste.file = file;
        paste.filePath = [destPath stringByAppendingPathComponent:file.fileName];
        
        [pasteArray addObject:paste];
        
    }
    
    if (num > 0) {
        
        self.pasteArray = pasteArray;
        
        NSString *msg = NSLocalizedString(@"Already selected file,please check in the status list",nil);
        [MBProgressHUD showSuccess:msg];
        [[NSNotificationCenter defaultCenter] postNotificationName:kCntChangedNotification object:nil];
    }
    
    [UIView animateWithDuration:0.25 animations:^{
        
        self.pasteTabBar.hidden = YES;
        
        self.selectbtn.hidden = YES;
        
#pragma mark add cancel方法
        [self cancel];
    }];
    
    [self.selectedArray removeAllObjects];
    self.selectedRows = nil;
}

- (void)deleteAction
{
    BOOL selectedCount = self.selectedRows.count > 0;
    NSMutableArray *selectedArray = [NSMutableArray array];
    
    for (int i = 0; i < self.selectedRows.count; i++) {
        
        NSIndexPath *path = self.selectedRows[i];
        
        [selectedArray addObject:self.datasource[path.row]];
    }
    self.selectedArray = selectedArray;
    
    if (!selectedCount){
        
        [MBProgressHUD showError:NSLocalizedString(@"Please Select the file",nil)];
        return;
    }
    
    [self popMsgWithCount:self.selectedRows.count targert:NSLocalizedString(@"Delete",nil)];
    
    
    
}

- (void)cutAction
{
    BOOL selectedCount = self.selectedRows.count > 0;
    NSMutableArray *selectedArray = [NSMutableArray array];
    
    for (int i = 0; i < self.selectedRows.count; i++) {
        
        NSIndexPath *path = self.selectedRows[i];
        
        [selectedArray addObject:self.datasource[path.row]];
    }
    self.selectedArray = selectedArray;
    
    if (!selectedCount){
        
        [MBProgressHUD showError:NSLocalizedString(@"Please Select the file",nil)];
        return;
    }
    
    BOOL cutFlag = YES;
    self.cutFlag = cutFlag;
    
    NSString *msg = [NSString stringWithFormat:@"已经选中%u个文件",self.selectedRows.count];
    [MBProgressHUD showSuccess:msg];
    
    [UIView animateWithDuration:0.25 animations:^{
        
        [self.tableView setEditing:NO];
        [self cancel];
        self.editbtn.hidden = YES;
        self.pasteTabBar.hidden = NO;
        
    }];
}

- (void)selectAllFile
{
    
    if (self.datasource.count == 0) [MBProgressHUD showError:NSLocalizedString(@"No files Exist",nil)];
    
    if (!self.selected) {
        
        for (int row = 0; row < self.datasource.count; row++) {
            
            NSIndexPath *index = [NSIndexPath indexPathForRow:row inSection:0];
            [self.tableView deselectRowAtIndexPath:index animated:NO];
            
        }
        
        NSArray* selectedRows = [self.tableView indexPathsForSelectedRows];
        
        self.selectedRows = selectedRows;
        self.selectedArray = nil;
        
        self.selected = YES;
        
        
    }else{
        
        for (int row = 0; row < self.datasource.count; row++) {
            NSIndexPath *index = [NSIndexPath indexPathForRow:row inSection:0];
            [self.tableView selectRowAtIndexPath:index animated:NO scrollPosition: UITableViewScrollPositionNone];
        }
        
        NSArray* selectedRows = [self.tableView indexPathsForSelectedRows];
        
        self.selectedRows = selectedRows;
        self.selectedArray = self.datasource;
        self.selected = NO;
        
    }
    
}

#pragma mark tabbar 代理方法
- (void)selectBar:(WFSelectBar *)pasteBar didSelectedButtonFrom:(WFEditButton *)from to:(WFEditButton *)to
{
    if (to.tag == 0) {
        
        [self pasteAction];
        
    }else if(to.tag == 1){
        
        [self deleteAction];
    
    }else if(to.tag == 2){
        
        [self zip];
    
    }else if(to.tag == 3){
    
        [UIView animateWithDuration:0.25 animations:^{
            
            self.selectbtn.hidden = YES;
            [self.tableView setEditing:NO];
            
        }];
        
        [self.selectedArray removeAllObjects];
        
        self.selectedRows = nil;
    
    }

}

- (void)pasteBar:(WFPasteBar *)pasteBar didSelectedButtonFrom:(WFEditButton *)from to:(WFEditButton *)to
{
    self.pasteView = NO;
    
    if (to.tag == 0) {
        
        [self pasteAction];

    }else if(to.tag == 1){
        
        [UIView animateWithDuration:0.25 animations:^{
            
            self.pasteTabBar.hidden = YES;
#pragma mark add cancel
            [self cancel];
        }];
        [self.selectedArray removeAllObjects];
        self.selectedRows = nil;
  
    }

}

-(void)editBar:(WFEditBar *)editBar didSelectedButtonFrom:(WFEditButton *)from to:(WFEditButton *)to
{

    if ([to.titleLabel.text isEqualToString:NSLocalizedString(@"Copy",nil)]) {
        
        BOOL selectedCount = self.selectedRows.count > 0;
        NSMutableArray *selectedArray = [NSMutableArray array];
        
        for (int i = 0; i < self.selectedRows.count; i++) {
            
            NSIndexPath *path = self.selectedRows[i];
            
            [selectedArray addObject:self.datasource[path.row]];
            
        }
        self.selectedArray = selectedArray;
 
        if (!selectedCount){
            
            [MBProgressHUD showError:NSLocalizedString(@"Please Select the file",nil)];
            
            return;
        }
        
        NSString *msg =nil;
        
        if (selectedArray.count == 1) {
            msg = NSLocalizedString(@"Have selected one file",nil);
        }else {
            msg = [NSString stringWithFormat:NSLocalizedString(@"Have selected %d files",nil),self.selectedRows.count];
        }
        
 
        [MBProgressHUD showSuccess:msg];
        
        [UIView animateWithDuration:0.25f animations:^{
            
            if (self.pasteTabBar.hidden == YES) {
                self.pasteTabBar.hidden = NO;
            }
 
            self.pasteView = YES;
            
            self.editbtn.hidden = YES;
            
            [self.tableView setEditing:NO];
            
//            [self cancel];
            
        }];
        
        
    }else if ([to.titleLabel.text isEqual:NSLocalizedString(@"All",nil)]){
        
        [self selectAllFile];
        
    }else if ([to.titleLabel.text isEqualToString:NSLocalizedString(@"Delete",nil)]){
        
        [self deleteAction];
        
        [UIView animateWithDuration:0.25 animations:^{
            
            [self.tableView setEditing:NO];
            [self cancel];
            
        }];
        
    }else if ([to.titleLabel.text isEqualToString:NSLocalizedString(@"Cut",nil)]){
        
        [self cutAction];
        
    }else if ([to.titleLabel.text isEqualToString:NSLocalizedString(@"All!",nil)]){
        
        if (self.datasource.count == 0)
            
            [MBProgressHUD showError:NSLocalizedString(@"No files Exist",nil)];

        if (!self.selected) {
            
            for (int row = 0; row < self.datasource.count; row++) {
                
                NSIndexPath *index = [NSIndexPath indexPathForRow:row inSection:0];
                [self.tableView deselectRowAtIndexPath:index animated:NO];
                
            }
            
            NSArray* selectedRows = [self.tableView indexPathsForSelectedRows];
            
            self.selectedRows = selectedRows;
            
            [self.selectedArray removeAllObjects];
            
            self.selected = YES;
            
            
        }else{
            
            for (int row = 0; row < self.datasource.count; row++) {
                NSIndexPath *index = [NSIndexPath indexPathForRow:row inSection:0];
                [self.tableView selectRowAtIndexPath:index animated:NO scrollPosition: UITableViewScrollPositionNone];
            }
            
            NSArray* selectedRows = [self.tableView indexPathsForSelectedRows];
            
            self.selectedRows = selectedRows;
            self.selectedArray = self.datasource;
            self.selected = NO;
            
        }
        
    }else if([to.titleLabel.text isEqualToString:NSLocalizedString(@"encrypt",nil)]){
     
        [self zip];
        
//        if (self.popupMenu == nil) {
//            [self setupMore];
//        }
//
//        CGFloat rectX = self.tableView.frame.size.width -80;
//        CGFloat rectY = self.tableView.frame.size.height-KHorizontal-10;
//        CGRect rect = CGRectMake(rectX, rectY, 0, 0);
//        
//        self.popupMenu.hidden = NO;
//     
//        self.popupMenu.arrowDirection = UIMenuControllerArrowDefault;
//        [self.popupMenu showInView:self.navigationController.view  targetRect:rect animated:YES];

        return;
        
    }

}


#pragma mark 状态列表

-(void)statusView
{
    WFStatusViewController *status = [[WFStatusViewController alloc]init];
//    WFStatusViewController *status = [[WFStatusViewController alloc]initWithFiles:[self.selectedArray copy]];
    self.customTabBar.hidden = YES;
   
    [self cancel];
    [self.tableView setEditing:NO];
    self.navigationController.navigationItem.title = NSLocalizedString(@"Status",nil);;
    [self.navigationController pushViewController:status animated:YES];
}

#pragma mark UIAlertView 的代理方法

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    
    if (alertView.tag == 100) {
        
        if (buttonIndex == 0) {
            
            [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
            [self.selectedArray removeAllObjects];
            
            self.selectedRows = nil;
            
            [UIView animateWithDuration:0.25 animations:^{
                
                if (!self.selectbtn.hidden) {
                    self.selectbtn.hidden = YES;
                }
                
                if (!self.editbtn.hidden) {
                    self.editbtn.hidden = YES;
                }
                
            }];
            
            return;
        }
        NSMutableArray *deleteList = [NSMutableArray array];
        
        [deleteList addObjectsFromArray:self.selectedArray];
        
        BOOL issuccess;
        
        for (int index = 0; index < deleteList.count; index++) {
            
            WFFile *item = [[WFFile alloc]init];
            item = deleteList[index];
            
            if([item.ID isKindOfClass:[ALAsset class]]){
                
                [MBProgressHUD showError:NSLocalizedString(@"Access restrictions,Deleted failured",nil)];
                
                return;
            }
            
            
            NSString *filePath;
            if([item.ID isKindOfClass:[IGLSMBItem class]]){
                
                filePath = item.filePath;
            
            }
            
            if([item.filePath hasPrefix:self.rootLocalPath]){
                
                filePath = item.filePath;
            }
            
            issuccess = [WFActionTool removeFileAtPath:filePath];
            if(!issuccess) break;
            
            [MBProgressHUD showSuccess:NSLocalizedString(@"Deleted Successfully",nil)];

            
            [self.datasource removeObject:item];
       
            
        }
        for (UIButton *btn in self.editbtn.subviews) {
            
            btn.selected = NO;
            
        }
        [self.tableView reloadData];
        
        [UIView animateWithDuration:0.25 animations:^{
            
            if (!self.selectbtn.hidden) {
                self.selectbtn.hidden = YES;
            }
            
            if (!self.editbtn.hidden) {
                self.editbtn.hidden = YES;
            }
            
        }];
        
        self.selectedRows = nil;
        
        [self.selectedArray removeAllObjects];

        return;
    
        
    }else if(alertView.tag == 101){
        
        for (UIButton *btn in self.editbtn.subviews) {
            
            btn.selected = NO;
            
        }
    
        [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
        [self.selectedArray removeAllObjects];
        
        self.selectedRows = nil;
    
    }else if(alertView.tag == 103){
    
        if (buttonIndex == 0) return;
 
        NSString *filename = [alertView textFieldAtIndex:0].text;
        NSString *destName =nil;
        NSLog(@"self.extension = %@",self.extension);
        if (![self.extension isEqualToString:@""]) {
            
            destName = [NSString stringWithFormat:@"%@.%@",filename,self.extension];
        }else{
            
            destName = filename;
        }
  
        WFFile *file = self.datasource[self.indexpath.row];
        
        file.fileName= destName;
        
        NSString *filePath = file.filePath;
        
        
        if ([file.ID isKindOfClass:[ALAsset class]]) {
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Warming",nil) message:NSLocalizedString(@"Access restrictions,Modified failured",nil) delegate:self cancelButtonTitle:NSLocalizedString(@"Done",nil) otherButtonTitles:nil, nil];
            
            [alert show];
            
        }else {
            
            [WFActionTool renameFileAtPaht:filePath rename:destName];
            
            [self.datasource removeObjectAtIndex:self.indexpath.row];
            
            NSString *newPath = [[filePath stringByDeletingSMBLastPathComponent] stringByAppendingSMBPathComponent:destName];
            
            WFFile *item = [[WFFile alloc]initWithPath:newPath file:file];
            [self.datasource insertObject:item atIndex:self.indexpath.row];
        
            NSIndexPath *path = [NSIndexPath indexPathForRow:self.indexpath.row inSection:0];
            [self.tableView reloadRowsAtIndexPaths:@[path] withRowAnimation:UITableViewRowAnimationBottom];
            
        }

    
    }else if(alertView.tag == 120){
    
        if (buttonIndex == 0)return;
        
        
        NSString *fileName = [alertView textFieldAtIndex:0].text;
        
        if (!fileName.length) return;
        
        if (![fileName isValidateFolderName]) {
            
            [MBProgressHUD showError:NSLocalizedString(@"Invalid Name",nil)];
            return;
        }
        
        NSString *dirpath = [self currentViewPath];
        NSString *filePath = [dirpath stringByAppendingSMBPathComponent:fileName];
        
        if([WFActionTool isExistsAtPath:filePath]){
            
            [MBProgressHUD showError:NSLocalizedString(@"The Directory has the same Folder,please rename again",nil)];
            
            return;
            
        }else if([WFActionTool createAtPaht:filePath]){
            
            [MBProgressHUD showSuccess:NSLocalizedString(@"Create Successfully",nil)];
            
            WFFile *file = [[WFFile alloc] initWithName:fileName filePath:filePath isEncrypt:NO];
            
            [self.datasource addObject:file];
            
            [self cancel];
            
            [self.tableView reloadData];
            
        }else{
            
            [MBProgressHUD showError:NSLocalizedString(@"Create Failed",nil)];
        }
    }else if(alertView.tag ==110){
    
        if (buttonIndex ==0)return;
        [MBProgressHUD showMessage:@"正在压缩，请稍等......"];
       
        NSString *zipFileName = [alertView textFieldAtIndex:0].text;
        
        NSString *filePath =nil;
//        if (self.dirPath == nil) {
        
            filePath = [[WFFileUtil getDocumentPath] stringByAppendingPathComponent:@"加密区"];
        
        if (![WFActionTool isExistsAtPath:filePath]) {
            
            [WFActionTool createAtPaht:filePath];
            
        }

        NSString *zipPath = [filePath stringByAppendingSMBPathComponent:zipFileName];
        
        if ([WFFileUtil isExistsAtPath:zipPath]) {
            
            [MBProgressHUD hideHUD];
            
            [MBProgressHUD showError:NSLocalizedString(@"File exists, please rename",nil)];
            
            return;
            
        }
        
        NSMutableArray *deleteList = [NSMutableArray array];
        
        [deleteList addObjectsFromArray:self.selectedArray];
   
        for (int index = 0; index < deleteList.count; index++) {
            WFFile *item = [[WFFile alloc]init];
            item = deleteList[index];
            
            [WFActionTool removeFileAtPath:item.filePath];
            
            [self.datasource removeObject:item];
        }
        
        [MBProgressHUD hideHUD];
        [MBProgressHUD showSuccess:NSLocalizedString(@"Decryption Successfully",nil)];
       
        [self.tableView reloadData];
        
        
    }else if(alertView.tag == 111||alertView.tag == 115){
        
     
        if (buttonIndex == 0)return;

   
    }else if(alertView.tag == 112){
    
        if (buttonIndex == 0)return;
        
        BOOL selectedCount = self.selectedRows.count > 0;
        NSMutableArray *selectedArray = [NSMutableArray array];
        
        for (int i = 0; i < self.selectedRows.count; i++) {
            
            NSIndexPath *path = self.selectedRows[i];
            
            [selectedArray addObject:self.datasource[path.row]];
    
        }
        
        self.selectedArray = selectedArray;
        
        if (!selectedCount){
            
            [MBProgressHUD showError:NSLocalizedString(@"Please Select the file",nil)];
            
            return;
        }
  
        NSString *destPath = [[WFFileUtil getDocumentPath] stringByAppendingPathComponent:@"云盘坞"];
     
        int num = 0;
    
        for (WFFile *file in self.selectedArray){
            NSString *filePath;
            BOOL isFolder = NO;
            
            if([file.ID isKindOfClass:[IGLSMBItem class]]){
                
                filePath = file.filePath;
                
                if ([file.ID isKindOfClass:[IGLSMBItemTree class]]) {
                    
                    isFolder = YES;
                    
                }
            }
   
            WFAction *action = [[WFAction alloc]initWithPath:filePath to:destPath];
            action.isFolder = isFolder;
            
            if(![WFActionTool canPaste:action]){
                continue;
            }
            
            if([WFActionTool haveSameName:action]){
                
                NSString *msg = NSLocalizedString(@"The Directory has the same file",nil);
                NSString *mtitle = NSLocalizedString(@"Warming",nil);
                
                UIAlertView *alert = [[UIAlertView alloc]initWithTitle:mtitle message:msg delegate:self cancelButtonTitle:NSLocalizedString(@"Done",nil) otherButtonTitles:nil, nil];
                
                alert.tag = 101;
                [alert show];
                continue;
            }
            
            action.isCut = self.cutFlag;
            IGLCopyAction *copyAction = [WFActionManager getCopyActionWithItem:action];
            
            [copyAction startAsynchronous];
            num++;
  
        }
        
        if (num > 0) {
 
            
            NSString *msg = NSLocalizedString(@"Already selected file,please check in the status list",nil);
            [MBProgressHUD showSuccess:msg];
            [[NSNotificationCenter defaultCenter] postNotificationName:kCntChangedNotification object:nil];
        }
        
        [self.selectedArray removeAllObjects];
        self.selectedRows = nil;
        
        return;

        
    }else if(alertView.tag == 114){
        NSLog(@"zhangjian");
    }else if (alertView.tag == 115){
    
        if (buttonIndex == 0)return;
    }
   
}

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0){
    
        [self.selectedArray removeAllObjects];
        self.selectedRows = nil;
        return;
    }
    
    NSMutableArray *deleteList = [NSMutableArray array];
    
    [deleteList addObjectsFromArray:self.selectedArray];
    
    BOOL issuccess;
    
    for (int index = 0; index < deleteList.count; index++) {
        
        WFFile *item = [[WFFile alloc]init];
        item = deleteList[index];
        
        if([item.ID isKindOfClass:[ALAsset class]]){
            
            [MBProgressHUD showError:NSLocalizedString(@"Access restrictions,Deleted failured",nil)];
            
            return;
        }
        
        NSString *filePath;
        if([item.ID isKindOfClass:[IGLSMBItem class]]){
            
            filePath = item.filePath;
        }
        
        if([item.filePath hasPrefix:self.rootLocalPath]){
            
            filePath = item.filePath;
        }
        
        issuccess = [WFActionTool removeFileAtPath:filePath];
        if(!issuccess) break;
        
        [MBProgressHUD showSuccess:NSLocalizedString(@"Deleted Successfully",nil)];
        
        //        NSIndexPath *path = self.selectedRows[index];
        
        [self.datasource removeObject:item];
        //        [self.datasource removeObjectAtIndex:path.row];
        //        [self.tableView deleteRowsAtIndexPaths:@[path] withRowAnimation:UITableViewRowAnimationBottom];
        
    }
    [self.tableView reloadData];
    
    self.selectedRows = nil;
    
    [self.selectedArray removeAllObjects];
    return;
    
    

}

- (void)popMsgWithCount:(NSInteger)count targert:(NSString *)title
{
    NSString *actionTitle =@"";
    if (count == 1) {
        
        if ([title isEqualToString:NSLocalizedString(@"Delete",nil)]) {
            
            actionTitle = NSLocalizedString(@"Are you sure delete the file?",nil);
            
            
        }else{
            
            
            actionTitle = [NSString stringWithFormat:NSLocalizedString(@"Are you sure delete the %d file?",nil),count];
        }
        
    }else if (count > 1){
        
        if ([title isEqual:NSLocalizedString(@"Delete",nil)]) {
            
             actionTitle = [NSString stringWithFormat:NSLocalizedString(@"Are you sure delete the %d file?",nil),count];
            
        }else{
            
            actionTitle = @"确定要移动这些文件？";
        }
        
    }
    
    NSString *cancelTitle =NSLocalizedString(@"Cancel",nil);
    NSString *okTitle = NSLocalizedString(@"Done",nil);;
    NSString *dtitle = NSLocalizedString(@"Warming",nil);
    
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:dtitle message:actionTitle delegate:self cancelButtonTitle:cancelTitle otherButtonTitles:okTitle, nil];
    
    alert.tag = 100;
    
    [alert show];
   
}

- (void)getDataFromDocument:(NSString *)filePath
{
    
    NSString *tmpFile = [filePath stringByAppendingString:@"/"];
    
    dispatch_queue_t queue = dispatch_queue_create("WFDOCK", DISPATCH_QUEUE_SERIAL);
    dispatch_async(queue, ^{
        [self.datasource removeAllObjects];
        NSFileManager* manager = [NSFileManager defaultManager];
        NSError *err=nil;
        if (![manager fileExistsAtPath:tmpFile])
            return ;
        
        NSArray *directoryContent = [manager contentsOfDirectoryAtPath:tmpFile error:&err];
        
        if (err) return;
        
        for(NSString *fileName in directoryContent) {
            
            if ([fileName isEqualToString:@".config"]||[fileName isEqualToString:@".tmp"]) continue;
            
            WFFile *fileItem = [[WFFile alloc]initWithName:fileName filePath:tmpFile withType:nil];
            
            [self.datasource addObject:fileItem];
            
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [self.tableView reloadData];
            
        });
        
    });
    
}


-(void)zip
{

    BOOL selectedCount = self.selectedRows.count > 0;
    NSMutableArray *selectedArray = [NSMutableArray array];
    
    for (int i = 0; i < self.selectedRows.count; i++) {
        
        NSIndexPath *path = self.selectedRows[i];
        
        [selectedArray addObject:self.datasource[path.row]];
    }
    self.selectedArray = selectedArray;
    
    if (!selectedCount){
        
        [MBProgressHUD showError:NSLocalizedString(@"Please Select the file",nil)];
        
        return;
    }
    
    for (WFFile *file in self.selectedArray) {
        
        if (file.fileType == NSFileTypeDirectory||[file.ID isKindOfClass:[IGLSMBItemTree class]]) {
            
            [MBProgressHUD showError:NSLocalizedString(@"The selected file contains folders, files of this type of files does not support encryption, please select again",nil)];
            return;
        }
        
        if([[file.fileName pathExtension] isEqualToString:@"lock"]){
        
            [MBProgressHUD showError:NSLocalizedString(@"The selected file contains encrypted files, please select again",nil)];
            return;
        }
   
    }

    [UIView animateWithDuration:0.25 animations:^{
        
        if (!self.selectbtn.hidden) {
            self.selectbtn.hidden = YES;
        }
        
        if (!self.editbtn.hidden) {
            self.editbtn.hidden = YES;
        }
        
    }];
    
    PAPasscodeViewController *passcodeViewController = [[PAPasscodeViewController alloc] initForAction:PasscodeActionSet];
    passcodeViewController.delegate = self;
    
    [self presentViewController:passcodeViewController animated:YES completion:nil];
    
}

#pragma mark PAPasscodeViewController 的代理方法

- (void)PAPasscodeViewControllerDidCancel:(PAPasscodeViewController *)controller
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)PAPasscodeViewControllerDidSetPasscode:(PAPasscodeViewController *)controller {
    
    [self dismissViewControllerAnimated:YES completion:^() {
        
        NSString *msg =nil;
        NSString *zipName = nil;
        
        self.isEncrypt = YES;
       
        self.passcode = controller.passcode;
        
        WFFile *file = [[WFFile alloc]init];
        
        if (self.selectedArray.count == 1) {
            
            file = self.selectedArray[0];
            
            msg = NSLocalizedString(@"Have selected one file",nil);
            zipName = file.fileName;
            
            
        }else {
            
            msg = [NSString stringWithFormat:NSLocalizedString(@"Have selected %d files",nil),self.selectedRows.count];
        }
        
        NSString *filePath =nil;
        
        Byte *buffer = NULL;
        
        for (WFFile *file in self.selectedArray) {
            
            if ([file.ID isKindOfClass:[IGLSMBItem class]]) {
          
                NSData *data = [[IGLSMBProvier alloc] dataWithPath:file.filePath];
                
                
                filePath = [[WFFileUtil getDocumentPath] stringByAppendingPathComponent:NSLocalizedString(@"WiFiDock",nil)];
                
                [self zipWithFile:file Data:data to:filePath];
  
            }
            
            if ([file.ID isKindOfClass:[ALAsset class]]) {
                
                ALAsset *asset = file.ID;
                ALAssetRepresentation *rep = [asset defaultRepresentation];
                buffer = (Byte*)malloc((unsigned long)rep.size);
//                unsigned long count = (unsigned long)rep.size;
                
                NSUInteger buffered = [rep getBytes:buffer fromOffset:0.0 length:((unsigned long)rep.size) error:nil];
                NSData *data = [NSData dataWithBytesNoCopy:buffer length:buffered freeWhenDone:YES];
                
                filePath = [[WFFileUtil getDocumentPath] stringByAppendingPathComponent:NSLocalizedString(@"Encryption area",nil)];
                
                [self zipWithFile:file Data:data to:filePath];
      
            }else{
  
                if (file.fileType == NSFileTypeRegular) {
                    
                    filePath = [[WFFileUtil getDocumentPath] stringByAppendingPathComponent:NSLocalizedString(@"Encryption area",nil)];
                    
                    NSData *data = [NSData dataWithContentsOfFile:file.filePath];
                    
                    [self zipWithFile:file Data:data to:filePath];
                    
                    
                    
                }else if(file.fileType == NSFileTypeDirectory){
                    
                    [MBProgressHUD hideHUD];
                    [MBProgressHUD showError:NSLocalizedString(@"Does not support file encryption",nil)];
                    
                    return ;
                    /*
                     NSFileManager *mgr = [NSFileManager defaultManager];
                     
                     NSArray *subPaths = [mgr subpathsAtPath:path];
                     
                     for (NSString *subPath in subPaths) {
                     
                     NSString *fullPath = [path stringByAppendingPathComponent:subPath];
                     ZipWriteStream *pStream = [zFile writeFileInZipWithName:file.fileName fileDate:date compressionLevel:ZipCompressionLevelNone password:self.passcode crc32:99];
                     NSData *data = [NSData dataWithContentsOfFile:fullPath];
                     
                     [pStream writeData:data];
                     [pStream finishedWriting];
                     }
                     
                     [zFile close];
                     */
                    
                }
            }
    
        }
        
        NSMutableArray *deleteList = [NSMutableArray array];
        
        [deleteList addObjectsFromArray:self.selectedArray];
        
        for (int index = 0; index < deleteList.count; index++) {
            WFFile *item = [[WFFile alloc]init];
            item = deleteList[index];
            
            [WFActionTool removeFileAtPath:item.filePath];
            
            [self.datasource removeObject:item];
        }
        
        [self.tableView reloadData];
        
        [MBProgressHUD hideHUD];
        [MBProgressHUD showSuccess:NSLocalizedString(@"Encryption is completed",nil)];
        [self cancel];
        
    }];
}

- (void)PAPasscodeViewControllerDidChangePasscode:(PAPasscodeViewController *)controller {
    [self dismissViewControllerAnimated:YES completion:^() {
        
    }];
}

- (void)PAPasscodeViewControllerDidEnterPasscode:(PAPasscodeViewController *)controller {
    [self dismissViewControllerAnimated:YES completion:^() {
        
        NSString *passcode = controller.passcode;
        NSString *filePath =nil;
         self.deleteFlag = YES;
        if (self.encryptFlag) {
            
            filePath = [[WFFileUtil getDocumentPath]
                  stringByAppendingPathComponent:NSLocalizedString(@"Decryption area",nil)];
            
        }else{
   
            filePath = [[WFFileUtil getDocumentPath] stringByAppendingPathComponent:@".tmp"];
        }
        
        if (![WFActionTool isExistsAtPath:filePath]) {
            [WFActionTool createAtPaht:filePath];
        }
        
        ZipFile *zFile = [[ZipFile alloc]initWithFileName:controller.filePath mode:ZipFileModeUnzip];
        
        [zFile goToFirstFileInZip];
        
        BOOL continueReading = YES;
        BOOL errorFlag = NO;
        
        while (continueReading) {
            
            FileInZipInfo *info = [zFile getCurrentFileInZipInfo];
            
            ZipReadStream *rStream = [zFile readCurrentFileInZipWithPassword:passcode];
            
            NSMutableData *data = [[NSMutableData alloc]initWithLength:info.length];
            
            @try {
                
                [rStream readDataWithBuffer:data];
            }
            @catch (NSException *exception) {
                
                [MBProgressHUD hideHUD];
                [MBProgressHUD showError:NSLocalizedString(@"Decryption failure",nil)];
                errorFlag = YES;
                break;
            }
            @finally {
                
            }
            
            NSString *writePath = [filePath stringByAppendingPathComponent:info.name];
            
            if ([WFActionTool isExistsAtPath:writePath]) {
                
                int count = [self getDataFromPath:writePath];
                
                NSString *tmpName = [info.name stringByDeletingPathExtension];
                NSString *file = nil;
                if (count == 0) {
                    
                    file = [NSString stringWithFormat:@"%@",tmpName];
                    
                }else{
                    
                    file = [NSString stringWithFormat:@"%@(%d)",tmpName,count];
                }
                
                
                NSString *fileName = [NSString stringWithFormat:@"%@.%@",file,[info.name pathExtension]];
                
                writePath = [filePath stringByAppendingPathComponent:fileName];
                
            }
            NSError *error = nil;
            [data writeToFile:writePath atomically:YES];
            
            if (error) {
                
                [MBProgressHUD showError:[NSString stringWithFormat:@"%@",error.localizedDescription]];
            }
            
            @try {
                
                [rStream finishedReading];
            }
            @catch (NSException *exception) {
                
                errorFlag = YES;
                [WFActionTool removeFileAtPath:writePath];
                
                [MBProgressHUD hideHUD];
                
                NSString *title = NSLocalizedString(@"Warming",nil);
                NSString *msg = NSLocalizedString(@"Wrong password",nil);
                
                NSString *ok = NSLocalizedString(@"Done",nil);
                UIAlertView *alert = [[UIAlertView alloc]initWithTitle:title message:msg delegate:self cancelButtonTitle:ok otherButtonTitles:nil, nil];
                alert.tag = 111;
                
                [alert show];
                
                break;
            }
            @finally {
     
            }
            
            continueReading = [zFile goToNextFileInZip];
            
        }
        
        [MBProgressHUD hideHUD];
        
        [zFile close];
        
        
        
        if (!errorFlag) {
            
            [MBProgressHUD showSuccess:NSLocalizedString(@"Decryption Successfully",nil)];
            
            if (!self.encryptFlag) {
                
                NSMutableArray *encryptArray = [NSMutableArray array];
                
                encryptArray = [self getFileFromPath:filePath];
                
                self.datasource = encryptArray;
                
                WFFile *item =  self.datasource[0];
                NSInteger row = [self.datasource indexOfObject:item];
                NSIndexPath *path = [NSIndexPath indexPathForRow:row inSection:0];
                
                [self tableView:self.tableView didSelectRowAtIndexPath:path];
                self.datasource = nil;
                
                
            }
            self.encryptFlag = NO;
            
        }
        
    }];
}

- (void)zipWithFile:(WFFile *)file Data:(NSData *)data to:(NSString *)filePath
{

    NSInteger result = [self fileCountFromPath:filePath fileName:file.fileName];
    NSString *fileName = nil;
    if (result == 0) {
        
        fileName = [NSString stringWithFormat:@"%@",[file.fileName stringByDeletingPathExtension]];
    }else{
        
        fileName = [NSString stringWithFormat:@"%@(%d)",[file.fileName stringByDeletingPathExtension],result];
    }
    
    NSString *zipFileName = [fileName stringByAppendingString:@".lock"];
    
    if (![WFActionTool isExistsAtPath:filePath]) {
        
        [WFActionTool createAtPaht:filePath];
        
    }
    
    NSString *zipPath = [filePath stringByAppendingSMBPathComponent:zipFileName];
    
    ZipFile *zFile = [[ZipFile alloc]initWithFileName:zipPath mode:ZipFileModeCreate];
    
   
    NSDate *date = [NSDate date];
    
    ZipWriteStream *pStream = [zFile writeFileInZipWithName:file.fileName fileDate:date compressionLevel:ZipCompressionLevelNone password:self.passcode crc32:99];
    
    [pStream writeData:data];
    [pStream finishedWriting];
    
    [zFile close];
}

- (NSMutableArray *)getFileFromPath:(NSString *)path
{

    NSFileManager* manager = [NSFileManager defaultManager];
    NSError *err=nil;
    NSMutableArray *encryptArray = [NSMutableArray array];
    if (![manager fileExistsAtPath:path]) return nil;
    
    NSArray *directoryContent = [manager contentsOfDirectoryAtPath:path error:&err];
    for(NSString *fileName in directoryContent) {
        
        WFFile *fileItem = [[WFFile alloc]initWithName:fileName filePath:path withType:nil];
        
        [encryptArray addObject:fileItem];
        
    }
    
    return encryptArray;
}

- (NSInteger )fileCountFromPath:(NSString *)path fileName:(NSString *)fileName
{
    NSFileManager *manager = [NSFileManager defaultManager];
    
    NSError *err = nil;
    
    NSArray *directoryContent = [manager contentsOfDirectoryAtPath:path error:&err];
    
    int count = 0;
    
    NSString *Name = [fileName stringByDeletingPathExtension];
    
    for (NSString *file in directoryContent) {
        
        NSString *tmpName = [file stringByDeletingPathExtension];
        
        if ([tmpName rangeOfString:Name].location != NSNotFound ) {
            
            count++;
        }
        
    }
    
    return count;
    
}

- (NSInteger )getDataFromPath:(NSString *)path
{
    NSString *tmppath = [path stringByDeletingLastPathComponent];
    NSString *fileName = [path lastPathComponent];
    NSString *name = [fileName stringByDeletingPathExtension];
    
    NSFileManager *manager = [NSFileManager defaultManager];
    
    NSError *err = nil;
    
    NSArray *directoryContent = [manager contentsOfDirectoryAtPath:tmppath error:&err];
    
    int count = 0;
    
    for (NSString *file in directoryContent) {
        
        NSString *tmpName = [file stringByDeletingPathExtension];
        
        if ([tmpName hasPrefix:name]) {
            
            count++;
        }
    }
    
    return count;
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
