//
//  WFItem.h
//  WiFiDock
//
//  Created by apple on 14-12-8.
//  Copyright (c) 2014年 cn.hualu.WiFiDock. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WFItem : NSObject
@property (nonatomic, copy) NSString *icon;
@property (nonatomic, copy) NSString *fileName;
@property (nonatomic, copy) NSString *fileType;
@property (nonatomic, copy) NSString *fileSize;
@property (nonatomic, strong) NSURL *filePath;


@end
