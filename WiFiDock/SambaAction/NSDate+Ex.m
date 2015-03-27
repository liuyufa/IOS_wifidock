//
//  NSDate+Ex.m
//  IGL004
//
//  Created by apple on 2014/03/06.
//  Copyright (c) 2014年 hualu. All rights reserved.
//

#import "NSDate+Ex.h"

@implementation NSDate (Ex)
-(NSString*)stringWithDefaultFormat
{
    NSDateFormatter *formatter =  [[NSDateFormatter alloc] init];
    [formatter setDateFormat:DATETIME_FORMAT];
    return [formatter stringFromDate:self];
}
-(NSString*)stringWithFormat:(NSString *)string
{
    NSDateFormatter *formatter =  [[NSDateFormatter alloc] init];
    [formatter setDateFormat:string];
    return [formatter stringFromDate:self];
}
@end
