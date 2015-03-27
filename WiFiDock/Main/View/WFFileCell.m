//
//  WFFileCell.m
//  WiFiDock
//
//  Created by apple on 14-12-5.
//  Copyright (c) 2014年 cn.hualu.WiFiDock. All rights reserved.
//

#import "WFFileCell.h"
#import "WFFile.h"

@interface WFFileCell ()

@end

@implementation WFFileCell

+ (instancetype)cellWithTableView:(UITableView *)tableView
{
    static NSString *ID = @"fileCell";
    WFFileCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    

    if (cell == nil) {
        cell = [[[NSBundle mainBundle] loadNibNamed:@"WFFileCell" owner:nil options:nil] lastObject];

    }
    
    return cell;
}

- (void)setFile:(WFFile *)file
{
    _file = file;
    
    self.iconView.image = file.icon;
    
    if ([[file.fileName pathExtension] isEqualToString:@"lock"]) {
        
        self.titleLable.text = [file.fileName stringByDeletingPathExtension];
        
    }else{
    
        self.titleLable.text = file.fileName;
    }
    
    
    
    self.subtitleLable.text = file.createData;
    
    NSString *fileSize = [self stringForAllFileSize:[file.fileSize longLongValue]];
    
    self.sizeLable.text = fileSize;
    
    self.accessoryView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"CellArrow"]];
 
}



- (NSString *) stringForAllFileSize:(UInt64)fileSize
{
   
    if (!fileSize) return nil;
    if (fileSize < 1024) {
        return [NSString stringWithFormat:@"%lldB",fileSize];
    }else if (fileSize < 1024 * 1024){
        return [NSString stringWithFormat:@"%lldk",fileSize/1024];
    }else if (fileSize < 1024 * 1024 *1024){
        return [NSString stringWithFormat:@"%lld.%2lldM",fileSize/(1024*1024),fileSize%(1024*1024)/(1024*1024)];
    }else {
        
        
        return [NSString stringWithFormat:@"%.2fG",
                fileSize*1.00/(1024*1024*1024)];
    }
    return nil;
}



@end
