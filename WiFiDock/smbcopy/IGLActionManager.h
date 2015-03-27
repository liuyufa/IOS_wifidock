//
//  IGLActionManager.h
//  IGL004
//
//  Created by apple on 2014/02/24.
//  Copyright (c) 2014年 hualu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IGLSMBProvier.h"
#include "FileUtil_C.h"
#import "IGLActionItem.h"
#import "IGLActionUtils.h"
#import "IGLNSOperation.h"
#import "IGLCopyAction.h"


@interface IGLActionManager : NSObject{
    NSOperationQueue *_sharedQueue;
    NSMutableArray *_optionArray;
}
@property(nonatomic,retain) NSOperationQueue *sharedQueue;
@property(nonatomic,retain) NSMutableArray *optionArray;
+(void)setManage:(IGLActionManager*)m;
+(IGLActionManager *)sharedManage;
-(void)addOperation:(NSOperation*)operation;
-(void)removeOperation:(NSOperation*)operation;
+(IGLCopyAction*)getCopyActionWithItem:(IGLActionItem*)item;
@end

//@interface IGLCopyFileManager : IGLNSOperation{
//     NSString *_targetpath;
//}
//@property(nonatomic,retain) IGLActionItem *item;
//- (void)startAsynchronous;
//+(id)actionWithItem:(IGLActionItem*)item;
//@end
//
//@interface IGLCopyPhotosManager : IGLNSOperation{
//    int numofphoto;
//    int backupover;
//    NSString *_rootpath;
//    NSString *_subpath;
//    NSString *_copyPath;
//}
//-(id)initWithCopyPath:(NSString*)copyPath;
//- (void)startAsynchronous;
//@end
//
//@interface IGLCopyContactsManager : IGLNSOperation{
//    long long  fileSize;
//    long long  overedSize;
//    NSString * _targetpath;
//    NSString * _copyPath;
//}
//-(id)initWithCopyPath:(NSString*)copyPath;
//- (void)startAsynchronous;
//@end
