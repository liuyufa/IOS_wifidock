//
//  WFTransferItem.h
//  WiFiDock
//
//  Created by apple on 15-1-8.
//  Copyright (c) 2015年 cn.hualu.WiFiDock. All rights reserved.
//

#import <Foundation/Foundation.h>

@class IGLNSOperation,UIImage,UIButton;
@interface WFTransferItem : NSObject

@property (nonatomic, copy) NSString *fileName;
@property (nonatomic, strong)IGLNSOperation *operation;
@property (nonatomic, assign)float progress;
@property (nonatomic, copy)NSString *percent;
@property(nonatomic, strong)NSTimer *time;


-(instancetype)initWithOperation:(IGLNSOperation*)obj;
+(instancetype)transferItemWithOperation:(IGLNSOperation*)obj;
@end
