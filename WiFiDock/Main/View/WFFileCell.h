//
//  WFFileCell.h
//  WiFiDock
//
//  Created by apple on 14-12-5.
//  Copyright (c) 2014年 cn.hualu.WiFiDock. All rights reserved.
//

#import <UIKit/UIKit.h>


@class WFFile;
@interface WFFileCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *iconView;
@property (weak, nonatomic) IBOutlet UILabel *titleLable;
@property (weak, nonatomic) IBOutlet UILabel *subtitleLable;
@property (weak, nonatomic) IBOutlet UILabel *sizeLable;
@property(nonatomic,strong)WFFile *file;

+ (instancetype)cellWithTableView:(UITableView *)tableView;

@end
