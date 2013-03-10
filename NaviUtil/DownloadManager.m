//
//  DownloadManager.m
//  NavUtil
//
//  Created by Coming on 13/2/26.
//  Copyright (c) 2013年 Coming. All rights reserved.
//

#import "DownloadManager.h"
#import "FileDownloader.h"

@implementation DownloadManager

@synthesize activeDownload=_activeDownload;
@synthesize currentDownloadId=_currentDownloadId;
@synthesize maxDownload=_maxDownload;
@synthesize maxRetryCount=_maxRetryCount;
@synthesize downloadingQueue=_downloadingQueue;
@synthesize pendingQueue=_pendingingQueue;
@synthesize finishedQueue=_finishedQueue;


-(id) init
{
    self = [super init];
    if(self)
    {
        self.activeDownload     = 0;
        self.maxDownload        = 1;
        self.maxRetryCount      = 3;
        self.currentDownloadId  = 1;
        self.currentLocation    = [SystemManager getDefaultLocation];
        self.downloadingQueue   = [[NSMutableArray alloc] initWithCapacity:0];
        self.pendingQueue       = [[NSMutableArray alloc] initWithCapacity:0];
        self.finishedQueue      = [[NSMutableArray alloc] initWithCapacity:0];
        self.logLevel           = kLogInfo;

    }
    
    return self;
}

-(void) startDownload
{
    
    
}

-(void) stopDownload
{
    
}

-(void) downloadFinish: (FileDownloader*) fileDownloader
{
    DownloadRequest *downloadRequest = [self getDownloadRequest:fileDownloader.downloadId];
    downloadRequest.status = kDownloadStatus_Finished;

    [self.downloadingQueue removeObject:downloadRequest];
    [self.finishedQueue addObject:downloadRequest];

    if(self.logLevel <= kLogInfo)
        logInfo(@"%@\n", self);

    [self triggerDownload];
    [NaviQueryManager downloadRequestStatusChange:downloadRequest];
    
    

}

-(void) downloadFail: (FileDownloader*) fileDownloader
{
    DownloadRequest *downloadRequest;
    if(fileDownloader.retryCount <= self.maxRetryCount)
        [fileDownloader start];
    else
    {
        downloadRequest         = [self getDownloadRequest:fileDownloader.downloadId];
        downloadRequest.status  = kDownloadStatus_DownloadFail;
        
        [self.downloadingQueue removeObject:downloadRequest];
        [self.pendingQueue addObject:downloadRequest];
        [downloadRequest.delegate statusChange:downloadRequest];

        if(self.logLevel <= kLogInfo)
            logInfo(@"%@\n", downloadRequest);
        
        [self triggerDownload];
    }

    if(self.logLevel <= kLogInfo)
        logInfo(@"%@\n", self);
}

-(void) download:(DownloadRequest*) downloadRequest
{

    downloadRequest.downloadId = [self getNextDownloadId];
    [self.pendingQueue addObject:downloadRequest];

    if(self.logLevel <= kLogInfo)
        logInfo(@"%@\n", self);
    
    [self triggerDownload];
}

-(void) triggerDownload
{
    DownloadRequest *r;
    if(self.pendingQueue.count > 0 && self.downloadingQueue.count < self.maxDownload)
    {
        r = [self.pendingQueue objectAtIndex:0];
        [self.pendingQueue removeObjectAtIndex:0];
        [self.downloadingQueue addObject:r];
        [self startDownload:r];
        
        if(self.logLevel <= kLogInfo)
            logInfo(@"t %@\n", self);
    }
}

-(int) getNextDownloadId
{
    return self.currentDownloadId++;
}

-(void) startDownload:(DownloadRequest*) downloadRequest
{
    FileDownloader* fileDownloader  = [[FileDownloader alloc] init];

    downloadRequest.status          = kDownloadStatus_Downloading;
    [downloadRequest.delegate statusChange:downloadRequest];
    [fileDownloader download:downloadRequest delegate:self];
    [fileDownloader start];

    if(self.logLevel <= kLogInfo)
        logInfo(@"%@", downloadRequest);
}

-(DownloadRequest*) getDownloadRequest:(int)downloadId
{

    for(DownloadRequest *r in self.downloadingQueue)
    {
       if(r.downloadId == downloadId)
           return r;
    }

    for(DownloadRequest *r in self.finishedQueue)
    {
        if(r.downloadId == downloadId)
            return r;
    }
    
    for(DownloadRequest *r in self.pendingQueue)
    {
        if(r.downloadId == downloadId)
            return r;
    }

    return nil;
}

-(NSString*) description
{
    NSMutableString* result = [[NSMutableString alloc] init];
    
    [result appendString:@"[Download Manager] "];

    
    [result appendString:@"Pending: "];
    for(DownloadRequest *r in self.pendingQueue)
    {
        [result appendFormat:@"%d,", r.downloadId];
    }
    
    [result appendString:@"Downloading: "];
    for(DownloadRequest *r in self.downloadingQueue)
    {
        [result appendFormat:@"%d,", r.downloadId];
    }

    [result appendString:@"Finished: "];
    for(DownloadRequest *r in self.finishedQueue)
    {
        [result appendFormat:@"%d,", r.downloadId];
    }

    return result;
}

@end
