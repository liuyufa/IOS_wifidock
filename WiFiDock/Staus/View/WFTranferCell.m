//
//  WFTranferCell.m
//  WiFiDock
//
//  Created by apple on 15-1-8.
//  Copyright (c) 2015年 cn.hualu.WiFiDock. All rights reserved.
//

#import "WFTranferCell.h"
#import "WFProgress.h"
#import "WFTransferItem.h"
#import "IGLNSOperation.h"
#import "WFActionManager.h"
#import "WFTransferDate.h"

#define KProgressH 10
#define kGap 40
#define KButtonW 30
@interface WFTranferCell ()<UIAlertViewDelegate>

@property(nonatomic,strong)NSTimer *time;

@property (weak, nonatomic) IBOutlet UILabel *titleLableView;

@property (weak, nonatomic) IBOutlet UIProgressView *progress;

@property (weak, nonatomic) IBOutlet UILabel *updateLable;

- (IBAction)cancleClick:(id)sender;


@end

@implementation WFTranferCell




+ (instancetype)cellWithTableView:(UITableView *)tableView
{
    static NSString *CellID = @"tranferCell";
    WFTranferCell *cell = [tableView dequeueReusableCellWithIdentifier:CellID];
    if (cell == nil) {
        cell = [[[NSBundle mainBundle] loadNibNamed:@"WFTranferCell" owner:nil options:nil] lastObject];
        
    }

    return cell;
}


- (void)setItem:(WFTransferItem *)item
{
    _item = item;
    
    self.titleLableView.text =self.item.fileName;

    self.progress.progress = 0.0f;
    self.time = [NSTimer scheduledTimerWithTimeInterval:0.2 target:self selector:@selector(changeValue:) userInfo:nil repeats:YES];

}

- (void)changeValue:(NSTimer *)time
{

    self.progress.progress = [[self.item.operation overedStr] floatValue];
    
    self.updateLable.text = [NSString stringWithFormat:@"%@%@",self.item.percent,@"%"];
    
    float total = [[self.item.operation totalStr] floatValue ];
    float over = [[self.item.operation overedStr] floatValue];
    
    
    self.progress.progress = (over * 1.00)/total;
    int result = (int)(over *100)/total;
   
     self.updateLable.text = [NSString stringWithFormat:@"%d%@",result,@"%"];
    
    if (self.progress.progress == 1) {
        
        [self.time invalidate];
        self.time = nil;
        
        [self removeFromSuperview];
        
    }
}

- (IBAction)cancleClick:(id)sender
{
    NSString *title = NSLocalizedString(@"Warming",nil);
    NSString *msg = NSLocalizedString(@"Are you sure to cancel?",nil);
    
    NSString *cancle = NSLocalizedString(@"Cancel",nil);
    NSString *okbtn = NSLocalizedString(@"Done",nil);
    
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:title message:msg delegate:self cancelButtonTitle:cancle otherButtonTitles:okbtn, nil];
    
    [alert show];

}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) return;
    
    [self.time invalidate];
    self.time = nil;
    [self.item.operation cancel];
    [self removeFromSuperview];
    
    [[NSNotificationCenter defaultCenter]postNotificationName:KProgeress object:nil];
}


@end
