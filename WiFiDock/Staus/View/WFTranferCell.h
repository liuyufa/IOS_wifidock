//
//  WFTranferCell.h
//  WiFiDock
//
//  Created by apple on 15-1-8.
//  Copyright (c) 2015年 cn.hualu.WiFiDock. All rights reserved.
//

#import <UIKit/UIKit.h>

@class WFTransferItem;

@protocol WFTranferCellDelegate <NSObject>



@end

@interface WFTranferCell : UITableViewCell

@property (nonatomic, strong)WFTransferItem *item;

+ (instancetype)cellWithTableView:(UITableView *)tableView;
@end
