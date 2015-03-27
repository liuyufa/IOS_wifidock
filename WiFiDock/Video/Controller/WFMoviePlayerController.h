//
//  WFMoviePlayerController.h
//  WiFiDock
//
//  Created by apple on 15-1-9.
//  Copyright (c) 2015年 cn.hualu.WiFiDock. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol WFMoviePlayerControllerDelegate <NSObject>

- (void)moviePlayerDidFinished;
@optional
- (void)moviePlayerDidCapturedWithImage:(UIImage *)image;

@end

@interface WFMoviePlayerController : UIViewController

@property (nonatomic, weak) id<WFMoviePlayerControllerDelegate> delegate;
@property (nonatomic, strong) NSURL *movieURL;
@end
