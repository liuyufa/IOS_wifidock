//
//  WFAction.h
//  WiFiDock
//
//  Created by apple on 15-1-7.
//  Copyright (c) 2015年 cn.hualu.WiFiDock. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WFAction : NSObject
@property(nonatomic,copy)NSString *from;
@property(nonatomic,copy)NSString *dest;
@property(nonatomic,copy)NSString *fileName;
@property(nonatomic,assign)BOOL isFolder;
@property(nonatomic,assign)long long fileSize;
@property(nonatomic,assign)long long overedSize;
@property(nonatomic,assign)BOOL isCut;

+(instancetype)actionWithPath:(NSString*)from to:(NSString*)dest;
-(instancetype)initWithPath:(NSString*)from to:(NSString*)dest;

@end
