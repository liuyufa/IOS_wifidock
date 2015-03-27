//
//  WFBackupViewController.m
//  WiFiDock
//
//  Created by apple on 14-12-2.
//  Copyright (c) 2014年 cn.hualu.WiFiDock. All rights reserved.
//

#import "WFBackupViewController.h"
#import "UIImage+IW.h"
#import "UIBarButtonItem+IW.h"
#import "WFSettingCell.h"
#import "WFSettingArrowItem.h"
#import "WFSettingGroup.h"
#import "WFAddressController.h"
#import "WFAlbumController.h"
#import <AddressBook/AddressBook.h>
#import "WFBackupData.h"
#import "WFPath.h"
#import "WFTableAlert.h"
#import "MBProgressHUD+WF.h"
#import "IGLSMBProvier.h"
#import "WFPeople.h"
#import "WFActionTool.h"
#import "IGLCopyPhotosAction.h"
#import "AccessAuthorUtils.h"
#import "WFFile.h"

#import "IGLSMBProvier.h"

#import "ZLPhotoAssets.h"

#import "ZLPhotoPickerViewController.h"

@interface WFBackupViewController ()<UIAlertViewDelegate,ZLPhotoPickerViewControllerDelegate>

//@property (nonatomic, strong) NSMutableArray *data;
@property (nonatomic, strong) WFTableAlert *alert;
@property (nonatomic, assign) BOOL canAccess;
@property (nonatomic, assign) BOOL isRoopOver;
@property (nonatomic, copy)NSString *copypath;
@property (nonatomic, strong)NSArray *seleteArray;

@property (nonatomic, copy)NSString *destPath;
@property (copy,nonatomic) NSString *forbooks;
@property (retain,nonatomic) NSMutableArray *addressBookTemp;

@end

@implementation AddressBook
@synthesize tel,firstname,lastname,compositename;
- (id)init
{
    if (self = [super init])
    {
        self.firstname = [[NSString alloc]init];
        self.lastname = [[NSString alloc]init];
        self.compositename = [[NSString alloc]init];
        self.tel = [[NSString alloc]init];
    }
    return self;
}

- (id)copyWithZone:(NSZone *)zone
{
    AddressBook *copy = [[[self class] allocWithZone:zone] init];
    copy->firstname = [firstname copy];
    copy->lastname = [lastname copy];
    copy->compositename = [compositename copy];
    copy->tel = [tel copy];
    return copy;
}
@end

@implementation WFBackupViewController

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
     self.navigationItem.title = NSLocalizedString(@"Backups",nil);
  
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
    self.navigationItem.leftBarButtonItem = [UIBarButtonItem itemWithImage:@"navigationbar_back" higlightedImage:@"navigationbar_back_highlighted" target:self action:@selector(back)];

    [self addNotifaction];
    
    [self setupGroup0];
    
    [self setupGroup1];
}

- (void)addNotifaction
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(backupsPhotos:) name:KSelectePhotos object:nil];
}

- (void)backupsPhotos:(NSNotification *)notification
{
    NSLog(@"backupsPhotos");
    NSDictionary *dic = notification.userInfo;
    
    self.seleteArray = dic[@"selectAssets"];
    
    [self copyPhotos];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (self.navigationController.navigationBar.hidden == YES) {
        self.navigationController.navigationBar.hidden = NO;
    }
}

