//
//  WFPeople.m
//  WiFiDock
//
//  Created by apple on 15-1-12.
//  Copyright (c) 2015年 cn.hualu.WiFiDock. All rights reserved.
//

#import "WFPeople.h"

@interface WFPeople ()



@end

@implementation WFPeople

- (instancetype)initWithAttributes:(NSDictionary *)attributes
{
    self = [super init];
    if (self) {
        [self setValuesForKeysWithDictionary:attributes];
    }
    
    return self;
}

- (void)setValue:(id)value forKey:(NSString *)key
{
    if ([key isEqualToString:@"id"]) {
        self.recordId = [value integerValue];
    } else if ([key isEqualToString:@"firstName"]) {
        self.firstName = value;
    } else if ([key isEqualToString:@"lastName"]) {
        self.lastName = value;
    } else if ([key isEqualToString:@"phone"]) {
        self.phone = value;
    }else if ([key isEqualToString:@"email"]) {
        self.email = value;
    }else if ([key isEqualToString:@"image"]) {
        self.image = value;
    }else if ([key isEqualToString:@"isSelected"]) {
        self.selected = [value boolValue];
    }else if ([key isEqualToString:@"date"]) {
        // TODO: Fix
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.dateFormat = @"yyyy-MM-dd";
        self.date = [dateFormatter dateFromString:value];
    } else if ([key isEqualToString:@"dateUpdated"]) {
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.dateFormat = @"yyyy-MM-dd'T'HH:mm:ssZ";
        self.dateUpdated = [dateFormatter dateFromString:value];
    }
}

- (NSString *)fullName
{
    if(self.firstName != nil && self.lastName != nil) {
        return [NSString stringWithFormat:@"%@ %@", self.firstName, self.lastName];
    } else if (self.firstName != nil) {
        return self.firstName;
    } else if (self.lastName != nil) {
        return self.lastName;
    } else {
        return @"";
    }
}

- (void)encodeWithCoder:(NSCoder *)encoder
{
    [encoder encodeObject:@(_recordId) forKey:@"recordId"];
    
    [encoder encodeObject:_firstName forKey:@"firstName"];
    
    [encoder encodeObject:_lastName forKey:@"lastName"];
    
    [encoder encodeObject:_phone forKey:@"phone"];
    
    [encoder encodeObject:_email forKey:@"email"];
    
    [encoder encodeObject:_image forKey:@"image"];
    
    [encoder encodeObject:@(_selected) forKey:@"selected"];
    
    [encoder encodeObject:_date forKey:@"date"];
   
}

-(id)initWithCoder:(NSCoder *)decoder
{
    self = [super init];
    
    if (self) {
        
        self.recordId = [[decoder decodeObjectForKey:@"recordId"] integerValue];
        self.firstName = [decoder decodeObjectForKey:@"firstName"];
        self.lastName = [decoder decodeObjectForKey:@"lastName"];
        self.phone = [decoder decodeObjectForKey:@"phone"];
        self.email = [decoder decodeObjectForKey:@"email"];
        self.selected = [[decoder decodeObjectForKey:@"selected"] boolValue];
        self.date = [decoder decodeObjectForKey:@"date"];
        
    }
    return  self;
}

@end
