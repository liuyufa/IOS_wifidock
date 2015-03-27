//
//  FileUtil_C.c
//  IGL004
//
//  Created by apple on 2014/02/27.
//  Copyright (c) 2014年 hualu. All rights reserved.
//

#include <stdio.h>
#include "sys/stat.h"
#include "FileUtil_C.h"

long long fileSizeAtPath(const char * path){
    struct stat st;
    if(lstat(path, &st) == 0){
        remove(path);
        return st.st_size;
    }
    return 0;
}