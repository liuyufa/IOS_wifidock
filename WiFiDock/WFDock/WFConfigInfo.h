//
//  WFConfigInfo.h
//  IGL004
//
//  Created by apple on 14-10-24.
//  Copyright (c) 2014年 hualu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WFConfigInfo : NSObject

-(NSString *)getConfigInfo:(NSString*) dessFlag;
-(NSString *)readConfigFilefromLocal:(NSString *)fileName;
-(void)getConfigInfoFromSmb:(NSString *)remoteUrl;
-(void)deleteConfigFileFromLocal:(NSString *)pathFile;

@end
