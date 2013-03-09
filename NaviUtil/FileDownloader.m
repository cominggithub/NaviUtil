//
//  FileDownloader.m
//  GoogleDirection
//
//  Created by Coming on 12/12/27.
//  Copyright (c) 2012年 Coming. All rights reserved.
//

#import "FileDownloader.h"


@implementation FileDownloader
@synthesize delegate=_delegate;
@synthesize downloadId=_downloadId;
@synthesize fileName=_fileName;
@synthesize url=_url;
@synthesize retryCount=_retryCount;


-(id) init
{
    self = [super init];

    if(self)
    {
        self.delegate   = nil;
        self.downloadId = -1;
        self.fileName   = @"";
        self.url        = @"";
        self.retryCount = 0;
    }
    
    return self;
    
}
-(void)download:(DownloadRequest*)downloadRequest delegate:(id<FileDownloaderDelegate>)delegate;
{

    self.delegate = delegate;
    
    self.fileName = [[NSString alloc] initWithString:downloadRequest.fileName];
    self.url = [[NSString alloc] initWithString:downloadRequest.url];
    self.downloadId = downloadRequest.downloadId;
    
    urlRequest = [NSMutableURLRequest requestWithURL:
                  [NSURL URLWithString:[self.url stringByAddingPercentEscapesUsingEncoding: NSUTF8StringEncoding]] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0];
    
    NSLog(@"FileDownload %lu starts to download %@ from %@\n", self.downloadId, self.fileName, self.url);
    
}

- (void) start
{
    [self deleteFile];
    [self createFile];
    self.retryCount++;
    [NSURLConnection connectionWithRequest:urlRequest delegate:self];
}

- (void) createFile
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if(![fileManager fileExistsAtPath:self.fileName]) {
        [fileManager createFileAtPath:self.fileName contents:nil attributes:nil];
    }
    else
    {
        [fileManager removeItemAtPath:self.fileName error:nil];
        [fileManager createFileAtPath:self.fileName contents:nil attributes:nil];
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    NSFileHandle *fileHandle = [NSFileHandle fileHandleForUpdatingAtPath:self.fileName];
    [fileHandle seekToEndOfFile];
    [fileHandle writeData:data];
    [fileHandle closeFile];
    NSLog(@"FileDownloader %lu recv data length %u", self.downloadId, [data length]);
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    NSLog(@"FileDownloader %lu didFailWithError %@\n", self.downloadId, error);
    
    if(self.delegate != nil && [self.delegate respondsToSelector:@selector(downloadFail:)])
        [self.delegate downloadFail: self];
    [self deleteFile];
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSHTTPURLResponse *)response
{
    NSLog(@"FileDownloader %lu didReceiveResponse\n", self.downloadId);
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    NSLog(@"FileDownloader %lu finish download\n", self.downloadId);
    
    if(self.delegate != nil && [self.delegate respondsToSelector:@selector(finishDownload:)])
    {
        
        [self.delegate downloadFinish: self];
    }
}

-(void)deleteFile
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    if([fileManager fileExistsAtPath:self.fileName]) {
        [fileManager removeItemAtPath:self.fileName error:nil];
    }
}
@end
