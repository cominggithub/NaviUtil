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
@synthesize currentLocation=_currentLocation;
@synthesize waitingQueue=_waitingQueue;
@synthesize finishedQueue=_finishedQueue;


-(id) init
{
    self = [super init];
    if(self)
    {
        self.activeDownload     = 0;
        self.maxDownload        = 10;
        self.maxRetryCount      = 3;
        self.currentDownloadId  = 1;
        self.currentLocation    = [SystemManager getDefaultLocation];
        self.downloadingQueue   = [[NSMutableArray alloc] initWithCapacity:0];
        self.waitingQueue       = [[NSMutableArray alloc] initWithCapacity:0];
        self.finishedQueue      = [[NSMutableArray alloc] initWithCapacity:0];
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
    [downloadRequest.delegate statusChange:downloadRequest];
    [self.downloadingQueue removeObject:downloadRequest];
    [self.finishedQueue addObject:downloadRequest];
    [self triggerDownload];
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
        [self.waitingQueue addObject:downloadRequest];
        [downloadRequest.delegate statusChange:downloadRequest];
    }
}

-(void) download:(DownloadRequest*) downloadRequest
{
    [self.downloadingQueue addObject:downloadRequest];
    [self triggerDownload];
}

-(void) triggerDownload
{
    DownloadRequest *r;
    if(self.downloadingQueue.count > 0)
    {
        r = [self.downloadingQueue objectAtIndex:0];
        [self startDownload:r];
    }
    
}

-(int) getNextDownloadId
{
    
    return self.currentDownloadId++;
}

-(void) startDownload:(DownloadRequest*) downloadRequest
{
    FileDownloader* fileDownloader  = [[FileDownloader alloc] init];
    
    downloadRequest.downloadId      = [self getNextDownloadId];
    downloadRequest.status          = kDownloadStatus_Downloading;
    [downloadRequest.delegate statusChange:downloadRequest];
    [fileDownloader download:downloadRequest delegate:self];

    
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
    
    for(DownloadRequest *r in self.waitingQueue)
    {
        if(r.downloadId == downloadId)
            return r;
    }

    return nil;
}

@end
