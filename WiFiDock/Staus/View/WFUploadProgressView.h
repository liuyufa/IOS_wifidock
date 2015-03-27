//
//  WFUploadProgressView.h
//  WiFiDock
//
//  Created by apple on 15-1-9.
//  Copyright (c) 2015年 cn.hualu.WiFiDock. All rights reserved.
//

#import <UIKit/UIKit.h>

@class WFUploadProgressView;
@protocol WFUploadProgressViewDelegate <NSObject>

- (void)uploadDidFinish:(WFUploadProgressView *)progressView;
@optional
- (void)uploadDidCancel:(WFUploadProgressView *)progressView;

@end

@interface WFUploadProgressView : UIControl
@property (weak, nonatomic) id<WFUploadProgressViewDelegate> delegate;

@property (nonatomic) CGFloat progress;
@property (nonatomic) BOOL animatedProgress;
@property (strong, nonatomic) UIColor *progressTintColor;
@property (strong, nonatomic) UIColor *progressTrackColor;

@end
