//
//  WFBgCell.m
//  WiFiDock
//
//  Created by apple on 14-12-5.
//  Copyright (c) 2014年 cn.hualu.WiFiDock. All rights reserved.
//

#import "WFBgCell.h"

@implementation WFBgCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self) {
        UIImageView *bg = [[UIImageView alloc]init];
        self.bg = bg;
        
        UIImageView *selectedBg = [[UIImageView alloc]init];
        self.selectedBg = selectedBg;
    }
    
    return self;
}

@end
