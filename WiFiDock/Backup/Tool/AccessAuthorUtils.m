//
//  AccessAuthorUtils.m
//  IGL004
//
//  Created by apple on 2014/03/18.
//  Copyright (c) 2014年 hualu. All rights reserved.
//

#import "AccessAuthorUtils.h"
#import<AssetsLibrary/AssetsLibrary.h>
#import<AddressBook/AddressBook.h>
#import <UIKit/UIKit.h>

@implementation AccessAuthorUtils
+ (void)isPhotoAccessEnableWithIsShowAlert:(BOOL)_isShowAlert
                              completion:(IsAccessEnableWithIsShowAlertBlock)_completion
{
    IsAccessEnableWithIsShowAlertBlock completion = [_completion copy];
    
    // iOS7.0未満
    NSString *iOsVersion = [[UIDevice currentDevice] systemVersion];
    if ( [iOsVersion compare:@"6.0" options:NSNumericSearch] == NSOrderedAscending ) {
        completion(YES);
        return;
    }
    ALAuthorizationStatus status = [ALAssetsLibrary authorizationStatus];
    switch (status) {
        case ALAuthorizationStatusAuthorized:
            completion(YES);
            break;
        case ALAuthorizationStatusNotDetermined: 
        {
            ALAssetsLibrary *assetsLibrary = [[ALAssetsLibrary alloc] init];
            
            [assetsLibrary enumerateGroupsWithTypes:ALAssetsGroupAll usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
                
                if (*stop) {
                    completion(YES);
                    return;
                }
                *stop = TRUE;
                
            } failureBlock:^(NSError *error) {
                completion(NO);
            }];
            
        }
            break;
        case ALAuthorizationStatusRestricted:
        {
            if (_isShowAlert) {
                UIAlertView *alertView = [[UIAlertView alloc]
                                          initWithTitle:nil
                                          message:NSLocalizedString(@"No authorized to access photo data",nil)
                                          delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
                [alertView show];
            }
            completion(NO);
        }
            break;
        case ALAuthorizationStatusDenied:
        {
            if (_isShowAlert) {
                UIAlertView *alertView = [[UIAlertView alloc]
                                          initWithTitle:nil
                                          message:NSLocalizedString(@"No authorized to access photo data",nil)
                                          delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
                [alertView show];
            }
            completion(NO);
        }
            break;
            
        default:
            break;
    }
}


@end
