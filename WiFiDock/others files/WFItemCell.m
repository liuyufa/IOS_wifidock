//
//  WFItemCell.m
//  WiFiDock
//
//  Created by apple on 14-12-29.
//  Copyright (c) 2014年 cn.hualu.WiFiDock. All rights reserved.
//

#import "WFItemCell.h"
#import "WFItemFrame.h"
#import "WFFile.h"

@interface WFItemCell ()
@property (weak, nonatomic) UIImageView *iconView;
@property (weak, nonatomic) UILabel *titleLable;
@property (weak, nonatomic) UILabel *subtitleLable;
@property (weak, nonatomic) UILabel *sizeLable;

@end
@implementation WFItemCell

+ (instancetype)cellWithTableView:(UITableView *)tableView
{
    static NSString *ID = @"ItemCell";
    WFItemCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    
    if (cell == nil) {
        cell = [[WFItemCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:ID];
    }
    
    return cell;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self) {
        
        [self setupSubviews];
    }
    return self;
}

- (void)setupSubviews
{
    UIImageView *iconView = [[UIImageView alloc]init];
    [self.contentView addSubview:iconView];
    self.iconView = iconView;
    
    UILabel *titleLable = [[UILabel alloc]init];
    [self.contentView addSubview:titleLable];
    self.titleLable = titleLable;
    
    UILabel *subtitleLable = [[UILabel alloc]init];
    [self.contentView addSubview:subtitleLable];
    self.subtitleLable = subtitleLable;
    
    UILabel *sizeLable = [[UILabel alloc]init];
    [self.contentView addSubview:sizeLable];
    self.sizeLable = sizeLable;
    
}

- (void)setItemFrame:(WFItemFrame *)itemFrame
{
    _itemFrame = itemFrame;
    
    WFFile *file = self.itemFrame.file;
    
    [self.iconView setImage:file.icon];
    self.iconView.frame = self.itemFrame.iconViewF;
    
    self.titleLable.text = file.fileName;
    self.titleLable.frame = self.itemFrame.titleLableF;
    
    self.subtitleLable.text = file.createData;
    self.subtitleLable.frame = self.itemFrame.subtitleLableF;
    
    self.sizeLable.text = file.fileSize;
    self.sizeLable.frame = self.itemFrame.sizeLableF;
    
    self.accessoryView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"CellArrow"]];

}
@end
