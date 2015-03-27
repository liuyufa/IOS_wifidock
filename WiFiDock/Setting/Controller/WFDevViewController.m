//
//  WFDevViewController.m
//  WiFiDock
//
//  Created by apple on 14-12-2.
//  Copyright (c) 2014年 cn.hualu.WiFiDock. All rights reserved.
//

#import "WFDevViewController.h"

@interface WFDevViewController ()<UIWebViewDelegate>
@property(nonatomic,strong)UIWebView *webView;

@end

@implementation WFDevViewController



- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    UIWebView *webView = [[UIWebView alloc] init];
//    webView.scrollView.frame =self.view.frame;
//    webView.frame = self.view.frame;
    webView.scalesPageToFit = YES;
    webView.delegate = self;
    [self.view addSubview:webView];
    
    self.navigationItem.rightBarButtonItem = [UIBarButtonItem itemWithImage:@"btn_home" higlightedImage:nil target:self action:@selector(mainView)];
    
    NSURL *url = [NSURL URLWithString:@"http://10.10.1.1"];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    [webView loadRequest:request];
    self.webView = webView;
    
}

-(void)back
{
    [self.navigationController popViewControllerAnimated:YES];
}


-(void)webViewDidFinishLoad:(UIWebView *)webView
{
    
    const CGFloat defaultH = self.view.frame.size.height;
    const CGFloat defaultw = self.view.frame.size.width;
    CGRect originalF = webView.frame;
    webView.frame = CGRectMake(originalF.origin.x, originalF.origin.y, defaultw, defaultH);
    CGSize actualSize = [webView sizeThatFits:CGSizeZero];
    
    if (actualSize.height >= defaultH) {
        actualSize.height =defaultH;
    }
    if (actualSize.width >= defaultw) {
        actualSize.width =defaultw;
    }
    CGRect webViewF = webView.frame;
//    webViewF.size.height = actualSize.height;
//    webViewF.size.width = actualSize.width;
    webViewF.size = actualSize;
    webView.frame = webViewF;
    [MBProgressHUD hideHUD];
}

-(void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    [MBProgressHUD hideHUD];
    [MBProgressHUD showError:[NSString stringWithFormat:@"%@",error.localizedDescription]];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [MBProgressHUD showMessage:NSLocalizedString(@"Loading NetWork......",nil)];
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
     if (UIInterfaceOrientationIsLandscape(toInterfaceOrientation)) {//横屏
         const CGFloat defaultH = self.view.frame.size.height;
         const CGFloat defaultw = self.view.frame.size.width;
         CGRect originalF = self.webView.frame;
         self.webView.frame = CGRectMake(originalF.origin.x, originalF.origin.y, defaultw, defaultH);
         CGSize actualSize = [self.webView sizeThatFits:CGSizeZero];
         if (actualSize.height >= defaultH) {
             actualSize.height =defaultH;
         }
         if (actualSize.width >= defaultw) {
             actualSize.width =defaultw;
         }
         CGRect webViewF = self.webView.frame;
         webViewF.size.width = actualSize.height+self.navigationController.view.frame.size.height;
         webViewF.size.height = actualSize.width;
         self.webView.frame = webViewF;
     }else {
         const CGFloat defaultH = self.view.frame.size.height;
         const CGFloat defaultw = self.view.frame.size.width;
         CGRect originalF = self.webView.frame;
         self.webView.frame = CGRectMake(originalF.origin.x, originalF.origin.y, defaultw, defaultH);
         CGSize actualSize = [self.webView sizeThatFits:CGSizeZero];
         if (actualSize.height >= defaultH) {
             actualSize.height =defaultH;
         }
         if (actualSize.width >= defaultw) {
             actualSize.width =defaultw;
         }
         CGRect webViewF = self.webView.frame;
         webViewF.size.width = actualSize.height;
         webViewF.size.height = actualSize.width+self.navigationController.view.frame.size.height;
         self.webView.frame = webViewF;
     }
    
}

@end
