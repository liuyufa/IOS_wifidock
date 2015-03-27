//
//  IGLActionItem.h
//  IGL004
//
//  Created by apple on 2014/05/23.
//  Copyright (c) 2014年 hualu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface IGLActionItem : NSObject
@property(nonatomic,copy) NSString *fromPath;
@property(nonatomic,copy) NSString *toPath;
@property(nonatomic,assign) TheSameFileOperation operation;
@property(nonatomic,assign) long long  fileSize;
@property(nonatomic,assign) long long  overedSize;
@property(nonatomic,assign) BOOL isFolder;
@property(nonatomic,assign) BOOL isCut;
+(id)itemWithPath:(NSString*)f t:(NSString*)t;
@end
