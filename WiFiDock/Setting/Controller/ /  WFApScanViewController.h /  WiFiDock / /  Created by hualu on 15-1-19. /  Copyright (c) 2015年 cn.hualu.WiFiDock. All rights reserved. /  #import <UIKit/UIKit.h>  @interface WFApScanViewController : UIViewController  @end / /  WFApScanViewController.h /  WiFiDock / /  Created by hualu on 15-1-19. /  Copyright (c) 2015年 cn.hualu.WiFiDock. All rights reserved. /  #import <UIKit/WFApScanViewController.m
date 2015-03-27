//
//  WFApScanViewController.m
//  WiFiDock
//
//  Created by hualu on 15-1-19.
//  Copyright (c) 2015年 cn.hualu.WiFiDock. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Foundation/NSObject.h>
#import "WFApScanViewController.h"
#import "Httphelper.h"
#import "MBProgressHUD+WF.h"
#import "ApScanItem.h"
#import "iToast.h"
#import "TLAlertView.h"
#import "Reachability.h"
#import "Reachability+WF.h"
#import <AddressBook/AddressBook.h>
@interface WFApScanViewController ()<NSXMLParserDelegate,UITableViewDataSource,UITableViewDelegate>

-(void)postHttpserver;
-(void)checkScan;
-(NSData*)checkScanenable1;
-(void)updataApLabel:(id)value;
-(NSString *)getApssid:(NSString *)strssid;
-(void)scanSurvey;

@property (nonatomic, retain) UITableView *myTableView;
//解析出得数据，内部是字典类型
@property (strong,nonatomic) NSMutableArray *infoList;
@property (strong,nonatomic) NSMutableDictionary *info;
@property (copy,nonatomic) NSString *currentText;
@property (copy,nonatomic) NSString *forssid;
@property (copy,nonatomic) NSString *forchannal;
@property (copy,nonatomic) NSString *forencryp;
@property (assign,nonatomic) NSRange range;
@property (assign,nonatomic) NSInteger tag;
@property (assign,nonatomic) NSInteger loopCount;
@property (assign,nonatomic) NSInteger connectTag;
@property (assign,nonatomic) NSInteger connectSuc;
@property (strong,nonatomic) NSTimer *timer;
@property (strong,nonatomic) NSData *tmpdata;

@property (copy,nonatomic) NSString *forbooks;
@end

@implementation WFApScanViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = NSLocalizedString(@"Ap Scan",nil);
    //[NSThread detachNewThreadSelector:@selector(postHttpserver:) toTarget:self withObject:nil];
    //    [self getaddress];
    [self postHttpserver];
    
}

-(void)checkScan
{
    NSString *url = @"http://10.10.1.1/:.wop:jresult";
    NSData *data =[Httphelper httpPostSyn:url];
    [self performSelectorOnMainThread:@selector(updataApLabel:) withObject:data waitUntilDone:NO];
}

