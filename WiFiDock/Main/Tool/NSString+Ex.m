//
//  NSString(Ex).m
//  IGL004
//
//  Created by apple on 2014/01/20.
//  Copyright (c) 2014年 hualu. All rights reserved.
//

#import "NSString+Ex.h"

@implementation NSString(Ex)

-(NSString*)encodeSambaUrl{
    return [[self stringByReplacingOccurrencesOfString:@"/" withString:@"*"] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
}
-(NSString*)decodeSambaUrl{
//    return [[NSString stringWithFormat:@"%@/",[self stringByReplacingOccurrencesOfString:@"*" withString:@"/"]] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding] ;
    return  [[self stringByReplacingOccurrencesOfString:@"*" withString:@"/"] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
}
-(NSString*)pathByDeletingLastPathComponent{
    NSRange range = [self rangeOfString:@"/" options:NSBackwardsSearch];
    return [self substringToIndex:range.location];
}

-(BOOL)isValidateFolderName{
    NSString *regex = @"^[^\\/?%*:|\"<>\\.]+$";
    NSPredicate *test = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    return [test evaluateWithObject:self];
}


- (NSString *) stringByAppendingSMBPathComponent: (NSString *) aString
{
    NSString *path = self;
    if (![path hasSuffix:@"/"]) {
        path = [path stringByAppendingString:@"/"];
    }
    return [path stringByAppendingString:aString];
}

- (NSString *)stringByDeletingSMBLastPathComponent{
    NSString *path = self;
    NSRange range = [path rangeOfString:@"/" options:NSBackwardsSearch];
    return [path substringToIndex:range.location];
    
}
- (NSString *)stringReplaceSMBLastPathComponent: (NSString *) aString{
    return [[self stringByDeletingSMBLastPathComponent] stringByAppendingSMBPathComponent:aString];
}
- (NSString *)stringByAppendingSMBPathExtension:(NSString *)str{
    NSString *path = self;
    if (![path hasSuffix:@"."]) {
        path = [path stringByAppendingString:@"."];
    }
    return [path stringByAppendingString:str];
}


-(BOOL)isValidateIpAdr {
    NSString *regex = @"\\b(?:\\d{1,3}\\.){3}\\d{1,3}\\b";
    //NSString *emailRegex = @"[0-9]{1,3}+\\.[0-9]{1,3}+\\.[0-9]{1,3}+\\.[0-9]{1,3}";
    NSPredicate *ipTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    if([ipTest evaluateWithObject:self]){
        NSArray *array = [self componentsSeparatedByString:@"."];
        if([array count] != 4){
            return false;
        }
        for (NSString *str in array) {
            int value = [str intValue];
            if(value < 0 || value > 255){
                return false;
            }
        }
        
    }else{
        return false;
    }
    return true;
}
-(NSString*)addUTF8Encodeing{
    return [self stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
}

-(BOOL)isValidateApahe {
    NSString *regex = @"^[a-zA-Z0-9_]+$";
    NSPredicate *preTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    return [preTest evaluateWithObject:self];
}

@end
