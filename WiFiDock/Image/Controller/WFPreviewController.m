//
//  WFPreviewController.m
//  WiFiDock
//
//  Created by apple on 14-12-10.
//  Copyright (c) 2014年 cn.hualu.WiFiDock. All rights reserved.
//

#import "WFPreviewController.h"
#import "WFFile.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "WFFileUtil.h"
#import "IGLSMBProvier.h"
#import "WFFileUtil.h"
#import "WFActionTool.h"
#import <objc/runtime.h>

#define KWFFileUtilTempPath NSTemporaryDirectory()
@interface WFPreviewController ()<QLPreviewControllerDataSource,QLPreviewControllerDelegate,UIDocumentInteractionControllerDelegate>

@property(nonatomic, strong)NSArray *totalFile;
@property(nonatomic, strong)NSURL *url;
@property(nonatomic, assign)NSInteger index;
@property(nonatomic, assign)BOOL loop;

@property(nonatomic, assign)IMP origImpOne;
@property(nonatomic, assign)IMP origImpTwo;

@property(nonatomic, assign)IMP origImpThree;
@property(nonatomic, assign)IMP origImpFour;
@end

static void override_setRightBarButtonItem(id _self, SEL __cmd, UIBarButtonItem *item, BOOL animated)
{
    
}

static void override_setRightBarButtonItems(id _self, SEL __cmd, NSArray *items, BOOL animated)
{
    
}

//static void override_setLeftBarButtonItem(id _self, SEL __cmd, UIBarButtonItem *item, BOOL animated)
//{
//    
//}
//
//static void override_setLeftBarButtonItems(id _self, SEL __cmd, NSArray *items, BOOL animated)
//{
//    
//    
//}



@implementation WFPreviewController


- (void)overrideMethod
{
    SEL selectorOneToOverride = @selector(setRightBarButtonItem:animated:);
    Method methodOne = class_getInstanceMethod([UINavigationItem class], selectorOneToOverride);
    self.origImpOne = class_getMethodImplementation([UINavigationItem class], selectorOneToOverride);
    method_setImplementation(methodOne, (IMP)override_setRightBarButtonItem);
    
    SEL selectorTwoToOverride = @selector(setRightBarButtonItems:animated:);
    Method methodTwo = class_getInstanceMethod([UINavigationItem class], selectorTwoToOverride);
    self.origImpTwo = class_getMethodImplementation([UINavigationItem class], selectorTwoToOverride);
    method_setImplementation(methodTwo, (IMP)override_setRightBarButtonItems);
    
//    SEL selectorThreeToOverride = @selector(setLeftBarButtonItem:animated:);
//    Method methodThree = class_getInstanceMethod([UINavigationItem class], selectorThreeToOverride);
//    self.origImpThree = class_getMethodImplementation([UINavigationItem class], selectorThreeToOverride);
//    method_setImplementation(methodThree, (IMP)override_setLeftBarButtonItem);
//
//    SEL selectorFourToOverride = @selector(setLeftBarButtonItems:animated:);
//    Method methodFour = class_getInstanceMethod([UINavigationItem class], selectorFourToOverride);
//    self.origImpFour = class_getMethodImplementation([UINavigationItem class], selectorFourToOverride);
//    method_setImplementation(methodFour, (IMP)override_setLeftBarButtonItems);
    
}

- (void)noOverrideMethod
{
    SEL selectorOneToOverride = @selector(setRightBarButtonItem:animated:);
    Method methodOne = class_getInstanceMethod([UINavigationItem class], selectorOneToOverride);
    method_setImplementation(methodOne, self.origImpOne);
    
    SEL selectorTwoToOverride = @selector(setRightBarButtonItems:animated:);
    Method methodTwo = class_getInstanceMethod([UINavigationItem class], selectorTwoToOverride);
    method_setImplementation(methodTwo, self.origImpTwo);
    
//    SEL selectorThreeToOverride = @selector(setLeftBarButtonItem:animated:);
//    Method methodThree = class_getInstanceMethod([UINavigationItem class], selectorThreeToOverride);
//    method_setImplementation(methodThree, self.origImpThree);
//    
//    SEL selectorFourToOverride = @selector(setLeftBarButtonItems:animated:);
//    Method methodFour = class_getInstanceMethod([UINavigationItem class], selectorFourToOverride);
//    method_setImplementation(methodFour, self.origImpFour);
}

