//
//  IGLCustomAlertView.m
//  IGL004
//
//  Created by apple on 2014/02/26.
//  Copyright (c) 2014年 hualu. All rights reserved.
//

#import "IGLCustomAlertView.h"
#import "IGLActionManager.h"
#import "IGLReachabilityAutoChecker.h"
#import "AssetImageItem.h"
@implementation IGLCustomAlertView
#define checkbox_width (TTIsPad()?47:47)
#define checkbox_height (TTIsPad()?33:33)
-(id)initWithBlock:(IGLCustomViewAlertCompletionBlock)completionBlock
{
	self = [super init];
	if (self)
	{
		self.completionBlock = completionBlock;
        _alertView = [[TTView alloc] initWithFrame:CGRectZero];
        [self addSubview:_alertView];
	}
	return self;
}

-(void)createBackgroundView
{
	self.frame = [[UIScreen mainScreen] bounds];
	self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.0];
	self.opaque = NO;
	UIWindow *appWindow = [[UIApplication sharedApplication] keyWindow];
	[appWindow addSubview:self];
	[UIView animateWithDuration:0.2 animations:^{
		self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.25];
	}];
}

-(void)customView{
}

-(void)animateIn
{
	_alertView.transform = CGAffineTransformMakeScale(0.6, 0.6);
	[UIView animateWithDuration:0.2 animations:^{
		_alertView.transform = CGAffineTransformMakeScale(1.1, 1.1);
	} completion:^(BOOL finished){
		[UIView animateWithDuration:1.0/15.0 animations:^{
			_alertView.transform = CGAffineTransformMakeScale(0.9, 0.9);
		} completion:^(BOOL finished){
			[UIView animateWithDuration:1.0/7.5 animations:^{
				_alertView.transform = CGAffineTransformIdentity;
			}];
		}];
	}];
}

-(void)animateOut
{
	[UIView animateWithDuration:1.0/7.5 animations:^{
		_alertView.transform = CGAffineTransformMakeScale(0.9, 0.9);
	} completion:^(BOOL finished) {
		[UIView animateWithDuration:1.0/15.0 animations:^{
			_alertView.transform = CGAffineTransformMakeScale(1.1, 1.1);
		} completion:^(BOOL finished) {
			[UIView animateWithDuration:0.3 animations:^{
				_alertView.transform = CGAffineTransformMakeScale(0.01, 0.01);
				self.alpha = 0.3;
			} completion:^(BOOL finished){
				[self removeFromSuperview];
			}];
		}];
	}];
}
-(void)show
{
	[self createBackgroundView];
	_alertView.frame = CGRectMake((self.width-280)/2,(self.height-150)/2,280,200);
    [self customView];
	[self becomeFirstResponder];
	[self animateIn];
}
-(void)showAtRect:(CGRect)rect
{
	[self createBackgroundView];
	_alertView.frame = rect;
    [self customView];
	[self becomeFirstResponder];
	[self animateIn];
}

-(void)dismissTableAlert
{
	[self animateOut];
	if (self.completionBlock != nil)
			self.completionBlock(self);
}
-(BOOL)canBecomeFirstResponder
{
	return YES;
}

-(void)canCanelForTouchOutSide{
    UITapGestureRecognizer *tapGr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(viewTapped:)];
    tapGr.cancelsTouchesInView = NO;
    [self addGestureRecognizer:tapGr];
}
-(void)viewTapped:(UITapGestureRecognizer*)tapGr{
    
}
@end

@implementation HaveSameFileWhenPasteAlert

