//
//  IGLLtoLActiom.m
//  IGL004
//
//  Created by apple on 2014/05/23.
//  Copyright (c) 2014年 hualu. All rights reserved.
//

#import "IGLLtoLAction.h"
#import "WFFileUtil.h"

@implementation IGLLtoLAction
+(id)actionWithItem:(IGLActionItem*)item{
    IGLLtoLAction *manager =  [[IGLLtoLAction alloc] init];
    manager.item = item;
    return manager;
}

-(void)doCopyAction{
    _targetpath = [self buildPath];
    if(!_targetpath){
        [self runWhenFinished];
        return;
    }
    NSFileManager* manager = [NSFileManager defaultManager];
    if(self.item.isFolder){
        self.item.fileSize =[WFFileUtil folderSizeAtPath:self.item.fromPath];
        if([IGLActionUtils freeDiskSpaceInBytes] <= (self.item.fileSize+1024*1024)){
            _iscancel = YES;
            [self runWhenFinished];
            return;
        }
        BOOL success = [manager createDirectoryAtPath:_targetpath withIntermediateDirectories:YES attributes:nil error:nil];
        if(!success){
            [self runWhenFinished];
            return;
        }
        NSEnumerator *childFilesEnumerator = [[manager subpathsAtPath:self.item.fromPath] objectEnumerator];
        for (NSString *fileName in [childFilesEnumerator allObjects]){
            NSString* srcPath = [self.item.fromPath stringByAppendingPathComponent:fileName];
            NSString* tarPath = [_targetpath stringByAppendingPathComponent:fileName];
            if([WFFileUtil isFolder:srcPath]){
                success=[manager createDirectoryAtPath:tarPath withIntermediateDirectories:YES attributes:nil error:nil];
            }else{
                success=[manager createFileAtPath:tarPath contents:nil attributes:nil];
                if (success) {
                    [self copyAction:srcPath to:tarPath];
                }
            }
            if(_iscancel){
                break;
            }
        }
    }else{
        self.item.fileSize =[WFFileUtil fileSizeAtPath:self.item.fromPath];
        if([IGLActionUtils freeDiskSpaceInBytes] <= (self.item.fileSize+COPYSPEED)){
            [self runWhenFinished];
            return;
        }
        BOOL success=[manager createFileAtPath:_targetpath contents:nil attributes:nil];
        if (success) {
            [self copyAction:self.item.fromPath to:_targetpath];
        }
    }
    [self runWhenFinished];
}
-(void)copyAction:(NSString*)srcPath to:(NSString*)tarPath{
    int from_fd,to_fd;
    int bytes_read,bytes_write;
    char buffer[COPY_BUFFER_SIZE_SUB];
    char *ptr;
    if((from_fd=open([srcPath cStringUsingEncoding:NSUTF8StringEncoding],O_RDONLY))==-1)
    {
        return;
    }
    if((to_fd=open([tarPath cStringUsingEncoding:NSUTF8StringEncoding],O_WRONLY|O_CREAT,S_IRUSR|S_IWUSR))==-1)
    {
        return;
    }
    
    while((bytes_read=read(from_fd,buffer,sizeof(buffer))))
    {
        if(_iscancel){
            break;
        }
        if((bytes_read==-1)&&(errno!=EINTR)) break;
        else if(bytes_read>0)
        {
            ptr=buffer;
            while((bytes_write=write(to_fd,ptr,bytes_read)))
            {
                if((bytes_write==-1)&&(errno!=EINTR))break;
                else if(bytes_write==bytes_read) break;
                else if(bytes_write>0)
                {
                    ptr+=bytes_write;
                    bytes_read-=bytes_write;
                }
            }
            if(bytes_write==-1)break;
        }
        self.item.overedSize += bytes_read;
    }
    close(from_fd);
    close(to_fd);
}
@end