-(void)postHttpserver
{
    if([Httphelper NetWorkIsOK]&&[self checkSmbOk])
    {
        [MBProgressHUD showMessage:NSLocalizedString(@"Ap Scan",nil)];
        //获取中继状态
        [NSThread detachNewThreadSelector:@selector(checkScan) toTarget:self withObject:nil];
    }
    else{
        [self exitNow];
    }
}
-(void)updataApLabel:(id)value
{
    NSData *data = value;
    if(data == nil){
        [MBProgressHUD hideHUD];
        NSLog(@"jresult cmd did not send !");
        [[[[iToast makeText:NSLocalizedString(@"Abnormal netWork connnection", @"")] setGravity:iToastGravityBottom] setDuration:iToastDurationNormal] show];
        return;
    }
    else{
        NSString *str = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
        NSLog(@"http %@",str);
        self.connectTag = [self getApdetial:str];
        NSString *url = @"http://10.10.1.1/:.wop:disjoin";
        if(0 == self.connectTag||-1 == self.connectTag||2 == self.connectTag){
            //扫描热点
            if([Httphelper setURLRequest:url]){
                [self setModeforAp];
                [self scanSurvey];
            }
        }else {
            [MBProgressHUD hideHUD];
            NSString *ssid = [self getApssid:str];
            TLAlertView *alertView = [TLAlertView showInView:self.view withTitle:ssid message:NSLocalizedString(@"is conneted,disconnet or not",@"") confirmButtonTitle:NSLocalizedString(@"Cancel",@"") cancelButtonTitle:NSLocalizedString(@"Done",@"")];
            [alertView handleCancel:^{
                [MBProgressHUD showMessage:NSLocalizedString(@"Ap Scan",nil)];
                
                if([Httphelper setURLRequest:url]){
                    [self scanSurvey];
                }
                else {
                    [MBProgressHUD hideHUD];
                    [[[[iToast makeText:NSLocalizedString(@"Abnormal netWork connnection", @"")] setGravity:iToastGravityBottom] setDuration:iToastDurationNormal] show];
                }
                
                NSLog(@"confirm");
            }         handleConfirm:^{
                NSLog(@"cancel");
            }];
            [alertView show];
        }
    }
    
}
-(BOOL)setModeforAp
{
    NSString *cmdap = @"http://10.10.1.1/:.wop:smode:repeater";
    if([Httphelper setURLRequest:cmdap])
    {
        NSString *getmod = @"http://10.10.1.1/:.wop:gmode";
        NSData *data =[Httphelper httpPostSyn:getmod];
        if(data==nil){
            NSLog(@"cmd did not send !");
            return NO;
        }
        else{
            NSString *str = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
            NSRange rang =[str rangeOfString:@"repeater"];
            if(rang.length>0){
                return YES;
            }
        }
    }
    return NO;
}
-(NSString *)getApssid:(NSString *)strssid
{
    NSString *ssid;
    int start = 0, end = 0;
    if (strssid != nil) {
        int len = [strssid length];
        for (int i = 45; i < len; i++) {
            if ('<' == [strssid characterAtIndex:i] && 'E' == [strssid characterAtIndex:i+1]) {
                start = i + 7;
                i = i + 5;
            }
            if ('/' == [strssid characterAtIndex:i] && 'E' == [strssid characterAtIndex:i+1]) {
                end = i - 1;
                break;
            }
        }
        ssid =[strssid substringWithRange:NSMakeRange(start,end-start)];
        NSLog(@"ssid %@",ssid);
    }
    return ssid;
}

-(void)scanSurvey
{
    self.connectSuc=0;
    NSString *url = @"http://10.10.1.1/:.wop:survey";
    [Httphelper post:url FinishBlock:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        if(data){
            //子线程通知主线程更新UI，selector中是要执行的函数，data是传给这个函数的参数
            //login_callBack就处理返回来的消息，这里就简单的输出，登录成功
            self.tmpdata =data;
            [self performSelectorOnMainThread:@selector(getXmldata:) withObject:data waitUntilDone:YES];
        }else{
            NSLog(@"无效的数据");
            [MBProgressHUD hideHUD];
        }
    }];
}
//登录的回调函数，首先判断接收的值是不是能登录。若不能，则提示用户。若能登录，则处理segue来跳转界面
- (void)getXmldata:(id)value{
    //NSXMLParser解析xml格式的数据，在这里初始化，并赋值
    NSXMLParser* parser = [[NSXMLParser alloc]initWithData:value];
    parser.delegate =self;
    [parser parse];
}

//1解析前的准备
- (void)parserDidStartDocument:(NSXMLParser *)parser
{
    NSLog(@"prepare for job");
    self.infoList = [NSMutableArray array];
}