+(HaveSameFileWhenPasteAlert *)alert:(IGLCustomViewAlertCompletionBlock)completionBlock{
    return [[HaveSameFileWhenPasteAlert alloc] initWithBlock:completionBlock];
}
-(void)customView{
    _alertView.backgroundColor = [UIColor whiteColor];
    _titleLabel = [[TTLabel alloc] initWithText:NSLocalizedString(@"Has same file in this folder", nil)];
    _titleLabel.style = IGSTYLE(labelWithBgColor);
    _titleLabel.frame = CGRectMake(5, 5, _alertView.width-10, _alertView.height/5-5);
    [_alertView addSubview:_titleLabel];
    
    //_checkBox = [[IGLCheckBox alloc] initWithFrameTitle:CGRectZero title:NSLocalizedString(@"        Do the same", nil)];
    _checkBox = [[IGLCheckBox alloc] initWithFrame:CGRectZero];
    //_checkBox.frame = CGRectMake(5, CGRectGetMaxY(_titleLabel.frame)+10, _alertView.width-10, _alertView.height/5-10);
    _checkBox.frame = CGRectMake(5, CGRectGetMaxY(_titleLabel.frame)+10, checkbox_width, checkbox_height);
    [_alertView addSubview:_checkBox];
    
    TTLabel *sameLabel = [[TTLabel alloc] initWithText:NSLocalizedString(@"Do the same", nil)];
    sameLabel.style = IGSTYLE(labelWithBgColor_white);
    //sameLabel.backgroundColor = [UIColor whiteColor];
    sameLabel.frame = CGRectMake(CGRectGetMaxX(_checkBox.frame)-5,CGRectGetMaxY(_titleLabel.frame)+10, _alertView.width-10-checkbox_width, _alertView.height/5-5);
    [_alertView addSubview:sameLabel];
    
    _tableView = [[TTTableView alloc] initWithFrame:CGRectZero];
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableView.backgroundColor = [UIColor whiteColor];
    _tableView.dataSource = [TTListDataSource dataSourceWithObjects:
                             [TTTableTextItem itemWithText:NSLocalizedString(@"Cover existed file", nil) delegate:self selector:@selector(doNothing)],
                             [TTTableTextItem itemWithText:NSLocalizedString(@"Skip", nil) delegate:self selector:@selector(doNothing)],
                             [TTTableTextItem itemWithText:NSLocalizedString(@"Append (2) in the last", nil) delegate:self selector:@selector(doNothing)],
                             nil];
    _tableView.delegate = self;
    _tableView.scrollEnabled = NO;
    _tableView.rowHeight = (_alertView.height-10)/5;
    _tableView.frame =CGRectMake(0, CGRectGetMaxY(_checkBox.frame)+5, _alertView.width-4, _tableView.rowHeight*3);
    [_alertView addSubview:_tableView];
}
-(void)dothesameSet{
    _isDoThesame = [_checkBox isCheck];
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self dothesameSet];
    if(indexPath.row == 0){
        _operation = TheSameFileOperationRecover;
    }
    if(indexPath.row == 1){
        _operation = TheSameFileOperationSkip;
    }
    if(indexPath.row == 2){
        _operation = TheSameFileOperationAppendName;
    }
    [self dismissTableAlert];
}
-(void)doNothing{
}
-(BOOL)getisDoThesame{
    return _isDoThesame;
}
-(TheSameFileOperation)getOperation{
    return _operation;
}

@end

@implementation LongPressActionAlert

