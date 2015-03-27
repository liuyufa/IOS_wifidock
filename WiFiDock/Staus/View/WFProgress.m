//
//  WFProgress.m
//  WiFiDock
//
//  Created by apple on 15-1-8.
//  Copyright (c) 2015年 cn.hualu.WiFiDock. All rights reserved.
//

#import "WFProgress.h"

#define kProgressBarHeight  22.0f
#define kProgressBarWidth	160.0f

@interface WFProgress ()

@end


@implementation WFProgress

- (id)init
{
    return [self initWithFrame: CGRectZero] ;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame: frame] ;
    
    if (self){
        
        self.backgroundColor = [UIColor clearColor] ;
        self.innerColor = [UIColor lightGrayColor] ;
        self.outerColor = [UIColor lightGrayColor] ;
        self.emptyColor = [UIColor clearColor] ;
        if (frame.size.width == 0.0f)
            frame.size.width = kProgressBarWidth ;
    }
    return self ;
}

- (void)setProgress:(float)currentProgress
{
    if(currentProgress >= 0.0f || currentProgress <= 1.0f){
    }else if (currentProgress < 0.0f){
        currentProgress = 0.0f;
    }else if (currentProgress > 1.0f){
        currentProgress = 1.0f;
    }else{
        return;
    }
    self.progress = currentProgress;
    
    [self setNeedsDisplay] ;
}

- (void)setFrame:(CGRect)frame
{
    frame.size.height = kProgressBarHeight ;
    [super setFrame: frame] ;
}

- (void)setBounds:(CGRect)bounds
{
    
    bounds.size.height = kProgressBarHeight ;
    [super setBounds: bounds] ;
}

- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext() ;
    
    // save the context
    CGContextSaveGState(context) ;
    
    // allow antialiasing
    CGContextSetAllowsAntialiasing(context, TRUE) ;
    
    // we first draw the outter rounded rectangle
    rect = CGRectInset(rect, 1.0f, 1.0f) ;
    CGFloat radius = 0.5f * rect.size.height ;
    
    [self.outerColor setStroke] ;
    CGContextSetLineWidth(context, 2.0f) ;
    
    CGContextBeginPath(context) ;
    CGContextMoveToPoint(context, CGRectGetMinX(rect), CGRectGetMidY(rect)) ;
    CGContextAddArcToPoint(context, CGRectGetMinX(rect), CGRectGetMinY(rect), CGRectGetMidX(rect), CGRectGetMinY(rect), radius) ;
    CGContextAddArcToPoint(context, CGRectGetMaxX(rect), CGRectGetMinY(rect), CGRectGetMaxX(rect), CGRectGetMidY(rect), radius) ;
    CGContextAddArcToPoint(context, CGRectGetMaxX(rect), CGRectGetMaxY(rect), CGRectGetMidX(rect), CGRectGetMaxY(rect), radius) ;
    CGContextAddArcToPoint(context, CGRectGetMinX(rect), CGRectGetMaxY(rect), CGRectGetMinX(rect), CGRectGetMidY(rect), radius) ;
    CGContextClosePath(context) ;
    CGContextDrawPath(context, kCGPathStroke) ;
    
    // draw the empty rounded rectangle (shown for the "unfilled" portions of the progress
    rect = CGRectInset(rect, 3.0f, 3.0f) ;
    radius = 0.5f * rect.size.height ;
    
    [self.emptyColor setFill] ;
    
    CGContextBeginPath(context) ;
    CGContextMoveToPoint(context, CGRectGetMinX(rect), CGRectGetMidY(rect)) ;
    CGContextAddArcToPoint(context, CGRectGetMinX(rect), CGRectGetMinY(rect), CGRectGetMidX(rect), CGRectGetMinY(rect), radius) ;
    CGContextAddArcToPoint(context, CGRectGetMaxX(rect), CGRectGetMinY(rect), CGRectGetMaxX(rect), CGRectGetMidY(rect), radius) ;
    CGContextAddArcToPoint(context, CGRectGetMaxX(rect), CGRectGetMaxY(rect), CGRectGetMidX(rect), CGRectGetMaxY(rect), radius) ;
    CGContextAddArcToPoint(context, CGRectGetMinX(rect), CGRectGetMaxY(rect), CGRectGetMinX(rect), CGRectGetMidY(rect), radius) ;
    CGContextClosePath(context) ;
    CGContextFillPath(context) ;
    
    // draw the inside moving filled rounded rectangle
    radius = 0.5f * rect.size.height ;
    
    // make sure the filled rounded rectangle is not smaller than 2 times the radius
    rect.size.width *= self.progress ;
    if (rect.size.width < 2 * radius)
        rect.size.width = 2 * radius ;
    
    [self.innerColor setFill] ;
    
    CGContextBeginPath(context) ;
    CGContextMoveToPoint(context, CGRectGetMinX(rect), CGRectGetMidY(rect)) ;
    CGContextAddArcToPoint(context, CGRectGetMinX(rect), CGRectGetMinY(rect), CGRectGetMidX(rect), CGRectGetMinY(rect), radius) ;
    CGContextAddArcToPoint(context, CGRectGetMaxX(rect), CGRectGetMinY(rect), CGRectGetMaxX(rect), CGRectGetMidY(rect), radius) ;
    CGContextAddArcToPoint(context, CGRectGetMaxX(rect), CGRectGetMaxY(rect), CGRectGetMidX(rect), CGRectGetMaxY(rect), radius) ;
    CGContextAddArcToPoint(context, CGRectGetMinX(rect), CGRectGetMaxY(rect), CGRectGetMinX(rect), CGRectGetMidY(rect), radius) ;
    CGContextClosePath(context) ;
    CGContextFillPath(context) ;
    
    // restore the context
    CGContextRestoreGState(context) ;
}

@end
