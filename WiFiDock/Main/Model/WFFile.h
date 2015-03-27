//
//  WFFile.h
//  WiFiDock
//
//  Created by apple on 14-12-5.
//  Copyright (c) 2014年 cn.hualu.WiFiDock. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class IGLSMBItem;
@interface WFFile : NSObject


@property (nonatomic, copy) NSString *fileName;
@property (nonatomic, copy) NSString *fileType;
@property (nonatomic, copy) NSString *fileSize;
@property (nonatomic, copy) NSString *createData;
@property (nonatomic, copy) NSString *modifyData;
@property (nonatomic, strong) UIImage *icon;
//@property (nonatomic, strong) NSURL *filePath;
@property (nonatomic, copy)NSString *filePath;
@property (nonatomic, assign) BOOL flag;
@property (nonatomic, strong) id ID;
@property (nonatomic, assign) FileType type;


- (instancetype)initWithId:(id)idItem withType:(NSString *)fileType;
//- (instancetype)initWithName:(NSString *)fileName withType:(NSString *)fileType;
- (instancetype)initWithPath:(NSString *)filePath WithName:(NSString *)fileName withDic:(NSDictionary*)dic;
- (instancetype)initWithSmbItem:(IGLSMBItem *)smbItem fileType:(NSString *)fileType;
- (instancetype)initWithFile:(WFFile *)file witthPath:(NSString *)destPath;
- (instancetype)initWithName:(NSString *)fileName filePath:(NSString *)filePath withType:(NSString *)fileType;
- (instancetype)initWithName:(NSString *)fileName filePath:(NSString *)filePath isEncrypt:(BOOL)flag;
- (instancetype)initWithPath:(NSString *)filePath file:(WFFile*)file;
- (instancetype)initWithPath:(NSString *)filePath;
@end
