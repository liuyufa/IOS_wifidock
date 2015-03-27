//
//  WFSmbFileStat.h
//  WiFiDock
//
//  Created by apple on 14-12-23.
//  Copyright (c) 2014年 cn.hualu.WiFiDock. All rights reserved.
//


#import <Foundation/Foundation.h>


@interface WFSmbFileState : NSObject
@property(nonatomic, strong) NSDate *createTime;
@property(nonatomic, strong) NSDate *lastModified;
@property(nonatomic, strong) NSDate *lastAccess;
@property(nonatomic, assign) long long size;
@property(nonatomic, assign) long mode;


@end