+(LongPressActionAlert *)alert:(IGLCustomViewAlertCompletionBlock)completionBlock{
    return [[LongPressActionAlert alloc] initWithBlock:completionBlock];
}
-(void)setDataSoureWithTpye:(int)type{
    if(type == 0){
        [self setType0DataSoure];
    }
    else if(type == 1){
        [self setType1DataSoure];
    }
    else if(type == 2){
        [self setType2DataSoure];
    }
    else if (type == 3) {
        [self setType3DataSoure];
    }
}
-(void)setType0DataSoure{
    
    
    _datasoure = [TTListDataSource dataSourceWithObjects:
                  [TTTableTextItem itemWithText:NSLocalizedString(@"copy", nil) delegate:self selector:@selector(doNothing)],
                  [TTTableTextItem itemWithText:NSLocalizedString(@"Cut", nil) delegate:self selector:@selector(doNothing)],
                  [TTTableTextItem itemWithText:NSLocalizedString(@"Delete", nil) delegate:self selector:@selector(doNothing)],
                  [TTTableTextItem itemWithText:NSLocalizedString(@"Rename", nil) delegate:self selector:@selector(doNothing)],
                  nil];
    
    operationList = [NSArray arrayWithObjects:[NSNumber numberWithInt:ActionCopy],
                                              [NSNumber numberWithInt:ActionCut],
                                              [NSNumber numberWithInt:ActionDelete],
                                              [NSNumber numberWithInt:ActionRename],nil];

}
-(void)setType1DataSoure{
    _datasoure = [TTListDataSource dataSourceWithObjects:
                  [TTTableTextItem itemWithText:NSLocalizedString(@"Delete", nil) delegate:self selector:@selector(doNothing)],
                  [TTTableTextItem itemWithText:NSLocalizedString(@"Rename", nil) delegate:self selector:@selector(doNothing)],
                  [TTTableTextItem itemWithText:NSLocalizedString(@"Get Property", nil) delegate:self selector:@selector(doNothing)],
                  nil];
    
    operationList = [NSArray arrayWithObjects:[NSNumber numberWithInt:ActionDelete],
                     [NSNumber numberWithInt:ActionRename],
                     [NSNumber numberWithInt:ActionGetProperty],nil];
}
-(void)setType2DataSoure{
    _datasoure = [TTListDataSource dataSourceWithObjects:
                  [TTTableTextItem itemWithText:NSLocalizedString(@"Delete", nil) delegate:self selector:@selector(doNothing)],
                  [TTTableTextItem itemWithText:NSLocalizedString(@"Rename", nil) delegate:self selector:@selector(doNothing)],
                  [TTTableTextItem itemWithText:NSLocalizedString(@"Get Property", nil) delegate:self selector:@selector(doNothing)],
                  [TTTableTextItem itemWithText:NSLocalizedString(@"Share", nil) delegate:self selector:@selector(doNothing)],
                  nil];
    
    operationList = [NSArray arrayWithObjects:[NSNumber numberWithInt:ActionDelete],
                     [NSNumber numberWithInt:ActionRename],
                     [NSNumber numberWithInt:ActionGetProperty],
                     [NSNumber numberWithInt:ActionShare],nil];
}
-(void)setType3DataSoure{
    _datasoure = [TTListDataSource dataSourceWithObjects:
                  //[TTTableTextItem itemWithText:NSLocalizedString(@"Delete", nil) delegate:self selector:@selector(doNothing)],
                  //[TTTableTextItem itemWithText:NSLocalizedString(@"Rename", nil) delegate:self selector:@selector(doNothing)],
                  [TTTableTextItem itemWithText:NSLocalizedString(@"Get Property", nil) delegate:self selector:@selector(doNothing)],
                  [TTTableTextItem itemWithText:NSLocalizedString(@"Share", nil) delegate:self selector:@selector(doNothing)],
                  nil];
    
    operationList = [NSArray arrayWithObjects:
                     //[NSNumber numberWithInt:ActionDelete],
                     //[NSNumber numberWithInt:ActionRename],
                     [NSNumber numberWithInt:ActionGetProperty],
                     [NSNumber numberWithInt:ActionShare],nil];
}
-(void)customView{
    _alertView.backgroundColor = [UIColor whiteColor];
    _titleLabel = [[TTLabel alloc] initWithText:NSLocalizedString(@"Menu", nil)];
    _titleLabel.style = IGSTYLE(labelWithBgColor_black);
    _titleLabel.frame = CGRectMake(0, 0, _alertView.width, _alertView.height/([_datasoure.items count] + 1));
    [_alertView addSubview:_titleLabel];
    
    _tableView = [[TTTableView alloc] initWithFrame:CGRectZero];
    _tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    _tableView.backgroundColor = [UIColor whiteColor];
    _tableView.dataSource = _datasoure;
    _tableView.delegate = self;
    _tableView.scrollEnabled = NO;
    _tableView.rowHeight = (_alertView.height)/([_datasoure.items count] + 1);
    _tableView.frame =CGRectMake(0, CGRectGetMaxY(_titleLabel.frame), _alertView.width-4, _tableView.rowHeight*[_datasoure.items count]);
    [_alertView addSubview:_tableView];
    
    [self canCanelForTouchOutSide];
}
-(void)viewTapped:(UITapGestureRecognizer*)tapGr{
    if (CGRectContainsPoint(_alertView.frame, [tapGr locationInView:self])){
        return;
    }
    _operation = ActionNone;
    [self dismissTableAlert];
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
//    if(indexPath.row == 0){
        _operation = [[operationList objectAtIndex:indexPath.row] integerValue];
//    }
//    if(indexPath.row == 1){
//        _operation = ActionCut;
//    }
//    if(indexPath.row == 2){
//        _operation = ActionDelete;
//    }
//    if(indexPath.row == 3){
//        _operation = ActionRename;
//    }
    [self dismissTableAlert];
}
-(void)doNothing{
}
-(ActionOperation)getOperation{
    return _operation;
}

@end

@implementation DeleteActionAlert

-(void)show
{
	[self createBackgroundView];
	_alertView.frame = CGRectMake((self.width-280)/2,(self.height-150)/2,280,160);
    [self customView];
	[self becomeFirstResponder];
	[self animateIn];
}

+(DeleteActionAlert *)alert:(IGLCustomViewAlertCompletionBlock)completionBlock{
    return [[DeleteActionAlert alloc] initWithBlock:completionBlock];
}
-(void)customView{
    _alertView.backgroundColor = [UIColor whiteColor];
    _titleLabel = [[TTLabel alloc] initWithText:NSLocalizedString(@"Prompting", nil)];
    _titleLabel.style = IGSTYLE(labelWithBgColor);
    _titleLabel.frame = CGRectMake(5, 5, _alertView.width-10, _alertView.height/4-5);
    [_alertView addSubview:_titleLabel];
    
    _messageLabel = [[TTLabel alloc] initWithText:NSLocalizedString(@"Are you sure to delete the file(s)/folder(s)?", nil)];
    _messageLabel.backgroundColor = [UIColor clearColor];
    _messageLabel.style = IGSTYLE(labelMessage);
    _messageLabel.frame = CGRectMake(5, CGRectGetMaxY(_titleLabel.frame) + 10, _alertView.width-10, _alertView.height/2-15);
    [_alertView addSubview:_messageLabel];
    
    _comfirmBtn = [IGLButton buttonWithStyle:@"normalForMessageButton:" title:NSLocalizedString(@"Comfirm", nil)];
    _comfirmBtn.frame = CGRectMake(10, CGRectGetMaxY(_messageLabel.frame), _alertView.width/2-15, _alertView.height/4);
    [_comfirmBtn addTarget:self action:@selector(clickComfirm) forControlEvents:UIControlEventTouchUpInside];
    [_alertView addSubview:_comfirmBtn];
    
    _cancelBtn = [IGLButton buttonWithStyle:@"normalForMessageButton:" title:NSLocalizedString(@"Cancel", nil)];
    _cancelBtn.frame = CGRectMake(CGRectGetMaxX(_comfirmBtn.frame) + 10, CGRectGetMaxY(_messageLabel.frame), _alertView.width/2-15, _alertView.height/4);
    [_cancelBtn addTarget:self action:@selector(clickCancel) forControlEvents:UIControlEventTouchUpInside];
    [_alertView addSubview:_cancelBtn];
}
-(void)clickComfirm{
    _comfirm = YES;
    [self dismissTableAlert];
}
-(void)clickCancel{
    _comfirm = NO;
    [self dismissTableAlert];
}
-(BOOL)getComfirm{
    return _comfirm;
}

