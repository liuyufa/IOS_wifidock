//
//  WFSettingCellTableViewCell.m
//  WiFiDock
//
//  Created by apple on 14-12-2.
//  Copyright (c) 2014年 cn.hualu.WiFiDock. All rights reserved.
//

#import "WFSettingCell.h"
#import "WFSettingArrowItem.h"
#import "WFSettingLablltem.h"
#import "WFSettingSwitchItem.h"

@interface WFSettingCell()
@property (nonatomic, strong) UIImageView *arrowView;
@property (nonatomic, strong) UILabel *labelView;
@property (nonatomic, strong) UISwitch *switchView;
@end
@implementation WFSettingCell

- (UIImageView *)arrowView
{
    if (_arrowView == nil) {
        _arrowView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"CellArrow"]];
    }
    return _arrowView;
}

- (UILabel *)labelView
{
    if (_labelView == nil) {
        _labelView = [[UILabel alloc] init];
        _labelView.bounds = CGRectMake(0, 0, 100, 30);
        _labelView.backgroundColor = [UIColor redColor];
    }
    return _labelView;
}

- (UISwitch *)switchView
{
    if (_switchView == nil) {
        _switchView = [[UISwitch alloc] init];
        [_switchView addTarget:self action:@selector(switchStateChange) forControlEvents:UIControlEventValueChanged];
    }
    return _switchView;
}

- (void)switchStateChange
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    //    if (self.item.key) {
    [defaults setBool:self.switchView.isOn forKey:@"delete"];
    [defaults synchronize];
    //    }
}

+ (instancetype)cellWithTableView:(UITableView *)tableView
{
    static NSString *ID = @"setting";
    WFSettingCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    if (cell == nil) {
        cell = [[WFSettingCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:ID];
    }
    return cell;
}


- (void)setItem:(WFSettingItem *)item
{
    _item = item;
    
    // 1.设置数据
    [self setupData];
    
    // 2.设置右边的内容
    [self setupRightContent];
}

- (void)setupRightContent
{
    if ([self.item isKindOfClass:[WFSettingArrowItem class]]) { // 箭头
        self.accessoryView = self.arrowView;
    } else if ([self.item isKindOfClass:[WFSettingLablltem class]]) { // 标签
        self.accessoryView = self.labelView;
    } else if([self.item isKindOfClass:[WFSettingSwitchItem class]]){
        
        self.accessoryView = self.switchView;
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        // 设置开关的状态
//        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
//        self.switchView.on = [defaults boolForKey:@"delete"];
        
    }else{
        self.accessoryView = nil;
    }
}

- (void)setupData
{
    if (self.item.icon) {
        self.imageView.image = [UIImage imageNamed:self.item.icon];
    }
    self.textLabel.text = self.item.title;
    self.detailTextLabel.text = self.item.subtitle;
}

@end
