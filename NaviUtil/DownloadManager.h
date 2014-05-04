//
//  DownloadManager.h
//  NavUtil
//
//  Created by Coming on 13/2/26.
//  Copyright (c) 2013年 Coming. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FileDownloader.h"
#import "DownloadRequest.h"
#import "SystemManager.h"
#import <CoreLocation/CoreLocation.h>
#import "NaviQueryManager.h"

enum FileType {
    FILE_TYPE_ROUTE,
    FILE_TYPE_PLACE,
    FILE_TYPE_SPEECH,
    FILE_TYPE_MAX
    
};

@interface DownloadManager : NSObject<FileDownloaderDelegate>

@property (nonatomic) int activeDownload;
@property (nonatomic) int currentDownloadId;
@property (nonatomic) int maxDownload;
@property (nonatomic) int maxRetryCount;
@property (nonatomic, strong) NSMutableArray* downloadingQueue;
@property (nonatomic, strong) NSMutableArray* pendingQueue;
@property (nonatomic, strong) NSMutableArray* finishedQueue;
@property (nonatomic) CLLocationCoordinate2D currentLocation;



-(void) downloadFinish: (FileDownloader*) fileDownloader;
-(void) downloadFail: (FileDownloader*) fileDownloader;
-(void) download:(DownloadRequest*) downloadRequest;
-(void) cancelPendingDownload;


@end
