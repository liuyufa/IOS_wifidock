//
//  WFStatusViewController.m
//  WiFiDock
//
//  Created by apple on 14-12-2.
//  Copyright (c) 2014年 cn.hualu.WiFiDock. All rights reserved.
//

#import "WFStatusViewController.h"
#import "WFTranferCell.h"
#import "WFActionManager.h"
#import "UIImage+IW.h"
#import "UIBarButtonItem+IW.h"
#import "WFTransferDate.h"
#import "IGLNSOperation.h"
#import "WFTransferItem.h"

@interface WFStatusViewController ()
@property(nonatomic,strong)NSMutableArray *data;
@end




@implementation WFStatusViewController


-(NSMutableArray *)data
{
    if(!_data){
        _data = [NSMutableArray array];
    }
    return _data;
}

- (id)init
{
    return [super initWithStyle:UITableViewStyleGrouped];
}

- (id)initWithStyle:(UITableViewStyle)style
{
    return [super initWithStyle:UITableViewStyleGrouped];
}




- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setupSubview];
 
    [self setupDate];
    
}

- (void)setupSubview
{
    self.navigationItem.title = NSLocalizedString(@"Status",nil);
    
    
    
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
    
    self.navigationItem.leftBarButtonItem = [UIBarButtonItem itemWithImage:@"navigationbar_back" higlightedImage:@"navigationbar_back_highlighted" target:self action:@selector(back)];
    
    self.tableView.rowHeight = 70;
}

- (void)back
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)setupDate
{
//    WFTransferDate *transferDate = [[WFTransferDate alloc]init];
//    
//    [transferDate loadDate];
    
    NSArray *items = [NSArray array];
    
    items = [WFActionManager sharedManage].optionArray;
    
    NSMutableArray *itemArray = [NSMutableArray array];
    
    for (IGLNSOperation *operation in items) {
        
        if([operation isFinished] || [operation isCancelled]){
            continue;
        }
        
        WFTransferItem *item =[[WFTransferItem alloc]initWithOperation:operation];
        [itemArray addObject:item];
    }

    
    self.data = itemArray;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    WFTranferCell *cell = [WFTranferCell cellWithTableView:tableView];
   
    cell.item = self.data[indexPath.row];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(progressFinish:) name:KProgeress object:nil];
    
    return cell;
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}

- (void)progressFinish:(NSNotification* )notification
{
    [self setupDate];
    [self.tableView reloadData];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.data.count;
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (self.navigationController.navigationBar.hidden == YES) {
        self.navigationController.navigationBar.hidden = NO;
    }
}
-(void)goBack
{
    [self dismissViewControllerAnimated:YES completion:^{
        NSLog(@"go home");
    }];
}

@end
