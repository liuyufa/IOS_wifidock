//
//  IGLNotifyHUD.h
//  IGL004
//
//  Created by apple on 2014/02/24.
//  Copyright (c) 2014年 hualu. All rights reserved.
//

#import <UIKit/UIKit.h>

#define APP_WIDATH [UIScreen mainScreen].applicationFrame.size.width
#define IGLKNotifyHUDDefaultWidth APP_WIDATH*2/3
#define IGLKNotifyHUDDefaultHeight 50.0f

@interface IGLNotifyHUD : UIView
@property (nonatomic) CGFloat destinationOpacity;
@property (nonatomic) CGFloat currentOpacity;
@property (nonatomic) UIImage *image;
@property (nonatomic) CGFloat roundness;
@property (nonatomic) BOOL bordered;
@property (nonatomic) BOOL isAnimating;
@property (strong, nonatomic) UIColor *borderColor;
@property (strong, nonatomic) NSString *text;
@property (strong, nonatomic) UIColor *bgColor;

+ (id)notifyHUDWithImage:(UIImage *)image text:(NSString *)text;
- (id)initWithImage:(UIImage *)image text:(NSString *)text;

- (void)presentWithDuration:(CGFloat)duration speed:(CGFloat)speed inView:(UIView *)view completion:(void (^)(void))completion;

@end