-(void)setupGroup1
{
    WFSettingItem *address = [WFSettingArrowItem itemWithTitle:NSLocalizedString(@"Address Book",nil) destVcClass:nil];
    __weak typeof(self) weakSelf = self;
    address.option = ^{
    
        WFBackupData *data = [[WFBackupData alloc]init];
        [data setBackupDataSoure];
        
        weakSelf.alert = [WFTableAlert tableAlertWithTitle:NSLocalizedString(@"Please Selected the path",nil)
        cancelButtonTitle:NSLocalizedString(@"Cancel",nil)
        numberOfRows:^NSInteger (NSInteger section){
                                              
            return data.paths.count;
                                          }
        andCells:^UITableViewCell* (WFTableAlert *anAlert, NSIndexPath *indexPath){
                                              
            static NSString *CellIdentifier = @"CellIdentifier";
            UITableViewCell *cell = [anAlert.table dequeueReusableCellWithIdentifier:CellIdentifier];
            if (cell == nil)
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
                                              
            WFPath *item = [data.paths objectAtIndex:indexPath.row];
            cell.textLabel.text = item.rootName;
                                              
            return cell;
     }];
        
        weakSelf.alert.height = 350;
        [weakSelf.alert configureSelectionBlock:^(NSIndexPath *selectedIndex){
            WFPath *item = [data.paths objectAtIndex:selectedIndex.row];
            NSString *destPath = [item.rootPath stringByAppendingSMBPathComponent:@"Contacts/Contacts.vcf"];
            if (![WFActionTool isExistsAtPath:destPath]) {
                NSString *title = NSLocalizedString(@"Warning",nil);
                NSString *msg = NSLocalizedString(@"No files Exist",nil);
                NSString *done = NSLocalizedString(@"Done",nil);
                
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:msg delegate:weakSelf cancelButtonTitle:done otherButtonTitles:nil, nil];
                alert.tag = 10;
                [alert show];
                
            }
            else{
            [weakSelf requestAccessAddressBook];
            [MBProgressHUD showMessage:NSLocalizedString(@"Recovering",nil)];
            [NSThread detachNewThreadSelector:@selector(getAddressBook:) toTarget:self withObject:destPath];
            }
        } andCompletionBlock:^{
            
        }];

        [weakSelf.alert show];
 
    };
    
    WFSettingItem *album = [WFSettingArrowItem itemWithTitle:NSLocalizedString(@"Album",nil) destVcClass:nil];
    
    album.option = ^{
    
        WFBackupData *data = [[WFBackupData alloc]init];
        [data setBackupDataSoure];
        weakSelf.alert = [WFTableAlert tableAlertWithTitle:NSLocalizedString(@"Please Selected the path",nil)
            cancelButtonTitle:NSLocalizedString(@"Cancel",nil)
            numberOfRows:^NSInteger (NSInteger section){
                                                  
                return data.paths.count;
            }
            andCells:^UITableViewCell* (WFTableAlert *anAlert, NSIndexPath *indexPath){
                                                      
                static NSString *CellIdentifier = @"CellIdentifier";
                UITableViewCell *cell = [anAlert.table dequeueReusableCellWithIdentifier:CellIdentifier];
                if (cell == nil)
                    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
                                                      
                WFPath *item = [data.paths objectAtIndex:indexPath.row];
                cell.textLabel.text = item.rootName;
                                                      
                return cell;
        }];
        weakSelf.alert.height = 350;
        
        [weakSelf.alert configureSelectionBlock:^(NSIndexPath *selectedIndex) {
            WFPath *item = [data.paths objectAtIndex:selectedIndex.row];
            NSString *source = [item.rootPath stringByAppendingSMBPathComponent:@"Wifidockbackups"];
            if (![WFActionTool isExistsAtPath:source]) {
                NSString *title = NSLocalizedString(@"Warning",nil);
                NSString *msg = NSLocalizedString(@"No files Exist",nil);
                NSString *done = NSLocalizedString(@"Done",nil);
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:msg delegate:weakSelf cancelButtonTitle:done otherButtonTitles:nil, nil];
                alert.tag = 10;
                [alert show];
                
            }
            
            [MBProgressHUD showMessage:NSLocalizedString(@"Backing up,please waiting......",nil)];
            [NSThread detachNewThreadSelector:@selector(recoverAlbum:) toTarget:self withObject:source];

        } andCompletionBlock:^{
            NSLog(@"andCompletionBlock");
            
        }];
        [weakSelf.alert show];
    };
    WFSettingGroup *group = [[WFSettingGroup alloc] init];
    group.header = NSLocalizedString(@"Recover",nil);
    group.items = @[address,album];
    [self.data addObject:group];
}
-(void)recoverAlbum:(NSString*)source{
    NSMutableArray *files = [[IGLSMBProvier alloc] fetchFileFromDirectory:source fileType:nil];
    if (files.count == 0) {
        [self performSelectorOnMainThread:@selector(recoverToError) withObject:nil waitUntilDone:NO];
        return;
    }
    for (WFFile *file in files) {
        NSData *imageData = [[IGLSMBProvier alloc] dataWithPath:file.filePath];
        UIImage *image = [UIImage imageWithData:imageData];
        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil);
    }
    [self performSelectorOnMainThread:@selector(recoverToSuccess) withObject:nil waitUntilDone:NO];
}
-(void)getAddressBook:(NSString *)path{
    if ([path hasPrefix:SAMBA_URL]) {
        NSData *result = [[IGLSMBProvier sharedSmbProvider] writeFrom:path];
        NSString *temresult = [[NSString alloc] initWithData:result  encoding:NSUTF8StringEncoding];
        [self Parasecontent:temresult];
    }else{
        NSFileManager *manager = [NSFileManager defaultManager];
        NSData *data = [manager contentsAtPath:path];
        NSString *temresult = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        [self Parasecontent:temresult];
    }
    if (ABAddressBookGetAuthorizationStatus() != kABAuthorizationStatusAuthorized) return;
    [self addToContact];
    [self performSelectorOnMainThread:@selector(recoverToSuccess) withObject:nil waitUntilDone:NO];
    
}
-(void)recoverToError{
    [MBProgressHUD hideHUD];
    [MBProgressHUD showError:NSLocalizedString(@"No files existence in the contents，please choose again",nil)];
}
-(void)backupToSuccess{
    [MBProgressHUD hideHUD];
    [MBProgressHUD showSuccess:NSLocalizedString(@"Backup Successfully",nil)];
}
-(void)recoverToSuccess{
    [MBProgressHUD hideHUD];
    [MBProgressHUD showSuccess:NSLocalizedString(@"Recover Successfully",nil)];
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 10) {
        return;
    }else if(alertView.tag == 11){


    }
    
}

