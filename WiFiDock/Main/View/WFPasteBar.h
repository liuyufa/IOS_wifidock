//
//  WFPasteBar.h
//  WiFiDock
//
//  Created by apple on 15-2-6.
//  Copyright (c) 2015年 cn.hualu.WiFiDock. All rights reserved.
//

#import <UIKit/UIKit.h>

@class WFPasteBar,WFEditButton;
@protocol WFPasteBarDelegate <NSObject>

@optional
- (void)pasteBar:(WFPasteBar *)pasteBar didSelectedButtonFrom:(WFEditButton*)from to:(WFEditButton*)to;

@end

@interface WFPasteBar : UIView

@property (strong, nonatomic) NSMutableArray *tabBarButtons;

@property(nonatomic,weak) id<WFPasteBarDelegate> delegate;

@end