@end

@implementation RenameActionAlert

-(void)show
{
	[self createBackgroundView];
	_alertView.frame = CGRectMake((self.width-280)/2,(self.height-150)/2,280,140);
    [self customView];
	[self becomeFirstResponder];
	[self animateIn];
}
-(void)showForNewFolder{
    [self createBackgroundView];
	_alertView.frame = CGRectMake((self.width-280)/2,(self.height-150)/2,280,140);
    [self customView];
    [_titleLabel setText:NSLocalizedString(@"New folder", nil)];
	[self becomeFirstResponder];
	[self animateIn];
}

+(RenameActionAlert *)alert:(IGLCustomViewAlertCompletionBlock)completionBlock{
    return [[RenameActionAlert alloc] initWithBlock:completionBlock];
}
-(void)customView{
    _alertView.backgroundColor = [UIColor whiteColor];
    _titleLabel = [[TTLabel alloc] initWithText:NSLocalizedString(@"Rename", nil)];
    _titleLabel.style = IGSTYLE(labelWithBgColor);
    _titleLabel.frame = CGRectMake(5, 5, _alertView.width-10, (_alertView.height-20)/3-5);
    [_alertView addSubview:_titleLabel];
    
    _nameTextField = [[UITextField alloc] init];
    _nameTextField.frame = CGRectMake(10, CGRectGetMaxY(_titleLabel.frame)+5, _alertView.width-20, _alertView.height/3-5);
    _nameTextField.delegate = self;
    _nameTextField.returnKeyType = UIReturnKeyDone;
    _nameTextField.layer.borderWidth = 1;
    _nameTextField.layer.borderColor = RGBACOLOR(81, 151, 19, 0.5).CGColor;
    _nameTextField.layer.cornerRadius = 5;
    _nameTextField.layer.backgroundColor = [UIColor whiteColor].CGColor;
    _nameTextField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    _nameTextField.leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 10)];
    _nameTextField.leftViewMode = UITextFieldViewModeAlways;
    [_alertView addSubview:_nameTextField];
    
    _comfirmBtn = [IGLButton buttonWithStyle:@"normalForMessageButton:" title:NSLocalizedString(@"Comfirm", nil)];
    _comfirmBtn.frame = CGRectMake(10, CGRectGetMaxY(_nameTextField.frame)+10, _alertView.width/2-15, _alertView.height/3-10);
    [_comfirmBtn addTarget:self action:@selector(clickComfirm) forControlEvents:UIControlEventTouchUpInside];
    [_alertView addSubview:_comfirmBtn];
    
    _cancelBtn = [IGLButton buttonWithStyle:@"normalForMessageButton:" title:NSLocalizedString(@"Cancel", nil)];
    _cancelBtn.frame = CGRectMake(CGRectGetMaxX(_comfirmBtn.frame) + 10, CGRectGetMaxY(_nameTextField.frame)+10, _alertView.width/2-15, _alertView.height/3-10);
    [_cancelBtn addTarget:self action:@selector(clickCancel) forControlEvents:UIControlEventTouchUpInside];
    [_alertView addSubview:_cancelBtn];
}
-(void)clickComfirm{
    _name = _nameTextField.text;
    [_nameTextField resignFirstResponder];
    [self dismissTableAlert];
}
-(void)clickCancel{
    _name = @"";
    [_nameTextField resignFirstResponder];
    [self dismissTableAlert];
}
-(NSString*)rename{
    return _name;
}
-(void)rename:(NSString*)name{
    _name = name;
    _nameTextField.text = _name;
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [_nameTextField resignFirstResponder];
    return YES;
}
@end


