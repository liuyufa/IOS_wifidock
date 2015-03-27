//
//  WFDataSource.h
//  WiFiDock
//
//  Created by apple on 14-12-28.
//  Copyright (c) 2014年 cn.hualu.WiFiDock. All rights reserved.
//

#import <Foundation/Foundation.h>

@class UITableView;

@interface WFDataSource : NSObject
-(instancetype)initWithRootPath:(NSString *)dirPath fileType:(NSString *)fileType;
+(instancetype)dataSourceWithRootPath:(NSString *)dirPath fileType:(NSString *)fileType;
@property(nonatomic,strong)NSMutableArray *datasource;

- (void)loading;
- (void)loadDirectoryData;

- (void)tableView:(UITableView*)tableView getDataFromDocument:filePath;

@end
