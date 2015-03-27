//
//  IGLCopyPhotosAction.h
//  IGL004
//
//  Created by apple on 2014/05/25.
//  Copyright (c) 2014年 hualu. All rights reserved.
//

#import "IGLNSOperation.h"
#import "IGLSMBProvier.h"
#import "IGLActionUtils.h"
#import<AssetsLibrary/AssetsLibrary.h>
#import <AddressBook/AddressBook.h>

@interface IGLCopyPhotosAction : IGLNSOperation
{
    int numofphoto;
    int backupover;
    NSString *_rootpath;
    NSString *_subpath;
    NSString *_copyPath;
}
-(id)initWithCopyPath:(NSString*)copyPath;
- (void)startAsynchronous;
@end
