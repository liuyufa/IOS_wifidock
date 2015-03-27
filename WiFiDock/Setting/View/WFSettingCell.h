//
//  WFSettingCellTableViewCell.h
//  WiFiDock
//
//  Created by apple on 14-12-2.
//  Copyright (c) 2014年 cn.hualu.WiFiDock. All rights reserved.
//

#import <UIKit/UIKit.h>

@class WFSettingItem;

@interface WFSettingCell : UITableViewCell

@property (nonatomic, strong) WFSettingItem *item;

+ (instancetype)cellWithTableView:(UITableView *)tableView;

@end
