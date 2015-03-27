//
//  HttpSambaFileResponse.m
//  IGL004
//
//  Created by apple on 2014/02/14.
//  Copyright (c) 2014年 hualu. All rights reserved.
//

#import "HttpSambaFileResponse.h"
#import "HTTPConnection.h"
#define NULL_FD  -1

@implementation HttpSambaFileResponse

- (id)initWithFile:(IGLSMBItemFile *)file forConnection:(HTTPConnection *)parent
{
	if((self = [super init]))
	{
        _file = file;
        filePath = file.path;
		connection = parent;
        fileLength = (UInt64)file.stat.size;
		fileOffset = 0;
		aborted = NO;
	}
	return self;
}

- (void)abort
{
	[connection responseDidAbort:self];
	aborted = YES;
    if(_file){
        [_file close];
        _file = nil;
    }
    _file = [[IGLSMBProvier sharedSmbProvider] fetchAtPath:filePath];
}
- (UInt64)contentLength
{
	return fileLength;
}

- (UInt64)offset
{
	return fileOffset;
}

- (BOOL)openFile
{
	fileFD = open([filePath UTF8String], O_RDONLY);
	if (fileFD == NULL_FD)
	{
		[self abort];
		return NO;
	}
	return YES;
}

- (BOOL)openFileIfNeeded
{
	if (aborted)
	{
		return NO;
	}
	
	if (!_file)
	{
		return YES;
	}
	
	return [self openFile];
}

- (void)setOffset:(UInt64)offset
{

//    if (![self openFileIfNeeded])
//	{
//		// File opening failed,
//		// or response has been aborted due to another error.
//		return;
//	}
    
    fileOffset = offset;
    id result = [_file seekToFileOffset:offset whence:0];
	if ([result isKindOfClass:[NSError class]])
	{
		[self abort];
	}
}

- (NSData *)readDataOfLength:(NSUInteger)length
{
//    if (![self openFileIfNeeded])
//	{
//		// File opening failed,
//		// or response has been aborted due to another error.
//		return;
//	}
		
	UInt64 bytesLeftInFile = fileLength - fileOffset;
	
	NSUInteger bytesToRead = (NSUInteger)MIN(length, bytesLeftInFile);
	
    id result = [_file readDataOfLength:bytesToRead];
    if ([result isKindOfClass:[NSError class]])
	{
		[self abort];
        return nil;
	}
    NSData *data = result;
    fileOffset +=data.length;
    return data;
    
	// Make sure buffer is big enough for read request.
	// Do not over-allocate.
	
//	if (buffer == NULL || bufferSize < bytesToRead)
//	{
//		bufferSize = bytesToRead;
//		buffer = reallocf(buffer, (size_t)bufferSize);
//		
//		if (buffer == NULL)
//		{
//			[self abort];
//			return nil;
//		}
//	}
//	
//	// Perform the read
//	
//	HTTPLogVerbose(@"%@[%p]: Attempting to read %lu bytes from file", THIS_FILE, self, (unsigned long)bytesToRead);
//	
//	ssize_t result = read(fileFD, buffer, bytesToRead);
//	
//	// Check the results
//	
//	if (result < 0)
//	{
//		HTTPLogError(@"%@: Error(%i) reading file(%@)", THIS_FILE, errno, filePath);
//		
//		[self abort];
//		return nil;
//	}
//	else if (result == 0)
//	{
//		//HTTPLogError(@"%@: Read EOF on file(%@)", THIS_FILE, filePath);
//		
//		[self abort];
//		return nil;
//	}
//	else // (result > 0)
//	{
//		HTTPLogVerbose(@"%@[%p]: Read %ld bytes from file", THIS_FILE, self, (long)result);
//		
//		fileOffset += result;
//		
//		return [NSData dataWithBytes:buffer length:result];
//	}
}

- (BOOL)isDone
{
	BOOL result = (fileOffset == fileLength);
	return result;
}

- (NSString *)filePath
{
	return filePath;
}

- (void)dealloc
{
	if (_file)
	{
		[_file close];
	}
	if (buffer)
		free(buffer);
	
}
@end
