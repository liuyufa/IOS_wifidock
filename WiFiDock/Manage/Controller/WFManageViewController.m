//
//  WFManageViewController.m
//  WiFiDock
//
//  Created by apple on 14-12-2.
//  Copyright (c) 2014年 cn.hualu.WiFiDock. All rights reserved.
//

#import "WFManageViewController.h"
#import "WFImageViewController.h"
#import "WFFileUtil.h"
#import "WFFile.h"
#import "KxMovieViewController.h"
#import "IGLSMBProvier.h"
#import "WFActionTool.h"
#import "WFPreviewController.h"
#import "AppDelegate.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import <AVFoundation/AVFoundation.h>
#import "NSString+Ex.h"
#import "WFMoviePlayerController.h"
#import "WFSettingItem.h"
#import "WFSettingArrowItem.h"
#import "UIImage+IW.h"




@interface WFManageViewController ()<UINavigationControllerDelegate,UIImagePickerControllerDelegate,UIAlertViewDelegate,WFMoviePlayerControllerDelegate>

@property (nonatomic, strong) WFMoviePlayerController *playerController;
@property (nonatomic, assign)BOOL loop;
@end

@implementation WFManageViewController

- (void)viewDidLoad
{
    
    [super viewDidLoad];
    
    self.navigationItem.title = NSLocalizedString(@"Manage",nil);
    self.deleteFlag = NO;
    
    UIBarButtonItem *btn1 = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemCamera target:self action:@selector(openCamera)];
    btn1.tintColor = WFColor(41, 41, 41);
    
//    UIBarButtonItem *space =[[UIBarButtonItem alloc]initWithTitle:@" " style:UIBarButtonItemStyleBordered target:nil action:nil];
//    space.width = 5;
//    space.enabled = NO;
    
    UIBarButtonItem *btn2 = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemCompose target:self action:@selector(getMore)];
    btn2.tintColor = WFColor(41, 41, 41);
    
    UIBarButtonItem *btn0 = [[UIBarButtonItem alloc]initWithImage:[UIImage imageWithName:@"icon_toolbar_status"] style:UIBarButtonItemStylePlain target:self action:@selector(statusView)];
     btn0.tintColor = WFColor(41, 41, 41);
    
    self.navigationItem.rightBarButtonItems = @[btn2,btn1,btn0];
    
    NSNotificationCenter *defaultCenter = [NSNotificationCenter defaultCenter];
    
    [defaultCenter addObserver:self selector:@selector(deleteTmp) name:kDelete object:nil];
    
}

