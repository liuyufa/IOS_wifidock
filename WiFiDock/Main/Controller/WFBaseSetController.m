//
//  WFTabBarController.m
//  WiFiDock
//
//  Created by apple on 14-12-2.
//  Copyright (c) 2014年 cn.hualu.WiFiDock. All rights reserved.
//

#import "WFBaseSetController.h"

#import "WFSettingGroup.h"
#import "WFSettingCell.h"
#import "WFSettingItem.h"
#import "WFSettingArrowItem.h"
#import "UIImage+IW.h"


@interface WFBaseSetController ()


@end

@implementation WFBaseSetController



- (id)init
{
    return [super initWithStyle:UITableViewStyleGrouped];
}

- (id)initWithStyle:(UITableViewStyle)style
{
    return [super initWithStyle:UITableViewStyleGrouped];
}




- (NSArray *)data
{
    if (_data == nil) {
        _data = [NSMutableArray array];
    }
    return _data;
}



- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
    self.navigationItem.leftBarButtonItem = [UIBarButtonItem itemWithImage:@"navigationbar_back" higlightedImage:@"navigationbar_back_highlighted" target:self action:@selector(back)];
  
    self.tableView.rowHeight = 50;
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
    
}

- (void)back
{
    [self.navigationController popViewControllerAnimated:YES];
}


#pragma mark TableView代理方法

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.data.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    WFSettingGroup *group = self.data[section];
    return group.items.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    WFSettingCell *cell = [WFSettingCell cellWithTableView:tableView];
    
    WFSettingGroup *group = self.data[indexPath.section];
    cell.item = group.items[indexPath.row];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
   
    WFSettingGroup *group = self.data[indexPath.section];
    WFSettingItem *item = group.items[indexPath.row];
    
    if (item.option) {
        item.option();
    } else if ([item isKindOfClass:[WFSettingArrowItem class]]) { // 箭头
        WFSettingArrowItem *arrowItem = (WFSettingArrowItem *)item;
        
        if (arrowItem.destVcClass == nil) return;
        
        UIViewController *vc = [[arrowItem.destVcClass alloc] init];
        vc.title = arrowItem.title;
        [self.navigationController pushViewController:vc  animated:YES];
    }
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (self.navigationController.navigationBar.hidden == YES) {
        self.navigationController.navigationBar.hidden = NO;
    }

}


- (void)mainView
{
    [self.navigationController popToRootViewControllerAnimated:YES];
}


@end
