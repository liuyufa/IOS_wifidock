//
//  NSString(Ex).h
//  IGL004
//
//  Created by apple on 2014/01/20.
//  Copyright (c) 2014年 hualu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString(Ex)

-(NSString*)encodeSambaUrl;
-(NSString*)decodeSambaUrl;
-(NSString*)pathByDeletingLastPathComponent;
-(BOOL)isValidateFolderName;
//-(id)JSON;
- (NSString *) stringByAppendingSMBPathComponent: (NSString *) aString;
- (NSString *)stringByDeletingSMBLastPathComponent;
- (NSString *)stringReplaceSMBLastPathComponent: (NSString *) aString;
- (NSString *)stringByAppendingSMBPathExtension:(NSString *)str;

-(BOOL)isValidateIpAdr;
-(NSString*)addUTF8Encodeing;
-(BOOL)isValidateApahe;
@end
