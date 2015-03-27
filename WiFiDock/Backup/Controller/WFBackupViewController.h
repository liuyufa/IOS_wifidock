//
//  WFBackupViewController.h
//  WiFiDock
//
//  Created by apple on 14-12-2.
//  Copyright (c) 2014年 cn.hualu.WiFiDock. All rights reserved.
//

#import "WFBaseSetController.h"

@interface WFBackupViewController : WFBaseSetController

@end

@interface AddressBook : NSObject {
    NSString *firstname;
    NSString *lastname;
    NSString *compositename;
    NSString *tel;
}
@property (nonatomic, retain) NSString *firstname;
@property (nonatomic, retain) NSString *lastname;
@property (nonatomic, retain) NSString *compositename;
@property (nonatomic, retain) NSString *tel;
@end