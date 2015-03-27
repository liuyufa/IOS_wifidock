//
//  WFSmbUser.h
//  WiFiDock
//
//  Created by apple on 14-12-23.
//  Copyright (c) 2014年 cn.hualu.WiFiDock. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WFSmbUser : NSObject
@property (nonatomic, copy) NSString *workgroup;
@property (nonatomic, copy) NSString *username;
@property (nonatomic, copy) NSString *password;

+ (instancetype) smbUserWithGroup: (NSString *)workgroup
               username: (NSString *)username
               password: (NSString *)password;
- (instancetype)initWithGroup: (NSString *)workgroup
                     username: (NSString *)username
                     password: (NSString *)password;
@end
