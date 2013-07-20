//
//  FileDownloader.m
//  GoogleDirection
//
//  Created by Coming on 12/12/27.
//  Copyright (c) 2012年 Coming. All rights reserved.
//


#import "FileDownloader.h"

#define FILE_DEBUG FALSE
#include "Log.h"

@implementation FileDownloader
@synthesize delegate=_delegate;
@synthesize downloadId=_downloadId;
@synthesize filePath=_filePath;
@synthesize url=_url;
@synthesize retryCount=_retryCount;


-(id) init
{
    self = [super init];

    if(self)
    {
        self.delegate   = nil;
        self.downloadId = -1;
        self.filePath   = @"";
        self.url        = @"";
        self.retryCount = 0;
    }
    
    return self;
    
}
-(void)download:(DownloadRequest*)downloadRequest delegate:(id<FileDownloaderDelegate>)delegate;
{

    self.delegate = delegate;
    
    self.filePath = [[NSString alloc] initWithString:downloadRequest.filePath];
    self.url = [[NSString alloc] initWithString:downloadRequest.url];
    self.downloadId = downloadRequest.downloadId;
    
    urlRequest = [NSMutableURLRequest requestWithURL:
                  [NSURL URLWithString:[self.url stringByAddingPercentEscapesUsingEncoding: NSUTF8StringEncoding]] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0];
    

    
}

- (void) start
{
    [self deleteFile];
    [self createFile];
    self.retryCount++;
    mlogDebug(@"%lu starts to download %@ from %@\n", self.downloadId, self.filePath, self.url);
    [NSURLConnection connectionWithRequest:urlRequest delegate:self];
}

- (void) createFile
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if(![fileManager fileExistsAtPath:self.filePath]) {
        [fileManager createFileAtPath:self.filePath contents:nil attributes:nil];
    }
    else
    {
        [fileManager removeItemAtPath:self.filePath error:nil];
        [fileManager createFileAtPath:self.filePath contents:nil attributes:nil];
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    NSFileHandle *fileHandle = [NSFileHandle fileHandleForUpdatingAtPath:self.filePath];
    [fileHandle seekToEndOfFile];
    [fileHandle writeData:data];
    [fileHandle closeFile];
    mlogDebug(@"%lu recv data length %u", self.downloadId, [data length]);
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    mlogInfo(@"%lu didFailWithError %@\n", self.downloadId, error);
    
    if(self.delegate != nil && [self.delegate respondsToSelector:@selector(downloadFail:)])
        [self.delegate downloadFail: self];
    [self deleteFile];
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSHTTPURLResponse *)response
{
    mlogDebug(@"%lu didReceiveResponse\n", self.downloadId);
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    mlogDebug(@"FileDownloader %lu finish download\n", self.downloadId);
    
    if(self.delegate != nil && [self.delegate respondsToSelector:@selector(downloadFinish:)])
    {
        [self.delegate downloadFinish: self];
    }
    
}

-(void)deleteFile
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    if([fileManager fileExistsAtPath:self.filePath]) {
        [fileManager removeItemAtPath:self.filePath error:nil];
    }
}
@end
