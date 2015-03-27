//
//  WFSelect.h
//  WiFiDock
//
//  Created by apple on 15-2-6.
//  Copyright (c) 2015年 cn.hualu.WiFiDock. All rights reserved.
//

#import <UIKit/UIKit.h>

@class WFSelectBar,WFEditButton;
@protocol WFSelectBarDelegate <NSObject>

@optional
- (void)selectBar:(WFSelectBar *)pasteBar didSelectedButtonFrom:(WFEditButton*)from to:(WFEditButton*)to;

@end

@interface WFSelectBar : UIView

@property (strong, nonatomic) NSMutableArray *tabBarButtons;

@property(nonatomic,weak) id<WFSelectBarDelegate> delegate;

@end
