//
//  DownloadRequest.h
//  NavUtil
//
//  Created by Coming on 13/2/26.
//  Copyright (c) 2013年 Coming. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>


@class DownloadRequest;

typedef enum DownloadMode
{
    kDownloadMode_Immediately,
    kDlownloadMode_LocationUrgent,
    kDownloadMode_Urgent,
    kDownloadMode_Normal
    
}DownloadMode;

typedef enum DownloadStatus
{
    kDownloadStatus_Pending,
    kDownloadStatus_Downloading,
    kDownloadStatus_Finished,
    kDownloadStatus_DownloadFail,
    kDownloadStatus_DownloadCancelled,
    
}DownloadStatus;


@protocol DownloadRequestDelegate <NSObject>
-(void) downloadRequest:(DownloadRequest*) downloadRequest status:(DownloadStatus) status;
@end

@interface DownloadRequest : NSObject
{
    
}

@property (nonatomic) int requestId;
@property (nonatomic) int downloadId;
@property (nonatomic, strong) NSString* name;
@property (nonatomic, strong) NSString* url;
@property (nonatomic, strong) NSString* fileName;
@property (nonatomic, strong) NSString* filePath;
@property (nonatomic) DownloadStatus status;
@property (nonatomic) DownloadMode mode;
@property (nonatomic) CLLocationCoordinate2D coordinate;
@property (nonatomic, weak) id<DownloadRequestDelegate> delegate;
@property (nonatomic, readonly) BOOL done;

- (NSComparisonResult)compare:(DownloadRequest *) o;
//    NSOrderedAscending = -1L, NSOrderedSame, NSOrderedDescending

@end
