//
//  MBProgressHUD+WF.h
//
//  Created by zhangjian on 14-12-2.
//  Copyright (c) 2014年 zhangjian. All rights reserved.
//

#import "MBProgressHUD.h"

@interface MBProgressHUD (WF)
+ (void)showSuccess:(NSString *)success toView:(UIView *)view;
+ (void)showError:(NSString *)error toView:(UIView *)view;

+ (MBProgressHUD *)showMessage:(NSString *)message toView:(UIView *)view;


+ (void)showSuccess:(NSString *)success;
+ (void)showError:(NSString *)error;

+ (MBProgressHUD *)showMessage:(NSString *)message;

+ (void)hideHUDForView:(UIView *)view;
+ (void)hideHUD;

@end
