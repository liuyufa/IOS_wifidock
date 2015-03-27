//
//  WFItemCell.h
//  WiFiDock
//
//  Created by apple on 14-12-29.
//  Copyright (c) 2014年 cn.hualu.WiFiDock. All rights reserved.
//

#import <UIKit/UIKit.h>
@class WFItemFrame;

@interface WFItemCell : UITableViewCell
@property(nonatomic, strong) WFItemFrame *itemFrame;
+ (instancetype)cellWithTableView:(UITableView *)tableView;
@end