//2解析到一个元素的开头时调用
-(void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict
{
    NSLog(@"解析到一个元素的开头---%@",elementName);
    if([@"LIST" isEqualToString:elementName])
    {
        self.tag = -1;
        return;
    }
    if([@"APINFO" isEqualToString:elementName]){
        self.tag = -1;
        return;
    }
    if([@"ESSID" isEqualToString:elementName])
    {
        self.tag = 1;
        self.info = [[NSMutableDictionary alloc] init];
    }
    if([@"BSSID" isEqualToString:elementName]){
        self.tag = 2;
    }else if([@"CHANNEL" isEqualToString:elementName])
    {
        self.tag = 3;
    }else if([@"QUALITY" isEqualToString:elementName]){
        self.tag = 4;
    }else if([@"SIGNAL" isEqualToString:elementName])
    {
        self.tag = 5;
    }else if([@"ENCRYPTION" isEqualToString:elementName]){
        self.tag = 6;
    }
    self.currentText = [[NSString alloc]init];
}
//3:获取首尾节点间内容
- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
    NSLog(@"获取首尾节点间内容1 %@",string);
    self.currentText=[self.currentText stringByAppendingString:string];
    NSLog(@"获取首尾节点间内容2 %@",self.currentText);
}
//4解析到一个元素的结尾时调用
-(void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
    NSLog(@"解析到一个元素的结尾---%@",elementName);
    switch (self.tag) {
        case 1:
        {
            NSLog(@"888881 %@",self.currentText);
            [self.info setObject:self.currentText forKey:@"ESSID"];
            self.currentText = nil;
            self.tag = -1;
            break;
        }
        case 2:
            NSLog(@"888882 %@",self.currentText);
            [self.info setObject:self.currentText forKey:@"BSSID"];
            self.currentText = nil;
            self.tag = -1;
            break;
        case 3:
            NSLog(@"888883 %@",self.currentText);
            [self.info setObject:self.currentText forKey:@"CHANNAL"];
            self.currentText = nil;
            self.tag = -1;
            break;
        case 4:
            NSLog(@"888884 %@",self.currentText);
            [self.info setObject:self.currentText forKey:@"QUALITY"];
            self.currentText = nil;
            self.tag = -1;
            break;
        case 5:
            NSLog(@"888885 %@",self.currentText);
            [self.info setObject:self.currentText forKey:@"SIGNAL"];
            self.currentText = nil;
            self.tag = -1;
            break;
        case 6:
            NSLog(@"888886 %@",self.currentText);
            //过滤ssid为空的热点
            NSString *ssid = [self.info objectForKey:@"ESSID"];
            if(0==[ssid length]){
                self.currentText = nil;
                self.tag = -1;
                return;
            }
            //过滤信号强度大于0或小于－99的热点
            NSString *signal = [self.info objectForKey:@"SIGNAL"];
            NSInteger intsignal = [signal integerValue];
            if(intsignal>=0||intsignal<=-100){
                self.currentText = nil;
                self.tag = -1;
                return;
            }
            [self.info setObject:self.currentText forKey:@"ENCRYPTION"];
            [self.infoList addObject:self.info];
            self.currentText = nil;
            self.tag = -1;
            break;
    }
}
//5结束解析文档时调用（解析完毕）
-(void)parserDidEndDocument:(NSXMLParser *)parser
{
    NSLog(@"结束解析文档");
    [self sortList];
    [MBProgressHUD hideHUD];
    [self setupview];
}
-(void)setupview
{
    //self.dataList = list;
    UITableView *tableView = [[UITableView alloc] init];
    CGFloat tableViewY = self.navigationController.navigationBar.frame.size.height+10;
    CGFloat tableViewW = self.navigationController.view.frame.size.width;
    CGFloat tableViewH = self.navigationController.view.frame.size.height- tableViewY;
    tableView.frame = CGRectMake(0, tableViewY, tableViewW, tableViewH);
    
    // 设置tableView的数据源
    tableView.dataSource = self;
    // 设置tableView的委托
    tableView.delegate = self;
    self.myTableView = tableView;
    [self.view addSubview:self.myTableView];
}
-(void)sortList
{
    NSLog(@"排序前的数组%@",self.infoList);
    NSArray *sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"SIGNAL" ascending:YES]];
    [self.infoList sortUsingDescriptors:sortDescriptors];
    NSLog(@"排序后的数组%@",self.infoList);
}
- (void)getMore
{
    [self dismissViewControllerAnimated:YES completion:^{
        NSLog(@"go home");
    }];
}