-(void)copyPhotos
{
    self.isRoopOver = NO;
    self.canAccess = NO;
    [AccessAuthorUtils isPhotoAccessEnableWithIsShowAlert:YES completion:^(BOOL isAccessEnable) {
        if(isAccessEnable){
            self.canAccess = YES;
        }
        self.isRoopOver = YES;
    }];
    
    while(!self.isRoopOver){
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
    }
    if(!self.canAccess){
        return;
    }
    [self performSelectorOnMainThread:@selector(docopyPhotos) withObject:nil waitUntilDone:NO];
}

- (void)docopyPhotos
{
    self.isRoopOver = NO;
    self.copypath  = nil;
    
    WFBackupData *data = [[WFBackupData alloc]init];
    [data setBackupDataSoure];
     __weak typeof(self) weakSelf = self;
    NSArray *seleteArray = self.seleteArray;
    self.alert = [WFTableAlert tableAlertWithTitle:NSLocalizedString(@"Please Selected the path",nil)
     cancelButtonTitle:NSLocalizedString(@"Cancel",nil)
          numberOfRows:^NSInteger (NSInteger section){
              
              return data.paths.count;
          }
    andCells:^UITableViewCell* (WFTableAlert *anAlert, NSIndexPath *indexPath){
                  
        static NSString *CellIdentifier = @"CellIdentifier";
        UITableViewCell *cell = [anAlert.table dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil)
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
                  
        WFPath *item = [data.paths objectAtIndex:indexPath.row];
                  cell.textLabel.text = item.rootName;
                  
                  return cell;
    }];
    
    weakSelf.alert.height = 350;
    
    
    [self.alert configureSelectionBlock:^(NSIndexPath *selectedIndex){
        
        WFPath *item = [data.paths objectAtIndex:selectedIndex.row];
        
        weakSelf.copypath = item.rootPath;
        
        if(!weakSelf.copypath){
            return;
        }
   
        IGLCopyPhotosAction *manager = [[IGLCopyPhotosAction alloc] initWithArray:seleteArray Path:weakSelf.copypath];
        [MBProgressHUD showSuccess:NSLocalizedString(@"Backuping! you can checked the current status from the status View",nil)];
        [manager startAsynchronous];
        
    } andCompletionBlock:^{
        
        
        
    }];
    
    
    [self.alert show];
 
    
}

