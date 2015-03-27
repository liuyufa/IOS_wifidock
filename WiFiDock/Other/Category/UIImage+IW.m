//
//  UIImage+IW.m
//  01-ItcastWeibo
//
//  Created by apple on 14-1-12.
//  Copyright (c) 2014年 itcast. All rights reserved.
//

#import "UIImage+IW.h"

@implementation UIImage (IW)

+ (UIImage *)originalImageWithName:(NSString *)name
{
    return [self imageWithName:name];
    
//    if (iOS7) {
//        return [[self imageWithName:name] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
//    } else {
//        return [self imageWithName:name];
//    }
}

+ (UIImage *)imageWithName:(NSString *)name
{

    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        
        NSString *newName = [name stringByAppendingString:@"~ipad"];
        
        UIImage *image = [self imageNamed:newName];
        
        if (image == nil) {
            
            image = [self imageNamed:name];
        }
        return image;
        
    }else{
        return [self imageNamed:name];
        
    }
    
}

+ (UIImage *)resizedImage:(NSString *)name
{
    return [self resizedImage:name leftScale:0.5 topScale:0.5];
}

+ (UIImage *)resizedImage:(NSString *)name leftScale:(CGFloat)leftScale topScale:(CGFloat)topScale
{
    UIImage *image = [self imageWithName:name];
    
    return [image stretchableImageWithLeftCapWidth:image.size.width * leftScale topCapHeight:image.size.height * topScale];
}

+ (UIImage *)captureWithView:(UIView *)view
{
    UIGraphicsBeginImageContextWithOptions(view.bounds.size, YES, 0.0);
    [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return img;
}
 
@end
