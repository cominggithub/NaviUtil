//
//  FileDownloader.h
//  GoogleDirection
//
//  Created by Coming on 12/12/27.
//  Copyright (c) 2012年 Coming. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Foundation/NSFileManager.h>
#import "DownloadRequest.h"
#import "Log.h"
#import "SystemManager.h"

@class FileDownloader;

@protocol FileDownloaderDelegate <NSObject>
-(void) downloadFinish: (FileDownloader*) fileDownloader;
-(void) downloadFail: (FileDownloader*) fileDownloader;
@end


@interface FileDownloader : NSObject<NSURLConnectionDelegate>
{
    NSMutableURLRequest *urlRequest;
}

@property (nonatomic, weak) id<FileDownloaderDelegate> delegate;
@property (nonatomic) unsigned long downloadId;
@property (nonatomic, strong) NSString *filePath;
@property (nonatomic, strong) NSString *url;
@property (nonatomic) int retryCount;


-(void) download:(DownloadRequest*)downloadRequest delegate:(id<FileDownloaderDelegate>)delegate;
-(void) start;
-(void) deleteFile;
@end
