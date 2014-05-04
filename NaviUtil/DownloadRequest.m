//
//  DownloadRequest.m
//  NavUtil
//
//  Created by Coming on 13/2/26.
//  Copyright (c) 2013年 Coming. All rights reserved.
//

#import "DownloadRequest.h"
#import "DownloadManager.h"

#define FILE_DEBUG FALSE
#include "Log.h"

@implementation DownloadRequest

@synthesize requestId=_requestId;
@synthesize downloadId=_downloadId;
@synthesize url=_url;
@synthesize fileName=_fileName;
@synthesize status=_status;
@synthesize mode=_mode;
@synthesize coordinate=_coordinate;
@synthesize name=_name;

-(id) init
{
    self = [super init];
    if(self)
    {
        self.downloadId     = 0;
        self.name           = @"";
        self.url            = @"";
        self.fileName       = @"";
        self.filePath       = @"";
        self.status         = kDownloadStatus_Pending;
        self.mode           = kDownloadMode_Normal;
    }
    
    return self;
}

- (NSComparisonResult)compare:(DownloadRequest *) o
{
    return NSOrderedSame;
}


-(NSString *) description {
    
    return [NSString stringWithFormat:@"DownloadId: %d, status: %@\n %@ %@ %@", self.downloadId, self.getStatusStr, self.url, self.fileName, self.filePath];
}

-(NSString*) getStatusStr
{
    NSString *result = nil;
    switch (self.status)
    {
        case kDownloadStatus_DownloadFail:
            result = @"Fail";
            break;
        case kDownloadStatus_Downloading:
            result = @"Downloading";
            break;
        case kDownloadStatus_Finished:
            result = @"Finished";
            break;
        case kDownloadStatus_Pending:
            result = @"Pending";
            break;
        case kDownloadStatus_DownloadCancelled:
            result = @"Cancelled";
            break;
        default:
            result = @"Unknown";
            break;
    }
    
    return result;
}

-(void) setStatus:(DownloadStatus)status
{
    _status = status;
    if (self.delegate != NULL)
    {
        if (nil != self.delegate && [self.delegate respondsToSelector:@selector(downloadRequest:status:)])
        {
            [self.delegate downloadRequest:self status:self.status];
        }
    }
}
-(BOOL) done
{
    if (self.status == kDownloadStatus_Finished || self.status == kDownloadStatus_DownloadFail || self.status == kDownloadStatus_DownloadCancelled)
        return TRUE;
    
    return FALSE;
}

-(void) start
{
    
}
@end
