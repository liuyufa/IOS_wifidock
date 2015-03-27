//
//  HttpSambaFileResponse.h
//  IGL004
//
//  Created by apple on 2014/02/14.
//  Copyright (c) 2014年 hualu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IGLSMBProvier.h"
#import "HTTPResponse.h"
@class HTTPConnection;

@interface HttpSambaFileResponse : NSObject<HTTPResponse>{
    IGLSMBItemFile *_file;
    HTTPConnection *connection;
	NSString *filePath;
	UInt64 fileLength;
	UInt64 fileOffset;
    
    BOOL aborted;
	
	int fileFD;
    
    void *buffer;
	NSUInteger bufferSize;
}

- (id)initWithFile:(IGLSMBItemFile *)file forConnection:(HTTPConnection *)parent;
- (NSString *)filePath;

@end