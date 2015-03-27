//
//  AccessAuthorUtils.h
//  IGL004
//
//  Created by apple on 2014/03/18.
//  Copyright (c) 2014年 hualu. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^IsAccessEnableWithIsShowAlertBlock)(BOOL isAccessEnable);
@interface AccessAuthorUtils : NSObject

+ (void)isPhotoAccessEnableWithIsShowAlert:(BOOL)_isShowAlert
                              completion:(IsAccessEnableWithIsShowAlertBlock)_completion;

@end
