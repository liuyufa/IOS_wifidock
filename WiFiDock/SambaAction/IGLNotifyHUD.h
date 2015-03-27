//
//  IGLNotifyHUD.h
//  IGL004
//
//  Created by apple on 2014/02/24.
//  Copyright (c) 2014年 hualu. All rights reserved.
//

#import <UIKit/UIKit.h>
#define IGLKNotifyHUDDefaultWidth APP_WIDATH*2/3
#define IGLKNotifyHUDDefaultHeight 50.0f

@interface IGLNotifyHUD : UIView
@property (nonatomic,assign) CGFloat destinationOpacity;
@property (nonatomic,assign) CGFloat currentOpacity;
@property (nonatomic,weak) UIImage *image;
@property (nonatomic,assign) CGFloat roundness;
@property (nonatomic,assign) BOOL bordered;
@property (nonatomic,assign) BOOL isAnimating;
@property (strong, nonatomic) UIColor *borderColor;
@property (copy, nonatomic) NSString *text;
@property (strong, nonatomic) UIColor *bgColor;

+ (id)notifyHUDWithImage:(UIImage *)image text:(NSString *)text;
- (id)initWithImage:(UIImage *)image text:(NSString *)text;

- (void)presentWithDuration:(CGFloat)duration speed:(CGFloat)speed inView:(UIView *)view completion:(void (^)(void))completion;

@end
