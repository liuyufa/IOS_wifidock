//
//  WFTableAlert.h
//  WiFiDock
//
//  Created by apple on 15-1-12.
//  Copyright (c) 2015年 cn.hualu.WiFiDock. All rights reserved.
//

#import <UIKit/UIKit.h>

@class WFTableAlert;

typedef NSInteger (^WFTableAlertNumberOfRowsBlock)(NSInteger section);
typedef UITableViewCell* (^WFTableAlertTableCellsBlock)(WFTableAlert *alert, NSIndexPath *indexPath);
typedef void (^WFTableAlertRowSelectionBlock)(NSIndexPath *selectedIndex);
typedef void (^WFTableAlertCompletionBlock)(void);

@interface WFTableAlert : UIView

@property (nonatomic, strong) UITableView *table;

@property (nonatomic, assign) CGFloat height;

@property (nonatomic, strong) WFTableAlertCompletionBlock completionBlock;

@property (nonatomic, strong) WFTableAlertRowSelectionBlock selectionBlock;


+(WFTableAlert *)tableAlertWithTitle:(NSString *)title cancelButtonTitle:(NSString *)cancelBtnTitle numberOfRows:(WFTableAlertNumberOfRowsBlock)rowsBlock andCells:(WFTableAlertTableCellsBlock)cellsBlock;


-(id)initWithTitle:(NSString *)title cancelButtonTitle:(NSString *)cancelBtnTitle numberOfRows:(WFTableAlertNumberOfRowsBlock)rowsBlock andCells:(WFTableAlertTableCellsBlock)cellsBlock;


-(void)configureSelectionBlock:(WFTableAlertRowSelectionBlock)selBlock andCompletionBlock:(WFTableAlertCompletionBlock)comBlock;


-(void)show;

@end
