//
//  WFItemFrame.m
//  WiFiDock
//
//  Created by apple on 14-12-29.
//  Copyright (c) 2014年 cn.hualu.WiFiDock. All rights reserved.
//

#import "WFItemFrame.h"
#import "WFFile.h"
#define WFItemCellBorder 10;
#define WFTitleLableH 25;
#define WFItemCellH 70

@implementation WFItemFrame

- (void)setFile:(WFFile *)file
{
    _file = file;
    
    CGFloat cellW = [UIScreen mainScreen].bounds.size.width;
    CGFloat cellH = WFItemCellH;
    
    CGFloat iconViewWH = 50;
    CGFloat iconViewX = WFItemCellBorder;
    CGFloat iconViewY = WFItemCellBorder;
    _iconViewF = CGRectMake(iconViewX, iconViewY, iconViewWH, iconViewWH);
    
    CGFloat titleLableX = CGRectGetMaxX(_iconViewF) + WFItemCellBorder;
    CGFloat titleLableY = CGRectGetMaxY(_iconViewF);
    CGFloat titleLableH = iconViewWH * 0.5;
    CGFloat titleLableW = cellW - titleLableX;
    
    _titleLableF = CGRectMake(titleLableX, titleLableY, titleLableW, titleLableH);
    
    CGFloat subtitleLableX = CGRectGetMaxX(_iconViewF) + WFItemCellBorder;
    CGFloat subtitleLableY = CGRectGetMaxY(_titleLableF);
    CGFloat subtitleLableH = iconViewWH * 0.5;
    CGFloat subtitleLableW = (cellW - subtitleLableX) * 0.5;
    
    _subtitleLableF = CGRectMake(subtitleLableX, subtitleLableY, subtitleLableW, subtitleLableH);
    
    CGFloat sizeLableX = CGRectGetMaxX(_subtitleLableF)+ 2 * WFItemCellBorder;
    CGFloat sizeLableY = subtitleLableH;
    CGFloat sizeLableH = iconViewWH * 0.5;
    CGFloat sizeLableW = cellW * 0.2;
    
    _sizeLableF = CGRectMake(sizeLableX, sizeLableY, sizeLableW, sizeLableH);
    
}

@end
