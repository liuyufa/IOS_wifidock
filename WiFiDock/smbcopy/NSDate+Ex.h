//
//  NSDate+Ex.h
//  IGL004
//
//  Created by apple on 2014/03/06.
//  Copyright (c) 2014年 hualu. All rights reserved.
//

#import <Foundation/Foundation.h>
#define DATETIME_FORMAT @"yyyyMMddHHmmss"
#define DATETIME_FORMAT_1 @"yyyy-MM-dd HH:mm:ss"
@interface NSDate (Ex)
-(NSString*)stringWithDefaultFormat;
-(NSString*)stringWithFormat:(NSString *)string;
@end