@implementation DisplayTextItem:TTTableTextItem
@end
@implementation DisplayTextItemCell:TTTableTextItemCell
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString*)identifier {
	self = [super initWithStyle:style reuseIdentifier:identifier];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.selectedBackgroundView = [[UIView alloc] initWithFrame:self.bounds];
        self.selectedBackgroundView.backgroundColor = [UIColor lightGrayColor];
    }
    
    return self;
}
- (void)setObject:(id)object {
    if (_item != object) {
        [super setObject:object];
        
        TTTableTextItem* item = object;
        self.textLabel.text = item.text;
        self.textLabel.backgroundColor = [UIColor clearColor];
        self.textLabel.font = [UIFont systemFontOfSize:15];
        self.textLabel.textColor = [UIColor whiteColor];
        self.textLabel.textAlignment = UITextAlignmentLeft;
        
        self.selectionStyle = UITableViewCellSelectionStyleGray;
    }
}
- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.textLabel.frame = CGRectInset(self.contentView.bounds,
                                       kTableCellHPadding, 0);
}
@end
@implementation DisplayDataSoure:TTListDataSource
- (Class)tableView:(UITableView*)tableView cellClassForObject:(id) object {
    if([object isKindOfClass:[DisplayTextItem class]]){
        return [DisplayTextItemCell class];
    }
    return [super tableView:tableView cellClassForObject:object];
}
@end

@implementation DisplayActionAlert
-(void)createBackgroundView
{
	self.frame = [[UIScreen mainScreen] bounds];
	self.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.0];
	self.opaque = NO;
	UIWindow *appWindow = [[UIApplication sharedApplication] keyWindow];
	[appWindow addSubview:self];
	[UIView animateWithDuration:0.2 animations:^{
		self.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.0];
	}];
}
+(DisplayActionAlert *)alert:(IGLCustomViewAlertCompletionBlock)completionBlock{
    return [[DisplayActionAlert alloc] initWithBlock:completionBlock];
}
-(void)showAtRect:(CGRect)rect
{
	[self createBackgroundView];
	_alertView.frame = rect;
    [self customView];
	[self becomeFirstResponder];
	[self animateIn];
}
-(void)customView{
    _alertView.backgroundColor = [UIColor whiteColor];
    _tableView = [[TTTableView alloc] initWithFrame:CGRectZero];
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableView.backgroundColor = RGBACOLOR(150,203,90,1);
    _tableView.dataSource = [DisplayDataSoure dataSourceWithObjects:
                             [DisplayTextItem itemWithText:NSLocalizedString(@"列表显示", nil)],
                             [DisplayTextItem itemWithText:NSLocalizedString(@"按名称排序", nil)],
                             [DisplayTextItem itemWithText:NSLocalizedString(@"按大小排序", nil)],
                             [DisplayTextItem itemWithText:NSLocalizedString(@"按时间排序", nil)],
                             nil];
    _tableView.delegate = self;
    _tableView.scrollEnabled = NO;
    _tableView.frame = CGRectMake(0, 0, _alertView.width, _alertView.height);
    _tableView.rowHeight = (_alertView.height)/4;
    [_alertView addSubview:_tableView];
    
    [self canCanelForTouchOutSide];
}
-(void)viewTapped:(UITapGestureRecognizer*)tapGr{
    if (CGRectContainsPoint(_alertView.frame, [tapGr locationInView:self])){
        return;
    }
    _operation = ActionNone;
    [self dismissTableAlert];
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
    if(indexPath.row == 0){
        _operation = ActionDisplay;
    }
    if(indexPath.row == 1){
        _operation = ActionSortByName;
    }
    if(indexPath.row == 2){
        _operation = ActionSortBySize;
    }
    if(indexPath.row == 3){
        _operation = ActionSortByTime;
    }
    [self dismissTableAlert];
}
-(ActionOperation)getOperation{
    return _operation;
}

@end


@implementation SearchTextItem:TTTableTextItem
@end
@implementation SearchTextItemCell:TTTableTextItemCell
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString*)identifier {
	self = [super initWithStyle:style reuseIdentifier:identifier];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.selectedBackgroundView = [[UIView alloc] initWithFrame:self.bounds];
        self.selectedBackgroundView.backgroundColor = [UIColor lightGrayColor];
    }
    
    return self;
}
- (void)setObject:(id)object {
    if (_item != object) {
        [super setObject:object];
        
        TTTableTextItem* item = object;
        self.textLabel.text = item.text;
        self.textLabel.backgroundColor = [UIColor clearColor];
        self.textLabel.font = [UIFont systemFontOfSize:15];
        self.textLabel.textColor = [UIColor whiteColor];
        self.textLabel.textAlignment = UITextAlignmentLeft;
        
        self.selectionStyle = UITableViewCellSelectionStyleGray;
    }
}
- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.textLabel.frame = CGRectInset(self.contentView.bounds,
                                       kTableCellHPadding, 0);
}
@end
@implementation SearchDataSoure:TTListDataSource
- (Class)tableView:(UITableView*)tableView cellClassForObject:(id) object {
    if([object isKindOfClass:[SearchTextItem class]]){
        return [SearchTextItemCell class];
    }
    return [super tableView:tableView cellClassForObject:object];
}
@end

