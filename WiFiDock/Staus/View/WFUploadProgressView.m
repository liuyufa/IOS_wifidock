//
//  WFUploadProgressView.m
//  WiFiDock
//
//  Created by apple on 15-1-9.
//  Copyright (c) 2015年 cn.hualu.WiFiDock. All rights reserved.
//

#import "WFUploadProgressView.h"

@interface WFUploadProgressView ()
@property (strong, nonatomic) UIProgressView *progressView;

@end

@implementation WFUploadProgressView

- (instancetype)initWithFrame:(CGRect)frame cancelButton:(BOOL)showButton
{
    self = [super init];
    if (self) {
        
        self.progressView = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleBar];
        
    }
    
    return self;
}

@end