- (void)setupGroup0
{
    WFSettingItem *address = [WFSettingArrowItem itemWithTitle:NSLocalizedString(@"Address Book",nil) destVcClass:nil];
    __weak typeof(self) weakSelf = self;
    address.option = ^{
        [weakSelf showdialog];
    };
    WFSettingItem *album = [WFSettingArrowItem itemWithTitle:NSLocalizedString(@"Album",nil) destVcClass:nil];
    
    album.option = ^{
        
//        [self copyPhotos];
        [weakSelf selectPhotos];
        /*
        NSString *title = NSLocalizedString(@"Warning",nil);
        NSString *msg = NSLocalizedString(@"Encrypted backups?",nil);
        NSString *done = NSLocalizedString(@"Cancel",nil);
        NSString *cacel = NSLocalizedString(@"Done",nil);
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:msg delegate:weakSelf cancelButtonTitle:cacel otherButtonTitles:done, nil];
        
        alert.tag = 11;
        
        [alert show];
         */
    };
    
    WFSettingGroup *group = [[WFSettingGroup alloc] init];
    group.header = NSLocalizedString(@"Backups",nil);
    group.items = @[address,album];
    [self.data addObject:group];
}
-(void)showdialog{
    [self requestAccessAddressBook];
    WFBackupData *data = [[WFBackupData alloc]init];
    [data setBackupDataSoure];
    NSString *title = NSLocalizedString(@"Please Select the file",nil);
    self.alert = [WFTableAlert tableAlertWithTitle:title
                                 cancelButtonTitle:NSLocalizedString(@"Cancel",nil)
                                      numberOfRows:^NSInteger (NSInteger section){
                                          
                                          return data.paths.count;
                                      }
                                          andCells:^UITableViewCell* (WFTableAlert *anAlert, NSIndexPath *indexPath){
                                              
                                              static NSString *CellIdentifier = @"CellIdentifier";
                                              UITableViewCell *cell = [anAlert.table dequeueReusableCellWithIdentifier:CellIdentifier];
                                              if (cell == nil)
                                                  cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
                                              
                                              WFPath *item = [data.paths objectAtIndex:indexPath.row];
                                              cell.textLabel.text = item.rootName;
                                              
                                              return cell;
                                          }];
    self.alert.height = 350;
    [self.alert configureSelectionBlock:^(NSIndexPath *selectedIndex){
        //        [MBProgressHUD showMessage:@"正在备份中，请稍等"];
        //NSData *persondata = [NSKeyedArchiver archivedDataWithRootObject:self.selectedContacts];
        WFPath *item = [data.paths objectAtIndex:selectedIndex.row];
        NSString *Path = [item.rootPath stringByAppendingSMBPathComponent:@"Contacts"];
        if(![WFActionTool isExistsAtPath:Path]){
            [WFActionTool createAtPaht:Path];
        }
        NSString *destPath = [Path stringByAppendingSMBPathComponent:@"Contacts.vcf"];
        self.destPath = destPath;
        if ([WFActionTool isExistsAtPath:destPath]) {
            [WFActionTool removeFileAtPath:self.destPath];
        }
        [self getaddress];
        NSData* xmlData = [self.forbooks dataUsingEncoding:NSUTF8StringEncoding];
        if ([item.rootPath hasPrefix:SAMBA_URL]) { //上传到 dock 端
            
            id result = [[IGLSMBProvier sharedSmbProvider]  createFileAtPath:destPath overwrite:YES];
            if(![result isKindOfClass:[IGLSMBItemFile class]]) return;
            IGLSMBItemFile *file = (IGLSMBItemFile *)result;
            [file writeData:xmlData];
        }else{
            [xmlData writeToFile:destPath atomically:YES];
        }
        [MBProgressHUD hideHUD];
        [MBProgressHUD showSuccess:NSLocalizedString(@"Backup Successfully",nil)];
    } andCompletionBlock:^{
        
    }];
    
    [self.alert show];
    
}
-(void)getaddress
{
    //读取所有联系人
    [self ReadAllPeoplesinfo];
    [self FileFromLocal];
}
-(void)FileFromLocal{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentDirectory = [paths objectAtIndex:0];
    NSString *filepath = [documentDirectory stringByAppendingPathComponent:@"Contacts.vcf"];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:filepath]) {
        [fileManager isDeletableFileAtPath:filepath];
    }
    else{
        [fileManager createFileAtPath:filepath contents:nil attributes:nil];
        [self.forbooks writeToFile:filepath atomically:YES encoding:NSUTF8StringEncoding error:nil];
    }
}
-(void)ReadAllPeoplesinfo
{
    //ABAddressBookRef addressBook = ABAddressBookCreate();
    ABAddressBookRef addressBook = nil;
    
    if ([[UIDevice currentDevice].systemVersion floatValue]>=6.0) {
        addressBook=ABAddressBookCreateWithOptions(NULL, NULL);
        dispatch_semaphore_t sema=dispatch_semaphore_create(0);
        ABAddressBookRequestAccessWithCompletion(addressBook, ^(bool greanted, CFErrorRef error){
            dispatch_semaphore_signal(sema);
        });
        
        dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
    }
    else
    {
        CFErrorRef* error=nil;
        addressBook =ABAddressBookCreateWithOptions(NULL, error);
    }
    CFArrayRef results = ABAddressBookCopyArrayOfAllPeople(addressBook);
    self.forbooks = @"";
    for(int i = 0; i < CFArrayGetCount(results); i++)
    {
        ABRecordRef person = CFArrayGetValueAtIndex(results, i);
        NSString *firstName = (__bridge NSString*)ABRecordCopyValue(person, kABPersonFirstNameProperty);
        firstName = (firstName ? firstName : @"");
        NSString *lastName = (__bridge NSString *)ABRecordCopyValue(person, kABPersonLastNameProperty);
        lastName = (lastName ? lastName : @"");
        NSString *middleName = (__bridge NSString *)ABRecordCopyValue(person, kABPersonMiddleNameProperty);
        NSString *prefix = (__bridge NSString *)ABRecordCopyValue(person, kABPersonPrefixProperty);
        NSString *suffix = (__bridge NSString *)ABRecordCopyValue(person, kABPersonSuffixProperty);
        NSString *compositeName = [NSString stringWithFormat:@"%@%@",firstName,lastName];
        if(i > 0) {
            self.forbooks = [self.forbooks stringByAppendingFormat:@"\n"];
        }
        self.forbooks = [self.forbooks stringByAppendingFormat:@"BEGIN:VCARD\nVERSION:3.0\nN:%@;%@;%@;%@;%@\n",
                         (firstName ? firstName : @""),
                         (lastName ? lastName : @""),
                         (middleName ? middleName : @""),
                         (prefix ? prefix : @""),
                         (suffix ? suffix : @"")
                         ];
        self.forbooks = [self.forbooks stringByAppendingFormat:@"FN:%@\n",compositeName];
        ABMultiValueRef phoneNumbers = ABRecordCopyValue(person, kABPersonPhoneProperty);
        if(phoneNumbers) {
            for (int k = 0; k < ABMultiValueGetCount(phoneNumbers); k++) {
                NSString *label = (__bridge NSString*)ABAddressBookCopyLocalizedLabel(ABMultiValueCopyLabelAtIndex(phoneNumbers, k));
                NSString *number = (__bridge NSString *)ABMultiValueCopyValueAtIndex(phoneNumbers, k);
                NSString *labelLower = [label lowercaseString];
                
                if ([labelLower isEqualToString:@"mobile"]) self.forbooks = [self.forbooks stringByAppendingFormat:@"TEL;type=CELL:%@\n",number];
                else if ([labelLower isEqualToString:@"home"]) self.forbooks = [self.forbooks stringByAppendingFormat:@"TEL;type=HOME:%@\n",number];
                else if ([labelLower isEqualToString:@"work"]) self.forbooks = [self.forbooks stringByAppendingFormat:@"TEL;type=WORK:%@\n",number];
                else if ([labelLower isEqualToString:@"main"]) self.forbooks = [self.forbooks stringByAppendingFormat:@"TEL;type=MAIN:%@\n",number];
                else if ([labelLower isEqualToString:@"homefax"]) self.forbooks = [self.forbooks stringByAppendingFormat:@"TEL;type=HOME;type=FAX:%@\n",number];
                else if ([labelLower isEqualToString:@"workfax"]) self.forbooks = [self.forbooks stringByAppendingFormat:@"TEL;type=WORK;type=FAX:%@\n",number];
                else if ([labelLower isEqualToString:@"pager"]) self.forbooks = [self.forbooks stringByAppendingFormat:@"TEL;type=PAGER:%@\n",number];
                else if([labelLower isEqualToString:@"other"]) self.forbooks = [self.forbooks stringByAppendingFormat:@"TEL;type=OTHER:%@\n",number];
                else { //类型解析不出来的
                    //counter++;
                    self.forbooks = [self.forbooks stringByAppendingFormat:@"TEL;type=other:%@\n",number];
                }
            }
        }
        self.forbooks = [self.forbooks stringByAppendingString:@"END:VCARD"];
    }
}
-(void)readFile{
    //读文件
    NSArray* pathss = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString* thepath = [pathss objectAtIndex:0];
    thepath = [thepath stringByAppendingPathComponent:@"Contacts.vcf"];
    NSLog(@"thepath %@",thepath);
    NSString* content = [NSString stringWithContentsOfFile:thepath encoding:NSUTF8StringEncoding error:nil];
    NSLog(@"NSString类方法读取的内容是：\n%@",content);
    [self Parasecontent:content];
}
-(void)Parasecontent:(NSString*)vcardString{
    //self.addressBookTemp = [[NSMutableArray array] retain];
    self.addressBookTemp = [[NSMutableArray alloc] init];
    AddressBook *addressBook1;
    NSLog(@"llllll %@",vcardString);
    NSArray *lines = [vcardString componentsSeparatedByString:@"\n"];
    for(NSString* line in lines)
    {
        if ([line hasPrefix:@"BEGIN:"])
        {
            addressBook1 = [[AddressBook alloc] init];
            NSLog(@"parse start");
        }
        else if([line hasPrefix:@"END"])
        {
            [self.addressBookTemp addObject:addressBook1];
            NSLog(@"parse end");
        }
        else if([line hasPrefix:@"VERSION:"]){
            continue;
        }
        else if([line hasPrefix:@"FN:"])
        {
            NSArray *upperComponents = [line componentsSeparatedByString:@":"];
            if([upperComponents count]>1){
                NSString * personName = [upperComponents objectAtIndex:1];
                addressBook1.compositename = personName;
                NSLog(@"personName %@ ",personName);
            }
        }
        else if([line hasPrefix:@"N:"])
        {
            NSArray *component = [line componentsSeparatedByString:@":"];
            if([component count]>1){
                NSArray *components = [component[1] componentsSeparatedByString:@";"];
                
                NSString *firstname = [components objectAtIndex:0];
                addressBook1.firstname = firstname;
                if([components count]>1){
                    NSString *lastname = [components objectAtIndex:1];
                    addressBook1.lastname = lastname;
                }
            }
        }
        else if([line hasPrefix:@"TEL;"])
        {
            NSArray *components = [line componentsSeparatedByString:@":"];
            if([components count]>1){
                NSString *personPhone = [components objectAtIndex:1];
                addressBook1.tel = personPhone;
            }
        }
    }
}
//添加到通讯录（通讯录还原）
-(void)addToContact
{
    ABAddressBookRef iPhoneAddressBook = ABAddressBookCreateWithOptions(NULL, NULL);
    //ABAddressBookRef iPhoneAddressBook = ABAddressBookCreate();
    for(int i=0;i<self.addressBookTemp.count;i++){
        AddressBook *addressBook1 = [[AddressBook alloc] init];
        addressBook1 = [self.addressBookTemp objectAtIndex:i];
        ABRecordRef newPerson = ABPersonCreate();
        CFErrorRef error = NULL;
        ABRecordSetValue(newPerson, kABPersonFirstNameProperty, (__bridge CFTypeRef)(addressBook1.firstname), &error);
        ABRecordSetValue(newPerson, kABPersonLastNameProperty, (__bridge CFTypeRef)(addressBook1.lastname), &error);
    //ABRecordSetValue(newPerson, kABPersonOrganizationProperty, @"Model Metrics", &error);
    //ABRecordSetValue(newPerson, kABPersonJobTitleProperty, @"Senior Slacker", &error);
    
    //phone number
        ABMutableMultiValueRef multiPhone = ABMultiValueCreateMutable(kABMultiStringPropertyType);
        //ABMultiValueAddValueAndLabel(multiPhone, (__bridge CFTypeRef)(self.addressBook.tel), kABPersonPhoneMainLabel, NULL);
        ABMultiValueAddValueAndLabel(multiPhone, (__bridge CFTypeRef)(addressBook1.tel), kABPersonPhoneMobileLabel, NULL);
    //ABMultiValueAddValueAndLabel(multiPhone, @"1-987-654-3210", kABOtherLabel, NULL);
        ABRecordSetValue(newPerson, kABPersonPhoneProperty, multiPhone,&error);
        CFRelease(multiPhone);
    
//    //email
//    ABMutableMultiValueRef multiEmail = ABMultiValueCreateMutable(kABMultiStringPropertyType);
//    ABMultiValueAddValueAndLabel(multiEmail, @"johndoe@modelmetrics.com", kABWorkLabel, NULL);
//    ABRecordSetValue(newPerson, kABPersonEmailProperty, multiEmail, &error);
//    CFRelease(multiEmail);
    
    //address
//    ABMutableMultiValueRef multiAddress = ABMultiValueCreateMutable(kABMultiDictionaryPropertyType);
//    NSMutableDictionary *addressDictionary = [[NSMutableDictionary alloc] init];
//    [addressDictionary setObject:@"750 North Orleans Street, Ste 601" forKey:(NSString *) kABPersonAddressStreetKey];
//    [addressDictionary setObject:@"Chicago" forKey:(NSString *)kABPersonAddressCityKey];
//    [addressDictionary setObject:@"IL" forKey:(NSString *)kABPersonAddressStateKey];
//    [addressDictionary setObject:@"60654" forKey:(NSString *)kABPersonAddressZIPKey];
//    ABMultiValueAddValueAndLabel(multiAddress, (__bridge CFTypeRef)(addressDictionary), kABWorkLabel, NULL);
//    ABRecordSetValue(newPerson, kABPersonAddressProperty, multiAddress,&error);
//    CFRelease(multiAddress);
        
        ABAddressBookAddRecord(iPhoneAddressBook, newPerson, &error);
        ABAddressBookSave(iPhoneAddressBook, &error);
        if (error != NULL)
        {
            NSLog(@"Danger Will Robinson! Danger!");
        }
    }
}