@implementation SearchActionAlert
-(void)createBackgroundView
{
	self.frame = [[UIScreen mainScreen] bounds];
	self.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.0];
	self.opaque = NO;
	UIWindow *appWindow = [[UIApplication sharedApplication] keyWindow];
	[appWindow addSubview:self];
	[UIView animateWithDuration:0.2 animations:^{
		self.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.0];
	}];
}
+(SearchActionAlert *)alert:(IGLCustomViewAlertCompletionBlock)completionBlock{
    return [[SearchActionAlert alloc] initWithBlock:completionBlock];
}
-(void)setDataArray:(NSArray*)array{
    _dataArray = array;
}
-(void)showAtRect:(CGRect)rect
{
	[self createBackgroundView];
	_alertView.frame = rect;
    [self customView];
	[self becomeFirstResponder];
	[self animateIn];
}
-(void)customView{
    _alertView.backgroundColor = [UIColor whiteColor];
    _tableView = [[TTTableView alloc] initWithFrame:CGRectZero];
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableView.backgroundColor = RGBACOLOR(150,203,90,1);
    NSMutableArray *items = [NSMutableArray array];
    [items addObject:[SearchTextItem itemWithText:NSLocalizedString(@"文件名", nil)]];
    for(NSString *data in _dataArray) {
        SearchTextItem *item = [SearchTextItem itemWithText:data];
        [items addObject:item];
    }
    _tableView.dataSource = [SearchDataSoure dataSourceWithItems:items];;
    
    _tableView.delegate = self;
    _tableView.scrollEnabled = NO;
    _tableView.frame = CGRectMake(0, 0, _alertView.width, _alertView.height);
    _tableView.rowHeight = (_alertView.height)/[items count];
    [_alertView addSubview:_tableView];
    
    [self canCanelForTouchOutSide];
}
-(void)viewTapped:(UITapGestureRecognizer*)tapGr{
    if (CGRectContainsPoint(_alertView.frame, [tapGr locationInView:self])){
        return;
    }
    _operation = @"";
    [self dismissTableAlert];
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
    if(indexPath.row == 0){
        _operation = @"searchbyname";
    }else{
        _operation = [NSString stringWithFormat:@".%@",[[_dataArray objectAtIndex:indexPath.row-1] lowercaseString]];
    }
    [self dismissTableAlert];
}
-(NSString*)getOperation{
    return _operation;
}
@end


@implementation contentForProptiesView:UIView
-(id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if(self){
        _pathLabel = [[TTLabel alloc] initWithFrame:CGRectZero];
        _pathLabel.backgroundColor = [UIColor clearColor];
        _pathLabel.style = IGSTYLE(labelPath);
        [self addSubview:_pathLabel];
        self.backgroundColor = [UIColor clearColor];
        _contentList = [NSArray array];
        _titleList = [NSArray arrayWithObjects:
                      NSLocalizedString(@"Type", nil),
                      NSLocalizedString(@"Path", nil),
                      NSLocalizedString(@"Contains", nil),
                      NSLocalizedString(@"Size", nil),
                      NSLocalizedString(@"Created", nil),
                      NSLocalizedString(@"Modified", nil),
                      NSLocalizedString(@"Writeable", nil),
                      NSLocalizedString(@"Readable", nil),
                      NSLocalizedString(@"Hide", nil),nil];
    }
    return self;
}
-(void)setContent:(NSArray*)array{
    _contentList = array;
    [self setNeedsDisplay];
}
- (void)drawRect:(CGRect)rect{
    if([_contentList count] == 0){
        return;
    }
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(ctx, [UIColor blackColor].CGColor);
    CGContextSetStrokeColorWithColor(ctx, [UIColor blackColor].CGColor);
    CGContextSetLineWidth(ctx,1);
    NSString *fileName = [_contentList objectAtIndex:0];
    
    float x = 0;
    float y = 0;
    float w = self.width;
    float h = 25;
    
    float offsetY = 0;
    
    [fileName drawInRect:CGRectMake(x + 5, y + offsetY, w, h)
                withFont:[UIFont boldSystemFontOfSize:17.0f]
           lineBreakMode:4
               alignment:0];
    CGContextSetStrokeColorWithColor(ctx, [UIColor lightGrayColor].CGColor);
    [self drawLineFrom:CGPointMake(0, h + 2 ) to:CGPointMake(w, h + 2 )];
    CGContextSetStrokeColorWithColor(ctx, [UIColor blackColor].CGColor);
    offsetY = offsetY + h + 5;
    for (int i = 0; i < [_titleList count]; i++) {
        NSString *title = [NSString stringWithFormat:@"%@:",[_titleList objectAtIndex:i]];
        NSString *content = [_contentList objectAtIndex:i+1];
        
        [title drawInRect:CGRectMake(x, y + offsetY, w/4, h)
                    withFont:[UIFont boldSystemFontOfSize:13.0f]
               lineBreakMode:4
                   alignment:2];
        if(i==1){
            _pathLabel.text = content;
            _pathLabel.frame = CGRectMake(w/4 + 5, y + offsetY, w*3/4-10, h);
            [_pathLabel sizeToFit];
            offsetY = offsetY + (_pathLabel.size.height > h?_pathLabel.size.height:h);
        }else{
            [content drawInRect:CGRectMake(w/4 + 5, y + offsetY, w*3/4, h)
                       withFont:[UIFont systemFontOfSize:13.0f]
                  lineBreakMode:0
                      alignment:0];
             offsetY = offsetY + h;
        }
        if(i == 3 || i == 5){
            CGContextSetStrokeColorWithColor(ctx, [UIColor lightGrayColor].CGColor);
            [self drawLineFrom:CGPointMake(0, offsetY - 5 ) to:CGPointMake(w, offsetY - 5 )];
            CGContextSetStrokeColorWithColor(ctx, [UIColor blackColor].CGColor);
        }
    }
}
@end;