- (void)deleteTmp
{
    if (self.deleteFlag) {
        
        NSString *tmpPath = [[WFFileUtil getDocumentPath] stringByAppendingPathComponent:@".tmp"];
        
        self.encryptFlag = NO;
        
        if ([WFActionTool isExistsAtPath: tmpPath]) {
            
            [WFActionTool removeFileAtPath:tmpPath];
            
            
        }
        
        NSString *dirPath=nil;
        if (self.dirPath==nil) {
            dirPath = [WFFileUtil getDocumentPath];
        }else{
            dirPath = self.dirPath;
        }
        [self getDataFromDocument:dirPath];
    }
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [super tableView:tableView didSelectRowAtIndexPath:indexPath];
    
    if(self.tableView.editing)return;
    
    WFFile *file = self.datasource[indexPath.row];

    self.index = indexPath.row;

    NSString *filePath = file.filePath;
    
    
    if ([file.ID isKindOfClass:[IGLSMBItem class]]) {
  
        if ([file.ID isKindOfClass:[IGLSMBItemTree class]]) {
            
            self.dirPath = filePath;
            
            WFDataSource *data = [WFDataSource dataSourceWithRootPath:filePath fileType:@"all"];
            [data loadDirectoryData];
            
            self.datasource = data.datasource;
            
            [self.tableView reloadData];
            
        }else if([file.ID isKindOfClass:[IGLSMBItemFile class]]){
            
            NSString *extension = [file.fileName pathExtension];
            
            if ([WFFileUtil isAudio:extension]||[WFFileUtil isVideo:extension]) {
                
                NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
                
                NSString *url = [NSString stringWithFormat:@"%@:%d%@",LOCAL_HTTP_PATH,LOCAL_HTTP_PORT,[file.filePath  stringByReplacingOccurrencesOfString:SAMBA_URL withString:@""]];
                
                url = [url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
                
                if ([url.pathExtension isEqualToString:@"wmv"])
                    parameters[KxMovieParameterMinBufferedDuration] = @(5.0);
                
                if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
                    parameters[KxMovieParameterDisableDeinterlacing] = @(YES);
                KxMovieViewController *vc = [KxMovieViewController movieViewControllerWithContent:nil current:url parameters:parameters withIndex:self.index];
                
                [self presentViewController:vc animated:NO completion:nil];
                
            }else if([WFFileUtil isDoc:extension]||[WFFileUtil isImage:extension]){
                
                self.loop = NO;
                NSString *despath = [KWFFileUtilTempPath stringByAppendingPathComponent:[file.filePath lastPathComponent]];
                
                NSString *sourcePath = file.filePath ;
                
                [[IGLSMBProvier sharedSmbProvider] copySMBPath:sourcePath localPath:despath overwrite:YES block:^(id result) {
                    self.loop = YES;
                }];
                
                while(!self.loop){
                    
                    [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
                }
                
                NSMutableArray *array = [NSMutableArray array];
                [array addObject:file];
                WFPreviewController *preview = [[WFPreviewController alloc]initWithURL:[NSURL fileURLWithPath:despath] query:[array copy] index:self.index];
                
                [self presentViewController:preview animated:YES completion:nil];
                
//                [self.navigationController pushViewController:preview animated:YES];
    
            }else if ([[file.fileName pathExtension]isEqualToString:@"lock"]){
            
                [MBProgressHUD showError:@"WiFiDock端不支持解密功能，请拷贝到本地中解密"];
                return;
                
            }
            
        }
    }else {
        
        if (file.fileType == NSFileTypeDirectory) {
            
            if ([file.fileName isEqual:NSLocalizedString(@"Localtion Image",nil)] || [file.fileName isEqual:NSLocalizedString(@"Localtion Video",nil)] || [file.fileName isEqual:NSLocalizedString(@"WiFiDock",nil)]) {
                
                [self.datasource removeAllObjects];
                
                if ([file.fileName isEqualToString:NSLocalizedString(@"Localtion Image",nil)]) {
                    
                    self.dirPath = [[WFFileUtil getDocumentPath] stringByAppendingPathComponent:NSLocalizedString(@"Localtion Image",nil)];
                    
                    [self getDateFromAssetsLibrary:@"photo"];
                    
                }else if ([file.fileName isEqualToString:NSLocalizedString(@"Localtion Video",nil)]){
                    
                    self.dirPath = [[WFFileUtil getDocumentPath] stringByAppendingPathComponent:NSLocalizedString(@"Localtion Video",nil)];
                    
                    [self getDateFromAssetsLibrary:@"video"];
                    
                }else if ([file.fileName isEqualToString:NSLocalizedString(@"WiFiDock",nil)]){
                    
                    self.dirPath = file.filePath;
                   
                    NSString *filePath = [[WFFileUtil getDocumentPath] stringByAppendingPathComponent:NSLocalizedString(@"WiFiDock",nil)];
                    
                    [self getDataFromDocument:filePath];
                    
                }else{
                
                    NSString *filePath = [WFFileUtil getDocumentPath];
                    
                    [self getDataFromDocument:filePath];
                }
                
                
            }else {
                
                NSString *tmpPath = file.filePath;
                self.dirPath = file.filePath;
//                NSString *filePath =[tmpPath stringByAppendingPathComponent:tmpPath];
                
                [self getDataFromDocument:tmpPath];
            }

        }else if(file.fileType == NSFileTypeRegular||[file.ID isKindOfClass:[ALAsset class]]){
        
           
            if ([[file.fileName pathExtension]isEqualToString:@"lock"]) {
                
 
                PAPasscodeViewController *passcodeViewController = [[PAPasscodeViewController alloc] initForAction:PasscodeActionEnter];
                
                passcodeViewController.fileName = file.fileName;
                passcodeViewController.filePath = file.filePath;
                passcodeViewController.delegate = self;
                
                [self presentViewController:passcodeViewController animated:YES completion:nil];
                

            }else{
                
                NSString *extension = [file.fileName pathExtension];
                
                if ([WFFileUtil isImage:extension] ||[WFFileUtil isDoc:extension] ) {
                    
                    NSURL *url = [NSURL fileURLWithPath:file.filePath];
                    NSMutableArray *array = [NSMutableArray array];
                    [array addObject:file];
                    
                    WFPreviewController *preview = [[WFPreviewController alloc]initWithURL:url query:[array copy] index:self.index];
                    
                    [self presentViewController:preview animated:YES completion:nil];
                    
//                    [self.parentViewController presentViewController:preview animated:YES completion:^{
//                        
//                        NSLog(@"hello");
//                    }];
                    
                }else if(([WFFileUtil isAudio:extension]||[WFFileUtil isVideo:extension])&& ![file.ID isKindOfClass:[ALAsset class]]){
                    
                    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
                    parameters[KxMovieParameterMinBufferedDuration] = @(5.0);
                    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
                        parameters[KxMovieParameterDisableDeinterlacing] = @(YES);
                    
                    KxMovieViewController *vc = [KxMovieViewController movieViewControllerWithContent:nil current:file.filePath parameters:parameters withIndex:self.index];
                    [self presentViewController:vc animated:NO completion:nil];
                    
                }else if([file.ID isKindOfClass:[ALAsset class]]){
                    
                    if (!self.playerController) {
                        self.playerController = [[WFMoviePlayerController alloc] init];
                        self.playerController.delegate = self;
                    }
                    
                    NSString *urlStr = file.filePath;
                    urlStr = [urlStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
                    
                    self.playerController.movieURL = [NSURL URLWithString:urlStr];
            
                    [self presentViewController:self.playerController animated:YES completion:nil];
                    
                }
                
            }
            
        }
        
    }
}



- (void)tabBar:(WFTabBar *)tabBar didSelectedButtonFrom:(WFTabBarButton*)from to:(WFTabBarButton*)to
{
    if ([from.item.title isEqualToString:to.item.title]) return;
    
    self.dirPath = nil;
    
    if ([to.item.title isEqualToString:NSLocalizedString(@"Local",nil)]) {
        
        NSString *filePath = [WFFileUtil getDocumentPath];
    
        [self getDataFromDocument:filePath];
        
    }else {
        
        [[IGLSMBProvier sharedSmbProvider] setIsCanle:NO];

        WFDataSource *data = [WFDataSource dataSourceWithRootPath:to.item.dirPath fileType:@"all"];
        
        [data loadDirectoryData];
     
        if (to.item.dirPath == self.rootSambaDockPath) {
            
            self.datasource = data.datasource;
            
        }else if(to.item.dirPath == self.rootSambaTFPath){
            
            self.datasource = data.datasource;
            
        }else if (to.item.dirPath == self.rootSambaUSBPath){
            
            self.datasource = data.datasource;
            
        }
    
        [self.tableView reloadData];
    }
}

-(void)back
{
    NSString *dirPath = self.dirPath;

    
    
    if ([dirPath isEqualToString:self.rootSambaDockPath]||
        [dirPath isEqualToString:self.rootSambaTFPath]||
        [dirPath isEqualToString:self.rootSambaUSBPath]||
        [dirPath isEqualToString:self.rootLocalPath]||
        (dirPath ==nil)){
        [[IGLSMBProvier sharedSmbProvider]setIsCanle:YES];
        [super back];
        
//        [self deleteFile];
    
    }else{

        if ([dirPath hasPrefix:self.rootLocalPath]&&![dirPath isEqualToString:self.rootLocalPath]) {
            dirPath = [dirPath pathByDeletingLastPathComponent];
            self.dirPath = dirPath;
            [self getDataFromDocument:dirPath];
            
        }else{
            
            dirPath = [dirPath pathByDeletingLastPathComponent];
            WFDataSource *data = [[WFDataSource alloc]initWithRootPath:dirPath fileType:@"all"];
            self.dirPath = dirPath;
            [data loadDirectoryData];
            
            self.datasource = data.datasource;
            [self.tableView reloadData];
        }
        
        
        
    }
}

- (void)setupMore
{
    [super setupMore];
    
    QBPopupMenuItem *item1 = [QBPopupMenuItem itemWithTitle:NSLocalizedString(@"Status",nil) target:self action:@selector(statusView)];
    
//    QBPopupMenuItem *item2 = [QBPopupMenuItem itemWithTitle:NSLocalizedString(@"All",nil) target:self action:@selector(selectAllFile)];
    
//    QBPopupMenuItem *item3 = [QBPopupMenuItem itemWithTitle:NSLocalizedString(@"Camera",nil) target:self action:@selector(openCamera)];
    
    QBPopupMenuItem *item4 = [QBPopupMenuItem itemWithTitle:NSLocalizedString(@"New Directory",nil) target:self action:@selector(createDirectory)];
    
    QBPopupMenuItem *item5 = [QBPopupMenuItem itemWithTitle:NSLocalizedString(@"encrypt",nil) target:self action:@selector(zip)];
    
    
    NSArray *items = @[item1,item4,item5];
    
    QBPopupMenu *popupMenu = [[QBPopupMenu alloc] initWithItems:items];
    popupMenu.highlightedColor = [[UIColor colorWithRed:0 green:0.478 blue:1.0 alpha:1.0] colorWithAlphaComponent:0.8];
    
    self.popupMenu = popupMenu;
    
}

- (void)openCamera
{
    if(![UIImagePickerController isSourceTypeAvailable:
         UIImagePickerControllerSourceTypeCamera]){
        [MBProgressHUD showError:NSLocalizedString(@"Open Camera Faild",nil)];
        return;
    }
    UIImagePickerController* Camera = [[UIImagePickerController alloc] init];
    Camera.delegate = self;
    Camera.sourceType = UIImagePickerControllerSourceTypeCamera;
    Camera.mediaTypes = [NSArray arrayWithObjects:(NSString*)kUTTypeImage,(NSString*)kUTTypeMovie, nil];
    Camera.cameraCaptureMode = UIImagePickerControllerCameraCaptureModePhoto;
    Camera.allowsEditing = NO;
    Camera.videoQuality = UIImagePickerControllerQualityTypeMedium;
    Camera.showsCameraControls = YES;
    Camera.cameraDevice = UIImagePickerControllerCameraDeviceRear|UIImagePickerControllerCameraDeviceFront;
    Camera.cameraFlashMode = UIImagePickerControllerCameraFlashModeAuto;

    [self presentViewController:Camera animated:YES completion:^{
        self.editbtn.hidden = YES;
    
        [self cancel];
    }];

 
}

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    
    [MBProgressHUD showSuccess:NSLocalizedString(@"Loading......",nil)];
    NSString *mediaType = [info objectForKey:UIImagePickerControllerMediaType];
    CurrentViewMode mode = [self getCurrentViewMode];
    NSString *destPath = [self currentViewPath];
    if ([mediaType isEqualToString:@"public.image"]){
        
        UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
        
        if (mode == CurrentViewLoaclMode) {
            
            UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil);
            
            [MBProgressHUD showSuccess:NSLocalizedString(@"Uploaded Successfully",nil)];
            
        }else{
        
            [[IGLSMBProvier sharedSmbProvider] uploadData:UIImageJPEGRepresentation(image, 1.0) smbPath:[WFActionTool buildUploadImageName:destPath] overwrite:YES block:^(id result) {
                if ([result isKindOfClass:[IGLSMBItemFile class]]) {
                    
                    [MBProgressHUD showSuccess:NSLocalizedString(@"Uploaded Successfully",nil)];
                    
                }else{
                    
                    [MBProgressHUD showError:NSLocalizedString(@"Uploaded Error",nil)];
                    
                }
            }];
        }
        
 
    }else if([mediaType isEqualToString:@"public.movie"]){
        
        NSURL *videoURL = [info objectForKey:UIImagePickerControllerMediaURL];
        
        if (mode == CurrentViewLoaclMode) {
            
            NSString *urlStr=[videoURL path];
            
            UISaveVideoAtPathToSavedPhotosAlbum(urlStr, self, @selector(video:didFinishSavingWithError:contextInfo:), nil);
            
        }else{
            
            NSData *videoData = [NSData dataWithContentsOfURL:videoURL];
           
            [[IGLSMBProvier sharedSmbProvider] uploadData:videoData smbPath:[WFActionTool buildUploadVideoName:destPath] overwrite:YES block:^(id result) {
                if([result isKindOfClass:[IGLSMBItemFile class]]){
                    
                    [MBProgressHUD showSuccess:NSLocalizedString(@"Uploaded Successfully",nil)];
                    
                    WFFile *file = [[WFFile alloc]initWithSmbItem:result fileType:@"video"];
                    
                    [self.datasource addObject:file];
                    [self.tableView reloadData];
                    
                }else{
                    
                    [MBProgressHUD showError:NSLocalizedString(@"Uploaded Error",nil)];
                }
            }];
        }
    }
    
    [picker dismissViewControllerAnimated:YES completion:^{
//        self.editbtn.hidden = NO;
    }];
}

- (void)video:(NSString *)videoPath didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo{
    if (error) {
        
        NSString *msg = [NSString stringWithFormat:@"保存视频过程中发生错误，错误信息:%@",error.localizedDescription];
        [MBProgressHUD showError:msg];
        
        
    }else{
        
        [MBProgressHUD showSuccess:NSLocalizedString(@"Saved Video Successfully",nil)];
    }
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:^{
//        self.editbtn.hidden = NO;
    }];
}

- (void)createDirectory
{
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"New Directory",nil) message:nil delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel",nil) otherButtonTitles:NSLocalizedString(@"Done",nil), nil];
    alert.alertViewStyle = UIAlertViewStylePlainTextInput;
    
    alert.tag = 120;

    [alert show];

}

- (void)moviePlayerDidFinished
{
    [self dismissViewControllerAnimated:YES completion:nil];
    self.playerController = nil;
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
   
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
//    if (self.editbtn.hidden == YES) {
//        self.editbtn.hidden = NO;
//    }
}

- (void)deleteFile
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

    BOOL on = [defaults boolForKey:@"delete"];
    
    
    if (on) {
        
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSString *path = [[WFFileUtil getDocumentPath] stringByAppendingPathComponent:@"云盘坞"];
        
        NSArray *contents = [fileManager contentsOfDirectoryAtPath:path error:NULL];
        
        NSEnumerator *e = [contents objectEnumerator];
        NSString *filename;
        while ((filename = [e nextObject])) {
            
            [fileManager removeItemAtPath:[path stringByAppendingPathComponent:filename] error:NULL];
        }
        
    }

}


-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
@end
