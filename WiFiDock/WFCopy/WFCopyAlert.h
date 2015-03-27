//
//  WFCopyAlert.h
//  WiFiDock
//
//  Created by apple on 15-1-7.
//  Copyright (c) 2015年 cn.hualu.WiFiDock. All rights reserved.
//

#import <UIKit/UIKit.h>

@class WFCopyAlert;
@protocol WFCopyAlertDelegate <NSObject>

- (void)copyAlert:(WFCopyAlert *)copyAlert clickedButtonAtIndex:(NSInteger)buttonIndex;

@end


@interface WFCopyAlert : UIAlertView

@property(nonatomic,weak)id<WFCopyAlertDelegate> delegate;
@end