- (void)selectPhotos
{
    
    ZLPhotoPickerViewController *pickerVc = [[ZLPhotoPickerViewController alloc] init];
    
    pickerVc.status = PickerViewShowStatusCameraRoll;
    
    pickerVc.delegate = self;
    [pickerVc show];
    
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    WFSettingGroup *group = self.data[section];
    return group.header;
}

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
        [self.navigationController pushViewController:vc animated:YES];
    }
}

- (void)requestAccessAddressBook
{
    
    ABAddressBookRef book = ABAddressBookCreateWithOptions(NULL, NULL);
    
    
    ABAddressBookRequestAccessWithCompletion(book, ^(bool granted, CFErrorRef error) {
        if (granted) {
            
            NSLog(@"允许访问");
            
            
        } else {
            
            NSLog(@"不允许访问");
        }
    });
    
    
    CFRelease(book);
}

- (NSString *)getMobilePhoneProperty:(ABMultiValueRef)phonesRef
{
    for (int i=0; i < ABMultiValueGetCount(phonesRef); i++) {
        CFStringRef currentPhoneLabel = ABMultiValueCopyLabelAtIndex(phonesRef, i);
        CFStringRef currentPhoneValue = ABMultiValueCopyValueAtIndex(phonesRef, i);
        
        if(currentPhoneLabel) {
            if (CFStringCompare(currentPhoneLabel, kABPersonPhoneMobileLabel, 0) == kCFCompareEqualTo) {
                CFRelease(currentPhoneLabel);
                return (__bridge_transfer NSString *)currentPhoneValue;
            }
            
            if (CFStringCompare(currentPhoneLabel, kABHomeLabel, 0) == kCFCompareEqualTo) {
                CFRelease(currentPhoneLabel);
                return (__bridge_transfer NSString *)currentPhoneValue;
            }
        }
        if(currentPhoneLabel) {
            CFRelease(currentPhoneLabel);
        }
        if(currentPhoneValue) {
            CFRelease(currentPhoneValue);
        }
    }
    
    return nil;
}


- (void) pickerViewControllerDoneAsstes : (NSArray *) assets
{
    
}

-(void)dealloc
{
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
@end