@implementation GetProptiesActionAlert

-(void)show
{
	[self createBackgroundView];
	_alertView.frame = CGRectMake((self.width-280)/2,(self.height-300)/2,280,300);
    [self customView];
	[self becomeFirstResponder];
	[self animateIn];
}

+(GetProptiesActionAlert *)alert:(IGLCustomViewAlertCompletionBlock)completionBlock{
    return [[GetProptiesActionAlert alloc] initWithBlock:completionBlock];
}
-(void)customView{
    _alertView.backgroundColor = [UIColor whiteColor];
    _titleLabel = [[TTLabel alloc] initWithText:NSLocalizedString(@"File Propties", nil)];
    _titleLabel.style = IGSTYLE(labelWithBgColor);
    _titleLabel.frame = CGRectMake(5, 5, _alertView.width-10, 35);
    [_alertView addSubview:_titleLabel];
    
    _contentView = [[contentForProptiesView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(_titleLabel.frame), CGRectGetWidth(_alertView.frame), CGRectGetHeight(_alertView.frame) - CGRectGetMaxY(_titleLabel.frame))];
    [_alertView addSubview:_contentView];
    
    [self canCanelForTouchOutSide];
}
-(void)viewTapped:(UITapGestureRecognizer*)tapGr{
    if (CGRectContainsPoint(_alertView.frame, [tapGr locationInView:self])){
        return;
    }
    [self dismissTableAlert];
}
-(void)setContext:(id)context{
    if([context isKindOfClass:[IGLSMBItem class]]){
        IGLSMBItem *o = context;
        NSString *filename = o.name;
        NSString *type = o.type == IGLSMBItemTypeFile?NSLocalizedString(@"File", nil):NSLocalizedString(@"Folder", nil);
        NSString *path = [o.path stringByDeletingSMBLastPathComponent];
        NSString *contains = @"";
        NSString *size = [NSString stringWithFormat:@"%.2lfMB", o.stat.size/(1000.0*1000.0)];
        NSString *created = o.stat.createTime?[o.stat.createTime stringWithFormat:DATETIME_FORMAT_1]:@"";
        NSString *modified = o.stat.lastModified?[o.stat.lastModified stringWithFormat:DATETIME_FORMAT_1]:@"";
        
        BOOL canRead = ((o.stat.mode&S_IRUSR) == S_IRUSR);
        BOOL canWrite = ((o.stat.mode&S_IWUSR) == S_IWUSR);
        BOOL isHidden = ((o.stat.mode&S_IXOTH) == S_IXOTH);
        
        NSString *write = canWrite?NSLocalizedString(@"YES", nil):NSLocalizedString(@"NO", nil);
        NSString *read = canRead?NSLocalizedString(@"YES", nil):NSLocalizedString(@"NO", nil);
        NSString *hidden = isHidden?NSLocalizedString(@"YES", nil):NSLocalizedString(@"NO", nil);
        [_contentView setContent:[NSArray arrayWithObjects:
                                  filename,
                                  type,
                                  path,
                                  contains,
                                  size,
                                  created,
                                  modified,
                                  write,
                                  read,
                                  hidden,nil]];
    }
    if([context isKindOfClass:[LocalContext class]]){
        LocalContext *o = context;
        NSString *filename = o.fileName;
        NSString *type = o.type == LocalContextTypeFile?NSLocalizedString(@"File", nil):NSLocalizedString(@"Folder", nil);
        NSString *path = [[o.filePath stringByDeletingSMBLastPathComponent]  stringByReplacingOccurrencesOfString:[FileUtils getDocumentPath] withString:LOCAL_PATH_PREFIX];
        if ([path isEqualToString:@""]) {
            path = o.filePath;
        }
        NSString *contains = o.contains;
        if (contains == nil) {
            contains = @"mobile";
        }
        NSString *size = [NSString stringWithFormat:@"%.2lfMB", o.size/(1000.0*1000.0)];
        NSString *created = o.createTime?[o.createTime stringWithFormat:DATETIME_FORMAT_1]:@"";
        NSString *modified = o.lastModified?[o.lastModified stringWithFormat:DATETIME_FORMAT_1]:@"";
        NSString *write = o.canWrite?NSLocalizedString(@"YES", nil):NSLocalizedString(@"NO", nil);
        //NSString *read = o.canRead?NSLocalizedString(@"YES", nil):NSLocalizedString(@"NO", nil);
        NSString *read = NSLocalizedString(@"YES", nil);
        NSString *hidden = o.isHidden?NSLocalizedString(@"YES", nil):NSLocalizedString(@"NO", nil);
        [_contentView setContent:[NSArray arrayWithObjects:
                                  filename,
                                  type,
                                  path,
                                  contains,
                                  size,
                                  created,
                                  modified,
                                  write,
                                  read,
                                  hidden,nil]];
    }
}
@end