- (void)back
{
    [self.navigationController popViewControllerAnimated:YES];
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.infoList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *customCellIndentifier = @"CustomCellIndentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:customCellIndentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:customCellIndentifier];
        CGRect ssidRect = CGRectMake(30, 25, 180, 25);
        UILabel *ssidLabel = [[UILabel alloc]initWithFrame:ssidRect];
        ssidLabel.font = [UIFont boldSystemFontOfSize:16];
        ssidLabel.tag = 1;
        ssidLabel.textColor = [UIColor brownColor];
        [cell.contentView addSubview:ssidLabel];
        
        CGRect signalRect = CGRectMake(240, 25, 35, 25);
        UIImageView *signalLabel = [[UIImageView alloc]initWithFrame:signalRect];
        signalLabel.tag = 2;
        [cell.contentView addSubview:signalLabel];
        
    }
    
    //获得行数
    NSUInteger row = [indexPath row];
    //取得相应行数的数据（NSDictionary类型，包括ssid encryption signal）
    NSDictionary *dic = [_infoList objectAtIndex:row];
    
    //设置ssid
    UILabel *ssid = (UILabel *)[cell.contentView viewWithTag:1];
    ssid.text = [dic objectForKey:@"ESSID"];
    if(self.connectSuc==1&&[ssid.text isEqualToString:self.forssid]){
        ssid.textColor = [UIColor greenColor];
        self.connectSuc=0;
    }
    NSString *encryption = [dic objectForKey:@"ENCRYPTION"];
    UIImageView *signal = (UIImageView *)[cell.contentView viewWithTag:2];
    NSString *signaltext = [dic objectForKey:@"SIGNAL"];
    int signalint = [signaltext intValue];
    if([encryption isEqualToString:@"NONE"]){
        if(signalint >= -53){
            signal.image=[UIImage imageNamed:@"hots4"];
        }else if(signalint <=-54 && signalint >=-81){
            signal.image=[UIImage imageNamed:@"hots3"];
        }else if(signalint <=-72 && signalint >=-82){
            signal.image=[UIImage imageNamed:@"hots2"];
        }else if(signalint <=-83 && signalint >=-91){
            signal.image=[UIImage imageNamed:@"hots1"];
        }else {
            signal.image=[UIImage imageNamed:@"hots0"];
        }
    }else{
        if(signalint >= -53){
            signal.image=[UIImage imageNamed:@"hotslock4"];
        }else if(signalint <=-54 && signalint >=-81){
            signal.image=[UIImage imageNamed:@"hotslock3"];
        }else if(signalint <=-72 && signalint >=-82){
            signal.image=[UIImage imageNamed:@"hotslock2"];
        }else if(signalint <=-83 && signalint >=-91){
            signal.image=[UIImage imageNamed:@"hotslock1"];
        }else {
            signal.image=[UIImage imageNamed:@"hotslock0"];
        }
    }
    
    //设置右侧箭头
    //cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    //UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSDictionary *dic = [_infoList objectAtIndex:indexPath.row];
    self.forssid = [dic objectForKey:@"ESSID"];
    self.forchannal = [dic objectForKey:@"CHANNAL"];
    self.forencryp = [dic objectForKey:@"ENCRYPTION"];
    NSLog(@"message!! %@",self.forssid);
    UIAlertView * alert =
    [[UIAlertView alloc] initWithTitle:nil message:NSLocalizedString(@"Please input key",@"") delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel",@"")  otherButtonTitles:NSLocalizedString(@"Done",@"") ,nil];
    alert.alertViewStyle = UIAlertViewStyleSecureTextInput;
    alert.tag = 10;
    [alert show];
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSLog(@"clicked button %@",[NSString stringWithFormat:@"%d",buttonIndex]);
    if(buttonIndex ==1){
        UITextField *password = [alertView textFieldAtIndex:0];
        NSString *sendinfo;
        if([self.forencryp isEqualToString:@"None"]){
            sendinfo =[[[[[@"http://10.10.1.1/:.wop:join:" stringByAppendingString:self.forssid] stringByAppendingString:@":"] stringByAppendingString:self.forchannal]stringByAppendingString:@":"]stringByAppendingString:@"None"];
        }
        else{
            if(password==nil||0==password.text.length){
                [[[[iToast makeText:NSLocalizedString(@"Password is Empty", @"")] setGravity:iToastGravityBottom] setDuration:iToastDurationNormal] show];
                return;
            }
            if(8>password.text.length){
                [[[[iToast makeText:NSLocalizedString(@"Password length is 8 to 63,Please re-enter", @"")] setGravity:iToastGravityBottom] setDuration:iToastDurationNormal] show];
                return;
            }
            sendinfo =[[[[[[[@"http://10.10.1.1/:.wop:join:" stringByAppendingString:self.forssid] stringByAppendingString:@":"] stringByAppendingString:self.forchannal]stringByAppendingString:@":"] stringByAppendingString:@"WPA"] stringByAppendingString:@":"]stringByAppendingString:password.text];
        }
        if([self checkSmbOk]){
            [MBProgressHUD showMessage:NSLocalizedString(@"Connecting,please wait...",@"")];
            NSLog(@"sendinfo %@",sendinfo);
            if([Httphelper setURLRequest:sendinfo]){
                self.loopCount =0;
                self.timer = [NSTimer scheduledTimerWithTimeInterval:2 target:self
                                                            selector:@selector(getApstatusProcess)
                                                            userInfo:nil
                                                             repeats:YES];
            }
            else{
                [MBProgressHUD hideHUD];
                [self exitNow];
            }
            
        }
        else {
            [self exitNow];
        }
    }
}


