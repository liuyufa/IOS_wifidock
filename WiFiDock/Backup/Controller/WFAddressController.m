////
////  WFAddressController.m
////  WiFiDock
////
////  Created by apple on 15-1-12.
////  Copyright (c) 2015年 cn.hualu.WiFiDock. All rights reserved.
////
//
//#import "WFAddressController.h"
//#import <AddressBook/AddressBook.h>
//#import <AddressBookUI/AddressBookUI.h>
//#import "WFContactPickerView.h"
//#import "WFPeople.h"
//#import "WFPeopleCell.h"
//#import "MBProgressHUD+WF.h"
//#import "UIBarButtonItem+IW.h"
//#import "WFTableAlert.h"
//#import "WFBackupData.h"
//#import "WFPath.h"
//#import "IGLSMBProvier.h"
//#import "WFActionTool.h"
//
//
//#define kKeyboardHeight 0.0
//
//@interface WFAddressController ()<UITableViewDataSource, UITableViewDelegate, WFContactPickerDelegate,UIAlertViewDelegate,ABPersonViewControllerDelegate>
//@property (nonatomic, assign) ABAddressBookRef addressBookRef;
//@property (nonatomic, strong) UIBarButtonItem *barButton;
//@property (nonatomic, strong) UITableView *tableView;
//@property (nonatomic, strong) WFTableAlert *alert;
//@property (nonatomic, copy)NSString *destPath;
//
//@property (copy,nonatomic) NSString *forbooks;
//@property (copy,nonatomic) NSMutableArray *addressBookTemp;
//@property (copy,nonatomic)AddressBook *addressBook;
//
//@end
//
//@implementation AddressBook
//@synthesize tel, firstname, lastname,compositename;
//@end
//
//@implementation WFAddressController
//
//
//
//- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
//{
//    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
//    if (self) {
//        self.title = @"Select Contacts (0)";
//        
//        CFErrorRef error;
//        _addressBookRef = ABAddressBookCreateWithOptions(NULL, &error);
//    }
//    return self;
//}
//
//- (void)viewDidLoad
//{
//    [super viewDidLoad];
//    
//     [self setupSubview];
//    
//    [self requestAccessAddressBook];
//    
//    [self accessAllPeople];
//}
//
//- (void)setupSubview
//{
//    
//    [self showdialog];
//    /*
//    self.navigationItem.leftBarButtonItem = [UIBarButtonItem itemWithImage:@"navigationbar_back" higlightedImage:@"navigationbar_back_highlighted" target:self action:@selector(back)];
//    
//    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
//    
//    UIBarButtonItem *btn1 = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(done:)];
//    
//    
//    self.barButton = btn1;
//   
//    UIBarButtonItem *space =[[UIBarButtonItem alloc]initWithTitle:@" " style:UIBarButtonItemStyleBordered target:nil action:nil];
//    space.width = 20;
//    space.enabled = NO;
//    
//    UIBarButtonItem *btn2 = [[UIBarButtonItem alloc]initWithTitle:NSLocalizedString(@"All",nil) style:UIBarButtonItemStyleBordered target:self action:@selector(all:)];
//    
//    self.navigationItem.rightBarButtonItems = @[btn2,space,btn1];
//    
//    btn1.enabled = FALSE;
//    
//    self.navigationItem.title = [NSString stringWithFormat:NSLocalizedString(@"Backup/Address Book",nil)];
//    
//    self.contactPickerView = [[WFContactPickerView alloc] initWithFrame:CGRectMake(0, 70, self.view.frame.size.width, 100)];
//    self.contactPickerView.delegate = self;
//    [self.contactPickerView setPlaceholderString:NSLocalizedString(@"Type contact name",nil)];
//    [self.view addSubview:self.contactPickerView];
//    
//    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, self.contactPickerView.frame.size.height, self.view.frame.size.width, self.view.frame.size.height - self.contactPickerView.frame.size.height - kKeyboardHeight) style:UITableViewStylePlain];
//    self.tableView.delegate = self;
//    self.tableView.dataSource = self;
//    [self.tableView registerNib:[UINib nibWithNibName:@"WFPeopleCell" bundle:nil] forCellReuseIdentifier:@"peopleCell"];
//    
//    [self.view insertSubview:self.tableView belowSubview:self.contactPickerView];
//     */
//}
//
//-(void)all:(id)sender
//{
//    
//    int count = self.filteredContacts.count;
//    
//    
//    if (self.selectedContacts.count== self.contacts.count ) {
//        
//        self.barButton.enabled = NO;
//        for (int row = 0; row < count; row++) {
//            
//           NSIndexPath *index = [NSIndexPath indexPathForRow:row inSection:0];
//           
//           WFPeople *user = [self.filteredContacts objectAtIndex:index.row];
//           [self.selectedContacts removeObject:user];
//           [self.contactPickerView removeContact:user];
//          
//        }
//        
//        
//        [self.tableView reloadData];
//        self.title =[NSString stringWithFormat:NSLocalizedString(@"Backup/Address Book",nil)];
//        
//    }else{
//    
//        for (int row = 0; row < count; row++) {
//            
//            NSIndexPath *index = [NSIndexPath indexPathForRow:row inSection:0];
//            [self.contactPickerView resignKeyboard];
//            
//            [self.tableView deselectRowAtIndexPath:index animated:YES];
//            
//            UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:index];
//            
//            
//            WFPeople *user = [self.filteredContacts objectAtIndex:index.row];
//            UIImageView *checkboxImageView = (UIImageView *)[cell viewWithTag:104];
//            UIImage *image;
//            
//            if ([self.selectedContacts containsObject:user]){
//                
//                continue;
//                
//            } else {
//                
//                [self.selectedContacts addObject:user];
//                [self.contactPickerView addContact:user withName:user.fullName];
//                
//                image = [UIImage imageNamed:@"icon-checkbox-selected-green-25x25"];
//            }
//            
//            
//            if(self.selectedContacts.count > 0) {
//                self.barButton.enabled = TRUE;
//            }
//            else{
//                self.barButton.enabled = FALSE;
//            }
//            
//            
//            self.title = [NSString stringWithFormat:NSLocalizedString(@"Add Members (%lu)",nil), (unsigned long)self.selectedContacts.count];
//            
//            
//            checkboxImageView.image = image;
//            
//            self.filteredContacts = self.contacts;
//            
//            [self.tableView reloadData];
//    
//    }
//    
//    
//        
//#pragma mark
//     /*
//       NSIndexPath *index = [NSIndexPath indexPathForRow:row inSection:0];
//        
//        [self tableView:self.tableView didSelectRowAtIndexPath:index];
//      */
//       
//    }
//
////    self.barButton.enabled = YES;
//}
//
//- (void)back
//{
//    [self.navigationController popViewControllerAnimated:YES];
//}
//
//- (void)requestAccessAddressBook
//{
//    
//    ABAddressBookRef book = ABAddressBookCreateWithOptions(NULL, NULL);
//    
//    
//    ABAddressBookRequestAccessWithCompletion(book, ^(bool granted, CFErrorRef error) {
//        if (granted) {
//            
//            NSLog(@"允许访问");
//            
//            
//        } else {
//            
//            NSLog(@"不允许访问");
//        }
//    });
//    
//    
//    CFRelease(book);
//}
//
//
//- (void)accessAllPeople
//{
//    
//    if (ABAddressBookGetAuthorizationStatus() != kABAuthorizationStatusAuthorized) return;
//    
//    
//    ABAddressBookRef book = ABAddressBookCreateWithOptions(NULL, NULL);
//    if (!book) return;
//
//    NSArray *allPeopole = (__bridge_transfer NSArray *)ABAddressBookCopyArrayOfAllPeople(book);
//    
//    NSMutableArray *mutableContacts = [NSMutableArray arrayWithCapacity:allPeopole.count];
//    
//    for (int i = 0; i < allPeopole.count; i++) {
//        
//        ABRecordRef record = (__bridge ABRecordRef)(allPeopole[i]);
//        WFPeople *peopleItem = [[WFPeople alloc]init];
//        
//        peopleItem.recordId = ABRecordGetRecordID(record);
//        peopleItem.lastName = (__bridge NSString *)
//           (ABRecordCopyValue(record, kABPersonLastNameProperty));
//        peopleItem.firstName = (__bridge_transfer NSString *)
//            (ABRecordCopyValue(record, kABPersonFirstNameProperty));
//
//        ABMultiValueRef phonesRef = ABRecordCopyValue(record, kABPersonPhoneProperty);
//        peopleItem.phone = [self getMobilePhoneProperty:phonesRef];
//        
//        if (phonesRef) CFRelease(phonesRef);
//        
//        NSData  *imgData = (__bridge_transfer NSData *)ABPersonCopyImageData(record);
//        peopleItem.image = [UIImage imageWithData:imgData];
//        
//        if (!peopleItem.image) {
//            peopleItem.image = [UIImage imageNamed:@"icon-avatar-60x60"];
//        }
//        
//        [mutableContacts addObject:peopleItem];
//    }
//    
//    if(book) CFRelease(book);
//    
//    self.contacts = [NSArray arrayWithArray:mutableContacts];
//    self.selectedContacts = [NSMutableArray array];
//    self.filteredContacts = self.contacts;
//    
//    [self.tableView reloadData];
//    
//    
//}
//
//- (void) refreshContacts
//{
//    for (WFPeople *contact in self.contacts)
//    {
//        [self refreshContact: contact];
//    }
//    [self.tableView reloadData];
//}
//
//- (void) refreshContact:(WFPeople*)contact
//{
//    
//    ABRecordRef contactPerson = ABAddressBookGetPersonWithRecordID(self.addressBookRef, (ABRecordID)contact.recordId);
//    contact.recordId = ABRecordGetRecordID(contactPerson);
//    
//    // Get first and last names
//    NSString *firstName = (__bridge_transfer NSString*)ABRecordCopyValue(contactPerson, kABPersonFirstNameProperty);
//    NSString *lastName = (__bridge_transfer NSString*)ABRecordCopyValue(contactPerson, kABPersonLastNameProperty);
//    
//    
//    contact.firstName = firstName;
//    contact.lastName = lastName;
//    
//    
//    ABMultiValueRef phonesRef = ABRecordCopyValue(contactPerson, kABPersonPhoneProperty);
//    contact.phone = [self getMobilePhoneProperty:phonesRef];
//    if(phonesRef) {
//        CFRelease(phonesRef);
//    }
//    
//    NSData  *imgData = (__bridge_transfer NSData *)ABPersonCopyImageData(contactPerson);
//    contact.image = [UIImage imageWithData:imgData];
//    if (!contact.image) {
//        contact.image = [UIImage imageNamed:@"icon-avatar-60x60"];
//    }
//}
//
//
//- (NSString *)getMobilePhoneProperty:(ABMultiValueRef)phonesRef
//{
//    for (int i=0; i < ABMultiValueGetCount(phonesRef); i++) {
//        CFStringRef currentPhoneLabel = ABMultiValueCopyLabelAtIndex(phonesRef, i);
//        CFStringRef currentPhoneValue = ABMultiValueCopyValueAtIndex(phonesRef, i);
//        
//        if(currentPhoneLabel) {
//            if (CFStringCompare(currentPhoneLabel, kABPersonPhoneMobileLabel, 0) == kCFCompareEqualTo) {
//                CFRelease(currentPhoneLabel);
//                return (__bridge_transfer  NSString *)currentPhoneValue;
//            }
//            
//            if (CFStringCompare(currentPhoneLabel, kABHomeLabel, 0) == kCFCompareEqualTo) {
//                return (__bridge NSString *)currentPhoneValue;
//            }
//        }
//        if(currentPhoneLabel) {
//            CFRelease(currentPhoneLabel);
//        }
//        if(currentPhoneValue) {
//            CFRelease(currentPhoneValue);
//        }
//    }
//    
//    return nil;
//}
//
//- (void)viewWillAppear:(BOOL)animated
//{
//    [super viewWillAppear:animated];
//  
//   
//    dispatch_async(dispatch_get_main_queue(), ^{
//        [self refreshContacts];
//    });
//
//    
//}
//
//- (void)adjustTableViewFrame:(BOOL)animated
//{
//    CGRect frame = self.tableView.frame;
//    
//    frame.origin.y = self.contactPickerView.frame.size.height;
//    
//    frame.size.height = self.view.frame.size.height - self.contactPickerView.frame.size.height - kKeyboardHeight;
//    
//    if(animated) {
//        [UIView beginAnimations:nil context:nil];
//        [UIView setAnimationDuration:0.3];
//        [UIView setAnimationDelay:0.1];
//        [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
//        
//        self.tableView.frame = frame;
//        
//        [UIView commitAnimations];
//    }
//    else{
//        self.tableView.frame = frame;
//    }
//}
//
//- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
//{
//    return 1;
//}
//
//- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
//{
//    return self.filteredContacts.count;
//}
//
//- (CGFloat)tableView: (UITableView*)tableView heightForRowAtIndexPath: (NSIndexPath*) indexPath
//{
//    return 70;
//}
//
//- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
//    
//    
//    WFPeople *contact = [self.filteredContacts objectAtIndex:indexPath.row];
//    
//    NSString *cellIdentifier = @"peopleCell";
//    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
//    if (cell == nil){
//        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
//    }
//    
//    
//    UILabel *contactNameLabel = (UILabel *)[cell viewWithTag:101];
//    UILabel *mobilePhoneNumberLabel = (UILabel *)[cell viewWithTag:102];
//    UIImageView *contactImage = (UIImageView *)[cell viewWithTag:103];
//    UIImageView *checkboxImageView = (UIImageView *)[cell viewWithTag:104];
//
//    contactNameLabel.text = [contact fullName];
//    mobilePhoneNumberLabel.text = contact.phone;
//    if(contact.image) {
//        contactImage.image = contact.image;
//    }
//    contactImage.layer.masksToBounds = YES;
//    contactImage.layer.cornerRadius = 20;
//    
//    UIImage *image;
//    if ([self.selectedContacts containsObject:[self.filteredContacts objectAtIndex:indexPath.row]]){
//        
//        image = [UIImage imageNamed:@"icon-checkbox-selected-green-25x25"];
//    } else {
//        
//        image = [UIImage imageNamed:@"icon-checkbox-unselected-25x25"];
//    }
//    checkboxImageView.image = image;
//    
//    
//    cell.accessoryView = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
//    
//    [(UIButton *)cell.accessoryView addTarget:self action:@selector(viewContactDetail:) forControlEvents:UIControlEventTouchUpInside];
//    cell.accessoryView.tag = contact.recordId;
//    
//    
//    return cell;
//}
//
//- (void)viewContactDetail:(UIButton*)sender
//{
//    ABRecordID personId = (ABRecordID)sender.tag;
//    ABPersonViewController *person = [[ABPersonViewController alloc]init];
//    person.addressBook = self.addressBookRef;
//    person.personViewDelegate = self;
//    person.displayedPerson = ABAddressBookGetPersonWithRecordID(self.addressBookRef, personId);
//    
//
//    
//    [self.navigationController pushViewController:person animated:YES];
//}
//
//
//- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    [self.contactPickerView resignKeyboard];
//    
//    [tableView deselectRowAtIndexPath:indexPath animated:YES];
//    
//    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
//    
//    
//    WFPeople *user = [self.filteredContacts objectAtIndex:indexPath.row];
//    UIImageView *checkboxImageView = (UIImageView *)[cell viewWithTag:104];
//    UIImage *image;
//    
//    if ([self.selectedContacts containsObject:user]){
//        
//        [self.selectedContacts removeObject:user];
//        [self.contactPickerView removeContact:user];
//        
//        image = [UIImage imageNamed:@"icon-checkbox-unselected-25x25"];
//    } else {
//        
//        [self.selectedContacts addObject:user];
//        [self.contactPickerView addContact:user withName:user.fullName];
//        
//        image = [UIImage imageNamed:@"icon-checkbox-selected-green-25x25"];
//    }
//    
//    
//    if(self.selectedContacts.count > 0) {
//        self.barButton.enabled = TRUE;
//    }
//    else{
//        self.barButton.enabled = FALSE;
//    }
//    
//    
//    self.title = [NSString stringWithFormat:NSLocalizedString(@"Add Members (%lu)",nil), (unsigned long)self.selectedContacts.count];
//    
//    
//    checkboxImageView.image = image;
//    
//    self.filteredContacts = self.contacts;
//    
//    [self.tableView reloadData];
//}
//
//- (void)contactPickerTextViewDidChange:(NSString *)textViewText
//{
//    if ([textViewText isEqualToString:@""]){
//        self.filteredContacts = self.contacts;
//    } else {
//        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"self.%@ contains[cd] %@ OR self.%@ contains[cd] %@", @"firstName", textViewText, @"lastName", textViewText];
//        self.filteredContacts = [self.contacts filteredArrayUsingPredicate:predicate];
//    }
//    [self.tableView reloadData];
//}
//
//- (void)contactPickerDidResize:(WFContactPickerView *)contactPickerView
//{
//    [self adjustTableViewFrame:YES];
//}
//
//- (void)contactPickerDidRemoveContact:(id)contact
//{
//    [self.selectedContacts removeObject:contact];
//    
//    NSUInteger index = [self.contacts indexOfObject:contact];
//    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]];
//
//    if(self.selectedContacts.count > 0) {
//        self.barButton.enabled = TRUE;
//    }else{
//        self.barButton.enabled = FALSE;
//    }
//    
//    
//    UIImageView *checkboxImageView = (UIImageView *)[cell viewWithTag:104];
//    UIImage *image;
//    image = [UIImage imageNamed:@"icon-checkbox-unselected-25x25"];
//    checkboxImageView.image = image;
//    
//    
//    self.title = [NSString stringWithFormat:@"Add Members (%lu)", (unsigned long)self.selectedContacts.count];
//}
//
//- (void)removeAllContacts:(id)sender
//{
//    [self.contactPickerView removeAllContacts];
//    [self.selectedContacts removeAllObjects];
//    self.filteredContacts = self.contacts;
//    [self.tableView reloadData];
//}
//#pragma mark ABPersonViewControllerDelegate
//
//- (BOOL)personViewController:(ABPersonViewController *)personViewController shouldPerformDefaultActionForPerson:(ABRecordRef)person property:(ABPropertyID)property identifier:(ABMultiValueIdentifier)identifier
//{
//
//    [self prefersStatusBarHidden];
//    
//    return YES;
//}
//
//
//
//- (void)done:(id)sender
//{
//    
//    if (self.selectedContacts.count == 0) return;
//    
//    WFBackupData *data = [[WFBackupData alloc]init];
//    [data setBackupDataSoure];
//    NSString *title = NSLocalizedString(@"Please Select the file",nil);
//    self.alert = [WFTableAlert tableAlertWithTitle:title
//                                    cancelButtonTitle:NSLocalizedString(@"Cancel",nil)
//        numberOfRows:^NSInteger (NSInteger section){
//                                          
//            return data.paths.count;
//        }
//        andCells:^UITableViewCell* (WFTableAlert *anAlert, NSIndexPath *indexPath){
//                      
//            static NSString *CellIdentifier = @"CellIdentifier";
//            UITableViewCell *cell = [anAlert.table dequeueReusableCellWithIdentifier:CellIdentifier];
//            if (cell == nil)
//                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
//                      
//            WFPath *item = [data.paths objectAtIndex:indexPath.row];
//            cell.textLabel.text = item.rootName;
//                     
//            return cell;
//     }];
//    
//    
//    self.alert.height = 350;
//    
//    
//    [self.alert configureSelectionBlock:^(NSIndexPath *selectedIndex){
//        
////        [MBProgressHUD showMessage:@"正在备份中，请稍等"];
//        
//        NSData *persondata = [NSKeyedArchiver archivedDataWithRootObject:self.selectedContacts];
// 
//        WFPath *item = [data.paths objectAtIndex:selectedIndex.row];
//        
//        NSString *destPath = [item.rootPath stringByAppendingSMBPathComponent:@"Contacts.data"];
//
//        self.destPath = destPath;
//
//        if ([WFActionTool isExistsAtPath:destPath]) {
//            
//            [WFActionTool removeFileAtPath:self.destPath];
//        }
//
//        if ([item.rootPath hasPrefix:SAMBA_URL]) { //上传到 dock 端
//            
//            id result = [[IGLSMBProvier sharedSmbProvider]  createFileAtPath:destPath overwrite:YES];
//            if(![result isKindOfClass:[IGLSMBItemFile class]]) return;
//            
//            IGLSMBItemFile *file = (IGLSMBItemFile *)result;
//            
//            [file writeData:persondata];
//            
//        }else{
//            
//            [persondata writeToFile:destPath atomically:YES];
//            
//        }
//        [MBProgressHUD hideHUD];
//        
//        [MBProgressHUD showSuccess:NSLocalizedString(@"Backup Successfully",nil)];
//   
//    } andCompletionBlock:^{
//        
//    }];
//    
//   
//    [self.alert show];
//    
//}
//-(void)getaddress
//{
//    //读取所有联系人
//    [self ReadAllPeoplesinfo];
//    [self FileFromLocal];
//    //[self readFile];
//}
//
//-(void)readFile{
//    //读文件
//    NSArray* pathss = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
//    NSString* thepath = [pathss objectAtIndex:0];
//    thepath = [thepath stringByAppendingPathComponent:@"Contacts.vcf"];
//    NSLog(@"thepath %@",thepath);
//    NSString* content = [NSString stringWithContentsOfFile:thepath encoding:NSUTF8StringEncoding error:nil];
//    NSLog(@"NSString类方法读取的内容是：\n%@",content);
//    [self Parasecontent:content];
//}
//-(void)Parasecontent:(NSString*)vcardString{
//    NSArray *lines = [vcardString componentsSeparatedByString:@"\n"];
//    for(NSString* line in lines)
//    {
//        if ([line hasPrefix:@"BEGIN"])
//        {
//            NSLog(@"parse start");
//        }
//        else if ([line hasPrefix:@"END"])
//        {
//            NSLog(@"parse end");
//        }
//        else if ([line hasPrefix:@"N:"])
//        {
//            NSArray *upperComponents = [line componentsSeparatedByString:@":"];
//            NSArray *components = [[upperComponents objectAtIndex:1] componentsSeparatedByString:@";"];
//            NSString * firstname = [components objectAtIndex:0];
//            NSString * lastname = [components objectAtIndex:1];
//            NSLog(@"firstname %@ ",firstname);
//            NSLog(@"lastname %@ ",lastname);
//            
//        }
//        else if ([line hasPrefix:@"FN:"])
//        {
//            NSArray *components = [line componentsSeparatedByString:@":"];
//            NSString *compositeName = [components objectAtIndex:1];
//            NSLog(@"compositeName %@",compositeName);
//            
//        }
//        //        else if ([line hasPrefix:@"TEL;"])
//        //        {
//        //            NSArray *components = [line componentsSeparatedByString:@":"];
//        //            NSString *middlename = [components objectAtIndex:1];
//        //            NSLog(@"middlename %@",middlename);
//        //        }
//        else if ([line hasPrefix:@"TEL;"])
//        {
//            NSArray *components = [line componentsSeparatedByString:@":"];
//            NSString *personPhone = [components objectAtIndex:1];
//            NSLog(@"personPhone %@",personPhone);
//        }
//    }
//}
//
//-(void)showdialog{
//    [self requestAccessAddressBook];
//    WFBackupData *data = [[WFBackupData alloc]init];
//    [data setBackupDataSoure];
//    NSString *title = NSLocalizedString(@"Please Select the file",nil);
//    self.alert = [WFTableAlert tableAlertWithTitle:title
//                                 cancelButtonTitle:NSLocalizedString(@"Cancel",nil)
//                                      numberOfRows:^NSInteger (NSInteger section){
//                                          
//                                          return data.paths.count;
//                                      }
//                                          andCells:^UITableViewCell* (WFTableAlert *anAlert, NSIndexPath *indexPath){
//                                              
//                                              static NSString *CellIdentifier = @"CellIdentifier";
//                                              UITableViewCell *cell = [anAlert.table dequeueReusableCellWithIdentifier:CellIdentifier];
//                                              if (cell == nil)
//                                                  cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
//                                              
//                                              WFPath *item = [data.paths objectAtIndex:indexPath.row];
//                                              cell.textLabel.text = item.rootName;
//                                              
//                                              return cell;
//                                          }];
//    self.alert.height = 350;
//    [self.alert configureSelectionBlock:^(NSIndexPath *selectedIndex){
//        //        [MBProgressHUD showMessage:@"正在备份中，请稍等"];
//        [self getaddress];
//        NSData *persondata = [NSKeyedArchiver archivedDataWithRootObject:self.selectedContacts];
//        WFPath *item = [data.paths objectAtIndex:selectedIndex.row];
//        NSString *destPath = [item.rootPath stringByAppendingSMBPathComponent:@"Contacts.vcf"];
//        self.destPath = destPath;
//        if ([WFActionTool isExistsAtPath:destPath]) {
//            [WFActionTool removeFileAtPath:self.destPath];
//        }
//        if ([item.rootPath hasPrefix:SAMBA_URL]) { //上传到 dock 端
//            
//            id result = [[IGLSMBProvier sharedSmbProvider]  createFileAtPath:destPath overwrite:YES];
//            if(![result isKindOfClass:[IGLSMBItemFile class]]) return;
//            
//            IGLSMBItemFile *file = (IGLSMBItemFile *)result;
//            
//            NSData* xmlData = [self.forbooks dataUsingEncoding:NSUTF8StringEncoding];
//            [file writeData:xmlData];
//            
//        }else{
//            
//            [persondata writeToFile:destPath atomically:YES];
//            
//        }
//        [MBProgressHUD hideHUD];
//        
//        [MBProgressHUD showSuccess:NSLocalizedString(@"Backup Successfully",nil)];
//        
//    } andCompletionBlock:^{
//        
//    }];
//    
//    [self.alert show];
//
//}
//-(void)FileFromLocal{
//    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
//    NSString *documentDirectory = [paths objectAtIndex:0];
//    NSString *filepath = [documentDirectory stringByAppendingPathComponent:@"Contacts.vcf"];
//    NSLog(@"filepath %@",filepath);
//    NSFileManager *fileManager = [NSFileManager defaultManager];
//    //    [fileManager fileExistsAtPath:filepath];
//    if (![fileManager fileExistsAtPath:filepath]) {
//        [fileManager createFileAtPath:filepath contents:nil attributes:nil];
//        NSLog(@"log for books %@",self.forbooks);
//        [self.forbooks writeToFile:filepath atomically:YES encoding:NSUTF8StringEncoding error:nil];
//        //[fileManager removeItemAtPath:pathFile error:nil];
//    }
//}
//
//-(void)Parasecontent {
//    NSArray* pathss = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
//    NSString* thepath = [pathss objectAtIndex:0];
//    thepath = [thepath stringByAppendingPathComponent:@"Contacts.vcf"];
//    NSLog(@"thepath %@",thepath);
//    NSString* content = [NSString stringWithContentsOfFile:thepath encoding:NSUTF8StringEncoding error:nil];
//    NSLog(@"NSString类方法读取的内容是：\n%@",content);
//    
//    self.addressBookTemp = [NSMutableArray array];
//    NSArray *lines = [content componentsSeparatedByString:@"\n"];
//    for(NSString* line in lines)
//    {
//        if ([line hasPrefix:@"BEGIN"])
//        {
//            self.addressBook = [[AddressBook alloc] init];
//            NSLog(@"parse start");
//        }
//        else if ([line hasPrefix:@"END"])
//        {
//            [self.addressBookTemp addObject:self.addressBook];
//            NSLog(@"parse end");
//        }
//        else if ([line hasPrefix:@"FN:"])
//        {
//            NSArray *upperComponents = [line componentsSeparatedByString:@":"];
//            if([upperComponents count]>1){
//                NSString * personName = [upperComponents objectAtIndex:1];
//                self.addressBook.compositename = personName;
//                NSLog(@"personName %@ ",personName);
//            }
//        }
//        else if ([line hasPrefix:@"N:"])
//        {
//            NSArray *component = [line componentsSeparatedByString:@":"];
//            if([component count]>1){
//                NSArray *components = [component[1] componentsSeparatedByString:@";"];
//                
//                NSString *firstname = [components objectAtIndex:0];
//                self.addressBook.firstname = firstname;
//                if([components count]>1){
//                    NSString *lastname = [components objectAtIndex:1];
//                    self.addressBook.lastname = lastname;
//                }
//            }
//        }
//        else if ([line hasPrefix:@"TEL;"])
//        {
//            NSArray *components = [line componentsSeparatedByString:@":"];
//            if([components count]>1){
//                NSString *personPhone = [components objectAtIndex:1];
//                self.addressBook.tel = personPhone;
//            }
//        }
//    }
//    
//}
//-(void)ReadAllPeoplesinfo
//{
//    //ABAddressBookRef addressBook = ABAddressBookCreate();
//    ABAddressBookRef addressBook = nil;
//    
//    if ([[UIDevice currentDevice].systemVersion floatValue]>=6.0) {
//        addressBook=ABAddressBookCreateWithOptions(NULL, NULL);
//        dispatch_semaphore_t sema=dispatch_semaphore_create(0);
//        ABAddressBookRequestAccessWithCompletion(addressBook, ^(bool greanted, CFErrorRef error){
//            dispatch_semaphore_signal(sema);
//        });
//        
//        dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
//    }
//    else
//    {
//        CFErrorRef* error=nil;
//        addressBook =ABAddressBookCreateWithOptions(NULL, error);
//    }
//    CFArrayRef results = ABAddressBookCopyArrayOfAllPeople(addressBook);
//    self.forbooks = @"";
//    for(int i = 0; i < CFArrayGetCount(results); i++)
//    {
//        ABRecordRef person = CFArrayGetValueAtIndex(results, i);
//        NSString *firstName = (__bridge NSString*)ABRecordCopyValue(person, kABPersonFirstNameProperty);
//        firstName = (firstName ? firstName : @"");
//        NSString *lastName = (__bridge NSString *)ABRecordCopyValue(person, kABPersonLastNameProperty);
//        lastName = (lastName ? lastName : @"");
//        NSString *middleName = (__bridge NSString *)ABRecordCopyValue(person, kABPersonMiddleNameProperty);
//        NSString *prefix = (__bridge NSString *)ABRecordCopyValue(person, kABPersonPrefixProperty);
//        NSString *suffix = (__bridge NSString *)ABRecordCopyValue(person, kABPersonSuffixProperty);
//        NSString *compositeName = [NSString stringWithFormat:@"%@%@",firstName,lastName];
//        if(i > 0) {
//            self.forbooks = [self.forbooks stringByAppendingFormat:@"\n"];
//        }
//        self.forbooks = [self.forbooks stringByAppendingFormat:@"BEGIN:VCARD\nVERSION:3.0\nN:%@;%@;%@;%@;%@\n",
//                         (firstName ? firstName : @""),
//                         (lastName ? lastName : @""),
//                         (middleName ? middleName : @""),
//                         (prefix ? prefix : @""),
//                         (suffix ? suffix : @"")
//                         ];
//        self.forbooks = [self.forbooks stringByAppendingFormat:@"FN:%@\n",compositeName];
//        ABMultiValueRef phoneNumbers = ABRecordCopyValue(person, kABPersonPhoneProperty);
//        if(phoneNumbers) {
//            for (int k = 0; k < ABMultiValueGetCount(phoneNumbers); k++) {
//                NSString *label = (__bridge NSString*)ABAddressBookCopyLocalizedLabel(ABMultiValueCopyLabelAtIndex(phoneNumbers, k));
//                NSString *number = (__bridge NSString *)ABMultiValueCopyValueAtIndex(phoneNumbers, k);
//                NSString *labelLower = [label lowercaseString];
//                
//                if ([labelLower isEqualToString:@"mobile"]) self.forbooks = [self.forbooks stringByAppendingFormat:@"TEL;type=CELL:%@\n",number];
//                else if ([labelLower isEqualToString:@"home"]) self.forbooks = [self.forbooks stringByAppendingFormat:@"TEL;type=HOME:%@\n",number];
//                else if ([labelLower isEqualToString:@"work"]) self.forbooks = [self.forbooks stringByAppendingFormat:@"TEL;type=WORK:%@\n",number];
//                else if ([labelLower isEqualToString:@"main"]) self.forbooks = [self.forbooks stringByAppendingFormat:@"TEL;type=MAIN:%@\n",number];
//                else if ([labelLower isEqualToString:@"homefax"]) self.forbooks = [self.forbooks stringByAppendingFormat:@"TEL;type=HOME;type=FAX:%@\n",number];
//                else if ([labelLower isEqualToString:@"workfax"]) self.forbooks = [self.forbooks stringByAppendingFormat:@"TEL;type=WORK;type=FAX:%@\n",number];
//                else if ([labelLower isEqualToString:@"pager"]) self.forbooks = [self.forbooks stringByAppendingFormat:@"TEL;type=PAGER:%@\n",number];
//                else if([labelLower isEqualToString:@"other"]) self.forbooks = [self.forbooks stringByAppendingFormat:@"TEL;type=OTHER:%@\n",number];
//                else { //类型解析不出来的
//                    //counter++;
//                    self.forbooks = [self.forbooks stringByAppendingFormat:@"TEL;type=other:%@\nitem.X-ABLabel:%@\n",number,label];
//                }
//            }
//        }
//        self.forbooks = [self.forbooks stringByAppendingString:@"END:VCARD"];
//    }
//}
//
//-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
//{
//    if (alertView.tag == 100) {
//        
//        if (buttonIndex == 0) return;
//        
//        
//        
//    }
//}
//
//-(void)dealloc
//{
//    NSLog(@"getCurrentRootPath");
//}
//
//- (NSString *)getCurrentRootPath
//{
//    return nil;
//}
//
//@end
