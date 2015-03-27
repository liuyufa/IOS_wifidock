//
//  IGLCustomAlertView.h
//  IGL004
//
//  Created by apple on 2014/02/26.
//  Copyright (c) 2014年 hualu. All rights reserved.
//

#import <UIKit/UIKit.h>
//#import <Three20UI/Three20UI.h>
//#import "IGLCheckBox.h"
#import "IGLSMBProvier.h"
//#import "LocalContext.h"

@class IGLCustomAlertView;
typedef void (^IGLCustomViewAlertCompletionBlock)(IGLCustomAlertView *view);

@interface IGLCustomAlertView : UIView{
    TTView* _alertView;
}
@property (nonatomic, strong) IGLCustomViewAlertCompletionBlock completionBlock;
-(id)initWithBlock:(IGLCustomViewAlertCompletionBlock)completionBlock;
-(void)show;
-(void)showAtRect:(CGRect)rect;
-(void)customView;
-(void)animateIn;
-(void)animateOut;
-(void)dismissTableAlert;
-(void)canCanelForTouchOutSide;
-(void)createBackgroundView;
@end

@interface HaveSameFileWhenPasteAlert : IGLCustomAlertView<TTTableViewDelegate>{
    TTLabel *_titleLabel;
    IGLCheckBox *_checkBox;
    TTTableView* _tableView;
    BOOL _isDoThesame;
    TheSameFileOperation _operation;
}
+(HaveSameFileWhenPasteAlert *)alert:(IGLCustomViewAlertCompletionBlock)cellsBlock;
-(BOOL)getisDoThesame;
-(TheSameFileOperation)getOperation;
@end
@interface LongPressActionAlert : IGLCustomAlertView<TTTableViewDelegate>{
    TTLabel *_titleLabel;
    TTTableView* _tableView;
    ActionOperation _operation;
    TTListDataSource *_datasoure;
    NSArray *operationList;
}
+(LongPressActionAlert *)alert:(IGLCustomViewAlertCompletionBlock)cellsBlock;
-(ActionOperation)getOperation;
-(void)setDataSoureWithTpye:(int)type;
@end
@interface DeleteActionAlert : IGLCustomAlertView{
    TTLabel *_titleLabel;
    TTLabel *_messageLabel;
    IGLButton *_comfirmBtn;
    IGLButton *_cancelBtn;
    BOOL _comfirm;
}
+(DeleteActionAlert *)alert:(IGLCustomViewAlertCompletionBlock)cellsBlock;
-(BOOL)getComfirm;
@end
@interface RenameActionAlert : IGLCustomAlertView<UITextFieldDelegate>{
    TTLabel *_titleLabel;
    UITextField *_nameTextField;
    IGLButton *_comfirmBtn;
    IGLButton *_cancelBtn;
    NSString *_name;
}
+(RenameActionAlert *)alert:(IGLCustomViewAlertCompletionBlock)cellsBlock;
-(NSString*)rename;
-(void)rename:(NSString*)name;
-(void)showForNewFolder;
@end
@interface DisplayActionAlert : IGLCustomAlertView<TTTableViewDelegate>{
    TTTableView* _tableView;
    ActionOperation _operation;
}
+(DisplayActionAlert *)alert:(IGLCustomViewAlertCompletionBlock)cellsBlock;
-(ActionOperation)getOperation;
@end
@interface DisplayTextItem:TTTableTextItem
@end
@interface DisplayTextItemCell:TTTableTextItemCell
@end
@interface DisplayDataSoure:TTListDataSource
@end

@interface SearchActionAlert : IGLCustomAlertView<TTTableViewDelegate>{
    TTTableView* _tableView;
    NSString *_operation;
    NSArray *_dataArray;
}
+(SearchActionAlert *)alert:(IGLCustomViewAlertCompletionBlock)cellsBlock;
-(void)setDataArray:(NSArray*)array;
-(NSString *)getOperation;
@end
@interface SearchTextItem:TTTableTextItem
@end
@interface SearchTextItemCell:TTTableTextItemCell
@end
@interface SearchDataSoure:TTListDataSource
@end

@interface contentForProptiesView:UIView{
    NSArray *_contentList;
    NSArray *_titleList;
    TTLabel *_pathLabel;
}
-(void)setContent:(NSArray*)array;
@end

@interface GetProptiesActionAlert : IGLCustomAlertView{
    TTLabel *_titleLabel;
    contentForProptiesView *_contentView;
}
+(GetProptiesActionAlert *)alert:(IGLCustomViewAlertCompletionBlock)cellsBlock;
-(void)setContext:(id)context;

@end

@interface BackupActionAlert : IGLCustomAlertView<TTTableViewDelegate>{
    NSString *_title;
    NSString *_copypath;
    TTLabel *_titleLabel;
    TTTableView* _tableView;
    TTListDataSource *_datasoure;
    NSArray *operationList;
}
-(void)setTitile:(NSString*)title;
+(BackupActionAlert *)alertback:(IGLCustomViewAlertCompletionBlock)cellsBlock;
-(NSString*)copyPath;
-(void)setType0DataSoure;
@end