//
//  WFToAction.m
//  WiFiDock
//
//  Created by apple on 15-1-7.
//  Copyright (c) 2015年 cn.hualu.WiFiDock. All rights reserved.
//

#import "WFLToLAction.h"


@implementation WFLToLAction
+(instancetype)actionWithItem:(WFAction*)item
{
    return [[WFLToLAction alloc]initWithItem:item];
}

- (instancetype)initWithItem:(WFAction*)item
{
    self = [super init];
    if (self) {
        
        self.item = item;
        
    }
    return self;
}

-(void)doCopyAction
{
    self.targetpath = [self buildPath];
    if (!self.targetpath) {
        
        [self runWhenFinished];
        return;
    }
    
    NSFileManager *manager = [NSFileManager defaultManager];
    
    if (self.item.isFolder) {
        self.item.fileSize = [WFFileUtil folderSizeAtPath:self.item.from];
        if ([WFActionTool freeDiskSpaceInBytes] <= (self.item.fileSize + 1024*1024)) {
            self.iscancel = YES;
            [self runWhenFinished];
            return;
        }
        
        BOOL result = [manager createDirectoryAtPath:self.targetpath withIntermediateDirectories:YES attributes:nil error:nil];
        if(!result){
            [self runWhenFinished];
            return;
        }
        
        NSEnumerator *filesEnumerator = [[manager subpathsAtPath:self.item.from] objectEnumerator];
        for (NSString *fileName in [filesEnumerator allObjects]) {
            NSString* source = [self.item.from stringByAppendingPathComponent:fileName];
            NSString* dest = [self.targetpath stringByAppendingPathComponent:fileName];
            
            if ([WFFileUtil isFolder:source]) {
                result = [manager createDirectoryAtPath:dest withIntermediateDirectories:YES attributes:nil error:nil];
                
            }else{
                
                result=[manager createFileAtPath:dest contents:nil attributes:nil];
                if (result) {
                    [self copyAction:source to:dest];
                }
            }
            
            if (self.iscancel) {
                break;
            }
        }
        
        
    }else{
        self.item.fileSize =[WFFileUtil fileSizeAtPath:self.item.from];
        if([WFActionTool freeDiskSpaceInBytes] <= (self.item.fileSize+COPYSPEED)){
            [self runWhenFinished];
            return;
        }
        
        BOOL result=[manager createFileAtPath:self.targetpath contents:nil attributes:nil];
        if (result) {
            [self copyAction:self.item.from to:self.targetpath];
        }

    
    }
    
    [self runWhenFinished];
}
- (void)copyAction:(NSString *)srcpath to:(NSString *)destpath
{

   
    int from,to;
    ssize_t readoffset,writeoffset;
    char buffer[COPY_BUFFER_SIZE_SUB];
    char *ptr = NULL;
    
    if((from=open([srcpath cStringUsingEncoding:NSUTF8StringEncoding],O_RDONLY))==-1)
    {
        return;
    }

    if((to=open([destpath cStringUsingEncoding:NSUTF8StringEncoding],O_WRONLY|O_CREAT,S_IRUSR|S_IWUSR))==-1)
    {
        return;
    }
    
    while((readoffset = read(from,buffer,sizeof(buffer))))
    {
        if(self.iscancel){
            break;
        }
        if((readoffset==-1)&&(errno!=EINTR)) break;
        else if(readoffset>0)
        {
            ptr=buffer;
            while((writeoffset = write(to,ptr,readoffset)))
            {
                if((writeoffset==-1)&&(errno!=EINTR))break;
                else if(writeoffset==readoffset) break;
                else if(writeoffset>0){
                    ptr+=writeoffset;
                    readoffset-=writeoffset;
                }
            }
            if(writeoffset==-1)break;
        }
        self.item.overedSize += readoffset;
    }
    close(from);
    close(to);
    
}
@end
