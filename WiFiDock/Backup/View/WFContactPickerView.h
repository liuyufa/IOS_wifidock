//
//  WFContactPickerView.h
//  WiFiDock
//
//  Created by apple on 15-1-12.
//  Copyright (c) 2015年 cn.hualu.WiFiDock. All rights reserved.
//

#import <UIKit/UIKit.h>

@class WFContactBubble,WFContactPickerView,WFBubbleColor;



@protocol WFContactPickerDelegate <NSObject>

- (void)contactPickerTextViewDidChange:(NSString *)textViewText;
- (void)contactPickerDidRemoveContact:(id)contact;
- (void)contactPickerDidResize:(WFContactPickerView *)contactPickerView;

@end

@interface WFContactPickerView : UIView

@property (nonatomic, strong) WFContactBubble *selectedContactBubble;
@property (nonatomic, assign) IBOutlet id <WFContactPickerDelegate> delegate;
@property (nonatomic, assign) BOOL limitToOne;
@property (nonatomic, assign) CGFloat viewPadding;
@property (nonatomic, strong) UIFont *font;

- (void)addContact:(id)contact withName:(NSString *)name;
- (void)removeContact:(id)contact;
- (void)removeAllContacts;
- (void)setPlaceholderString:(NSString *)placeholderString;
- (void)disableDropShadow;
- (void)resignKeyboard;
- (void)setBubbleColor:(WFBubbleColor *)color selectedColor:(WFBubbleColor *)selectedColor;

@end
