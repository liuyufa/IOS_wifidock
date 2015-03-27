//
//  WFPersonViewController.m
//  WiFiDock
//
//  Created by apple on 15-1-12.
//  Copyright (c) 2015年 cn.hualu.WiFiDock. All rights reserved.
//

#import "WFPersonViewController.h"

@interface WFPersonViewController ()<ABPersonViewControllerDelegate>

@end

@implementation WFPersonViewController

//-initWithaddressBook:(ABAddressBookRef)addressBookRef
//{
//    self = [super init];
//    if (self) {
//       
//    }
//    return self;
//}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.personViewDelegate = self;
}

-(BOOL)personViewController:(ABPersonViewController *)personViewController shouldPerformDefaultActionForPerson:(ABRecordRef)person property:(ABPropertyID)property identifier:(ABMultiValueIdentifier)identifier
{
    return YES;
}



@end
