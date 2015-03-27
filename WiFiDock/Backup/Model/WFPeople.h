//
//  WFPeople.h
//  WiFiDock
//
//  Created by apple on 15-1-12.
//  Copyright (c) 2015年 cn.hualu.WiFiDock. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


@interface WFPeople : NSObject<NSCoding>

- (instancetype)initWithAttributes:(NSDictionary *)attributes;
- (NSString *)fullName;

@property (nonatomic, assign) NSInteger recordId;
@property (nonatomic, copy) NSString *firstName;
@property (nonatomic, copy) NSString *lastName;
@property (nonatomic, copy) NSString *phone;
@property (nonatomic, copy) NSString *email;
@property (nonatomic, strong) UIImage *image;
@property (nonatomic, assign, getter = isSelected) BOOL selected;
@property (nonatomic, strong) NSDate *date;
@property (nonatomic, strong) NSDate *dateUpdated;

@end