@implementation BackupActionAlert

+(BackupActionAlert *)alertback:(IGLCustomViewAlertCompletionBlock)completionBlock{
    return [[BackupActionAlert alloc] initWithBlock:completionBlock];
}

-(void)setTitile:(NSString*)title{
    _title = title;
}

-(void)setType0DataSoure{
    
    NSMutableArray *itms = [NSMutableArray array];
    NSMutableArray *paths = [NSMutableArray array];
    
    if([Reachability sambaStatus]){
        if([[IGLReachabilityAutoChecker sharedChecker] wifidockPath]){
            [itms addObject:[TTTableTextItem itemWithText:NSLocalizedString(@"WifiDock", nil) delegate:self selector:@selector(doNothing)]];
            [paths addObject:[[IGLReachabilityAutoChecker sharedChecker] wifidockPath]];
        }
        if([[IGLReachabilityAutoChecker sharedChecker] tfPath]){
            [itms addObject:[TTTableTextItem itemWithText:NSLocalizedString(@"TF", nil) delegate:self selector:@selector(doNothing)]];
            [paths addObject:[[IGLReachabilityAutoChecker sharedChecker] tfPath]];
        }
        if([[IGLReachabilityAutoChecker sharedChecker] usbPath]){
            [itms addObject:[TTTableTextItem itemWithText:NSLocalizedString(@"USB", nil) delegate:self selector:@selector(doNothing)]];
            [paths addObject:[[IGLReachabilityAutoChecker sharedChecker] usbPath]];
        }
    }
    [itms addObject:[TTTableTextItem itemWithText:NSLocalizedString(@"Local", nil) delegate:self selector:@selector(doNothing)]];
    [paths addObject:[FileUtils getDocumentPath]];
    _datasoure = [TTListDataSource dataSourceWithItems:itms];
    
    operationList = [NSArray arrayWithArray:paths];
    
}

-(void)customView{
    _alertView.backgroundColor = [UIColor whiteColor];
    _titleLabel = [[TTLabel alloc] initWithText:_title];
    _titleLabel.style = IGSTYLE(labelWithBgColor_black);
    _titleLabel.frame = CGRectMake(0, 0, _alertView.width, _alertView.height/([_datasoure.items count] + 1));
    [_alertView addSubview:_titleLabel];
    
    _tableView = [[TTTableView alloc] initWithFrame:CGRectZero];
    _tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    _tableView.backgroundColor = [UIColor whiteColor];
    _tableView.dataSource = _datasoure;
    _tableView.delegate = self;
    _tableView.scrollEnabled = NO;
    [_tableView setEditing:NO];
    _tableView.rowHeight = (_alertView.height)/([_datasoure.items count] + 1);
    _tableView.frame =CGRectMake(0, CGRectGetMaxY(_titleLabel.frame), _alertView.width-4, _tableView.rowHeight*[_datasoure.items count]);
    [_alertView addSubview:_tableView];
    
    [self canCanelForTouchOutSide];
    
}
-(void)viewTapped:(UITapGestureRecognizer*)tapGr{
    if (CGRectContainsPoint(_alertView.frame, [tapGr locationInView:self])){
        return;
    }
    _copypath = nil;
    [self dismissTableAlert];
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
    _copypath = [operationList objectAtIndex:indexPath.row];
    [self dismissTableAlert];
}
-(void)show
{
	[self createBackgroundView];
	_alertView.frame = CGRectMake(0,0,280,([_datasoure.items count] +1)*50);
    _alertView.center = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame));
    [self customView];
	[self becomeFirstResponder];
	[self animateIn];
}
-(void)doNothing{
}
-(NSString*)copyPath{
    return _copypath;
}
@end
