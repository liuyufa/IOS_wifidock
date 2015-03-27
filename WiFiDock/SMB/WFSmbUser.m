//
//  WFSmbUser.m
//  WiFiDock
//
//  Created by apple on 14-12-23.
//  Copyright (c) 2014年 cn.hualu.WiFiDock. All rights reserved.
//

#import "WFSmbUser.h"

@implementation WFSmbUser
+ (id) smbUserWithGroup: (NSString *)workgroup
               username: (NSString *)username
               password: (NSString *)password
{
    return [[self alloc]initWithGroup:workgroup username:username password:password];
}

-(instancetype)initWithGroup:(NSString *)workgroup username:(NSString *)username password:(NSString *)password
{
    self = [super init];
    if (self) {   
        self.workgroup = workgroup;
        self.username = username;
        self.password = password;
    }
    
    return self;
    
}

@end
