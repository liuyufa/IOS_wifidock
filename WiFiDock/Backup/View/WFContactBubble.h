//
//  WFContactBubble.h
//  WiFiDock
//
//  Created by apple on 15-1-12.
//  Copyright (c) 2015年 cn.hualu.WiFiDock. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WFBubbleColor.h"

@class WFContactBubble;

@protocol WFContactBubbleDelegate <NSObject>

- (void)contactBubbleWasSelected:(WFContactBubble *)contactBubble;
- (void)contactBubbleWasUnSelected:(WFContactBubble *)contactBubble;
- (void)contactBubbleShouldBeRemoved:(WFContactBubble *)contactBubble;

@end

@interface WFContactBubble : UIView
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) UILabel *label;
@property (nonatomic, strong) UITextView *textView; // used to capture keyboard touches when view is selected
@property (nonatomic, assign) BOOL isSelected;

@property (nonatomic, assign) id <WFContactBubbleDelegate>delegate;
@property (nonatomic, strong) CAGradientLayer *gradientLayer;

@property (nonatomic, strong) WFBubbleColor *color;
@property (nonatomic, strong) WFBubbleColor *selectedColor;

- (id)initWithName:(NSString *)name;
- (id)initWithName:(NSString *)name
             color:(WFBubbleColor *)color
     selectedColor:(WFBubbleColor *)selectedColor;

- (void)select;
- (void)unSelect;
- (void)setFont:(UIFont *)font;
@end
