//
//  WFBackupData.h
//  WiFiDock
//
//  Created by apple on 15-1-12.
//  Copyright (c) 2015年 cn.hualu.WiFiDock. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WFBackupData : NSObject

@property(nonatomic, strong)NSMutableArray *contacts;

@property(nonatomic, copy)NSString *rootSambaDockPath;
@property(nonatomic, copy)NSString *rootSambaTFPath;
@property(nonatomic, copy)NSString *rootSambaUSBPath;
@property(nonatomic, copy)NSString *rootLocalPath;

@property(nonatomic, strong)NSMutableArray *paths;

-(void)setBackupDataSoure;
@end
