//
//  SystemManager.m
//  NavUtil
//
//  Created by Coming on 13/2/27.
//  Copyright (c) 2013年 Coming. All rights reserved.
//

#import "SystemManager.h"
#import "NaviQueryManager.h"
#import <mach/mach.h>

#define FILE_DEBUG FALSE
#include "Log.h"


static bool isInit = false;
static NSString *_documentPath=@"";
static NSString *_tmpPath=@"";
static NSString *_routeFilePath=@"";
static NSString *_placeFilePath=@"";
static NSString *_speechFilePath=@"";
static NSString *_logFilePath=@"";
static NSString *_userFilePath=@"";
static NSString *_defaultLanguage=@"zh-TW";
static NSDictionary *_supportedLanguage;
static CLLocationCoordinate2D _defaultLocation;
static CGRect _screenRect;
static CGRect _lanscapeScreenRect;


@implementation SystemManager


+(void) init
{
    mlogCheckPoint(@"SystemManager Init");
    [self initSupportedLanguage];
    [self initDirectory];
    [self initOS];

    isInit = true;
}
+(void) initOS
{
    UIDevice* device = [UIDevice currentDevice];
    CGRect screenBounds = [[UIScreen mainScreen] bounds];
    CGFloat screenScale = [[UIScreen mainScreen] scale];
//    CGSize screenSize = CGSizeMake(screenBounds.size.width * screenScale, screenBounds.size.height * screenScale);

    mlogInfo(@"%@: %@",
             [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleName"],
             [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"]);
    
    mlogInfo(@"localizedModel: %@", device.localizedModel);
    mlogInfo(@"model: %@", device.model);
    mlogInfo(@"name: %@", device.name);
    mlogInfo(@"systemName: %@", device.systemName);
    
    mlogInfo(@"orientation: %d", device.orientation);
    mlogInfo(@"systemVersion: %@", device.systemVersion);
    mlogInfo(@"userInterfaceIdiom: %d", device.userInterfaceIdiom);
    

    
    mlogInfo(@"screen %.0f X %.0f %s", screenBounds.size.width, screenBounds.size.height, screenScale > 1.0 ? "Retina":"");
    
    _screenRect                         = screenBounds;
    _lanscapeScreenRect.origin.x        = 0;
    _lanscapeScreenRect.origin.y        = 0;
    _lanscapeScreenRect.size.width      = _screenRect.size.height;
    _lanscapeScreenRect.size.height     = _screenRect.size.width;
    
    Reachability* networkStatus = [Reachability reachabilityWithHostName:@"tw.yahoo.com"];
    NetworkStatus netStatus = [networkStatus currentReachabilityStatus];
    BOOL connectionRequired= [networkStatus connectionRequired];
    NSString* statusString= @"";
    switch (netStatus)
    {
        case NotReachable:
        {
            statusString = @"Access Not Available";
            //Minor interface detail- connectionRequired may return yes, even when the host is unreachable.  We cover that up here...
            connectionRequired= NO;
            break;
        }
            
        case ReachableViaWWAN:
        {
            statusString = @"Reachable WWAN";
            break;
        }
        case ReachableViaWiFi:
        {
            statusString= @"Reachable WiFi";
            break;
        }
    }
    if(connectionRequired)
    {
        statusString= [NSString stringWithFormat: @"%@, Connection Required", statusString];
    }

}
+(void) initSupportedLanguage
{
    _supportedLanguage = [[NSDictionary alloc] initWithObjectsAndKeys:
                          @"TRUE", @"en-US",
                          @"TRUE", @"zh-TW",
                          nil
                          ];
}

+(void) initDirectory
{
    NSDateFormatter *dateFormattor = [[NSDateFormatter alloc] init];
    NSFileManager *filemanager;
    NSString *currentPath;
    
    [dateFormattor setDateFormat:@"HHMM"];
    filemanager =[NSFileManager defaultManager];
    currentPath = [filemanager currentDirectoryPath];
    
    NSArray *dirPaths;
    
    
    dirPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    _tmpPath = NSTemporaryDirectory();
    
    _documentPath   = [dirPaths objectAtIndex:0];
    _placeFilePath  = [NSString stringWithFormat:@"%@place", _tmpPath];
    _routeFilePath  = [NSString stringWithFormat:@"%@route", _tmpPath];
    _speechFilePath = [NSString stringWithFormat:@"%@speech", _tmpPath];
    _userFilePath   = [NSString stringWithFormat:@"%@/user.json", _documentPath];
    _logFilePath    = [NSString stringWithFormat:@"%@log.txt", _tmpPath];
    
    for(NSString *path in dirPaths)
    {
        printf("%s\n", [path UTF8String]);
    }
    
    [self cleanDirectory:_tmpPath];
    [self makeDirectory:[self placeFilePath]];
    [self makeDirectory:[self routeFilePath]];
    [self makeDirectory:[self speechFilePath]];
  
    mlogInfo(@"   Document Path: %@", [self documentPath]);
    mlogInfo(@" Place File Path: %@", [self placeFilePath]);
    mlogInfo(@" Route File Path: %@", [self routeFilePath]);
    mlogInfo(@"Speech File Path: %@", [self speechFilePath]);
    mlogInfo(@"  User File Path: %@", [self userFilePath]);
    mlogInfo(@"   Log File Path: %@", [self logFilePath]);
    

}

+(NSString*) documentPath
{
    return _documentPath;
}

+(NSString*) tmpPath
{
    return _tmpPath;
    
}
+(NSString*) placeFilePath
{
    return _placeFilePath;
}

+(NSString*) routeFilePath
{
    return _routeFilePath;
}

+(NSString*) speechFilePath
{
    return _speechFilePath;
}

+(NSString *) logFilePath
{
    return _logFilePath;
}

+(NSString *) userFilePath
{
    return _userFilePath;
}

+(CGRect) screenRect;
{
    return _screenRect;
}

+(CGRect) lanscapeScreenRect;
{
    return _lanscapeScreenRect;
}

+(void) cleanDirectory:(NSString*) path
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    if([fileManager fileExistsAtPath:path]) {
        [fileManager removeItemAtPath:path error:nil];
    }


}

+(void) makeDirectory:(NSString*) path
{
    [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:NULL];

}

+(NSString *) getSystemLanguage
{
    return [[NSLocale preferredLanguages] objectAtIndex:0];
}

+(NSString *) getSupportLanguage
{
    NSString *sysLanguage = [self getSystemLanguage];
    if ([self isLanguageSupported:sysLanguage] == true)
    {
        return sysLanguage;
    }
    
    return [self getDefaultLanguage];
}

+(NSString *) getDefaultLanguage;
{
    return _defaultLanguage;
}

+(bool) isLanguageSupported:(NSString*) language
{
    if([_supportedLanguage.allKeys containsObject:language] == true)
        return true;
    return false;
}

+(CLLocationCoordinate2D) getDefaultLocation
{
    return _defaultLocation;
}


+(NSString*) getUsedMemoryStr
{
    struct task_basic_info info;
    mach_msg_type_number_t size = sizeof(info);
    kern_return_t kerr = task_info(mach_task_self(),
                                   TASK_BASIC_INFO,
                                   (task_info_t)&info,
                                   &size);

    NSString *result = @"";
    if( kerr == KERN_SUCCESS ) {
        if(info.resident_size < 1024)
        {
            result = [NSString stringWithFormat:@"%d Bytes", info.resident_size];
        }
        else if(info.resident_size < 1024*1024)
        {
            result = [NSString stringWithFormat:@"%d KB", (int)info.resident_size/1024];
        }
        else
        {
            result = [NSString stringWithFormat:@"%.2f MB", info.resident_size/(1024.0*1024.0)];
        }
    }
    
    return result;
}

+(NSString *) getLanguageString:(NSString*) stringIndex
{
    return stringIndex;
}

@end