-(BOOL)prefersStatusBarHidden
{
    return NO;
}

-(NSArray *)totalFile
{
    if (!_totalFile) {
        _totalFile = [[NSArray alloc]init];
    }
    
    return _totalFile;
}

- (id)initWithURL:(NSURL*)url query:(NSArray*)datasource index:(NSInteger)index
{
    self = [super init];
    
    if (self) {
        
        self.url = url;
        
        self.totalFile = datasource;
        
        self.index = index;
        
    }
    
    return self;
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    self.view.frame = [[UIScreen mainScreen] bounds];
    
    self.dataSource = self;
    
    self.delegate = self;
    
    self.currentPreviewItemIndex = self.index ;
    
    self.view.autoresizingMask = UIViewContentModeBottomLeft |UIViewContentModeBottomRight |UIViewContentModeTop |UIViewContentModeBottom;
}

-(NSInteger)numberOfPreviewItemsInPreviewController:(QLPreviewController *)controller
{
    return self.totalFile.count;
}

-(id<QLPreviewItem>)previewController:(QLPreviewController *)controller previewItemAtIndex:(NSInteger)index
{

    if (index == self.index) return self.url;
   
    WFFile *file = [self.totalFile objectAtIndex:index];

    if ([file.ID isKindOfClass:[ALAsset class]]) {//相册中数据
        
        BOOL result = [WFFileUtil fileCopyWithItem:file destPath:KWFFileUtilTempPath];
        
        if (!result) return nil;
        
        NSString *tmpPath = [KWFFileUtilTempPath stringByAppendingPathComponent:file.fileName];
        
        return [NSURL fileURLWithPath:tmpPath];
        
    }else if([file.ID isKindOfClass:[IGLSMBItem class]]){
        
        NSString *despath = [KWFFileUtilTempPath stringByAppendingPathComponent:[file.filePath lastPathComponent]];
        
//        NSString *sourcePath = [file.filePath absoluteString];
        NSString *sourcePath = file.filePath;
        
        [[IGLSMBProvier sharedSmbProvider]copySmbItemfrom:sourcePath to:despath];
        
        return [NSURL fileURLWithPath:despath];
   
    }else {//document中数据
        
        NSURL *url = [NSURL fileURLWithPath:file.filePath];
  
        return url;
    }

    return nil;
}

- (BOOL)previewController:(QLPreviewController *)controller shouldOpenURL:(NSURL *)url forPreviewItem:(id<QLPreviewItem>)item
{
    NSLog(@"previewController");
    return YES;
}

- (UIViewController *)documentInteractionControllerViewControllerForPreview:(UIDocumentInteractionController *)interactionController
{
    return self;
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    self.view.frame = [[UIScreen mainScreen] bounds];
}

- (void)viewWillAppear:(BOOL)animated
{
    [self overrideMethod];
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [self noOverrideMethod];
    [super viewWillDisappear:animated];
    
    NSArray *fileList = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:KWFFileUtilTempPath error:nil];
    
    for(int i=0;i<[fileList count]; i++){
       
        NSString *filePath = [KWFFileUtilTempPath stringByAppendingPathComponent:[fileList objectAtIndex:i]];
       
        NSURL *filepaht1=[NSURL fileURLWithPath:filePath];
        
        [[NSFileManager defaultManager] removeItemAtURL:filepaht1 error:nil];
    }
    
}

-(void)dealloc
{
    NSLog(@"WFPreviewController++++++");
}

-(void)previewControllerWillDismiss:(QLPreviewController *)controller
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"kDelete" object:nil];
}
@end