- (void)getApstatusProcess{
    NSLog(@"getApstatusProcess!!");
    if([self checkSmbOk]){
        NSData *data =[self checkScanenable1];
        if(data == nil){
            [self.timer invalidate];
            [MBProgressHUD hideHUD];
            NSLog(@"jresult cmd did not send !");
            [[[[iToast makeText:NSLocalizedString(@"Abnormal netWork connnection", @"")] setGravity:iToastGravityBottom] setDuration:iToastDurationNormal] show];
            return;
        }
        else{
            NSString *str = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
            NSLog(@"http %@",str);
            self.connectTag = [self getApdetial:str];
            if(-1 == self.connectTag || 1==self.connectTag){
                [self performSelectorOnMainThread:@selector(updataApstatus) withObject:nil waitUntilDone:NO];
                return;
            }
            self.loopCount++;
            if(self.loopCount == 10){
                [self performSelectorOnMainThread:@selector(updataApstatus) withObject:nil waitUntilDone:NO];
                return;
            }
        }
    }
    else{
        [self.timer invalidate];
        [MBProgressHUD hideHUD];
        [self exitNow];
    }
}
-(int)getApdetial:(NSString*)str{
    int tag = -2;
    self.range = [str rangeOfString:@"repeater enabled, scan failed"];
    if (self.range.length > 0)
    {
        tag = -1;
    }
    self.range = [str rangeOfString:@"not connected"];
    if (self.range.length > 0)
    {
        tag = 0;
    }
    self.range = [str rangeOfString:@"connected"];
    if (self.range.length > 0&&0!=tag)
    {
        tag = 1;
    }
    self.range = [str rangeOfString:@"connecting"];
    if (self.range.length > 0)
    {
        tag = 2;
    }
    return tag;
}
-(void)updataApstatus{
    self.loopCount=0;
    [MBProgressHUD hideHUD];
    [self.timer invalidate];
    NSLog(@"updataApstatus!");
    switch (self.connectTag) {
        case -1:
        {
            NSLog(@"scan fail!");
        }
            break;
        case 0:
        {
            NSLog(@"not connect !");
        }
            break;
        case 1:
        {
            NSLog(@"join OK!");
            self.connectSuc=1;
            [self getXmldata:self.tmpdata];
        }
            break;
        case 2:
        {
            NSString *url = @"http://10.10.1.1/:.wop:disjoin";
            if([Httphelper setURLRequest:url]){
                NSLog(@"disjoin OK!");
                NSLog(@"timeout !!!!!");
            }else{
                NSLog(@"disjoin NG!");
            }
        }
            break;
        default:
            break;
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 70;
}

-(NSData*)checkScanenable1{
    NSString *url = @"http://10.10.1.1/:.wop:jresult";
    NSData *data =[Httphelper httpPostSyn:url];
    return data;
}
-(BOOL)checkSmbOk{
    Reachability *reachability = [Reachability reachabilityWithHostName:kSmbIp];
    [Reachability startCheckWithReachability:reachability];
    return [Reachability isReachableSamba];
}
-(void)exitNow{
    [[[[iToast makeText:NSLocalizedString(@"No device connected", @"")] setGravity:iToastGravityBottom] setDuration:iToastDurationNormal] show];
    [self.navigationController popViewControllerAnimated:YES];
}
@end