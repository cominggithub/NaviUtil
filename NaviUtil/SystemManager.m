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
static NSString *_defaultLanguage=@"zh-TW";
static NSDictionary *_supportedLanguage;
static CLLocationCoordinate2D _defaultLocation;
static CGRect _screenRect;
static CGRect _lanscapeScreenRect;
static NSMutableArray* _pathArray;
static Reachability *_reachiability;
static NSMutableArray* _delegates;
static float _wifiStatus;
static float _threeGStatus;
static float _batteryLife;
static float _gpsStatus;
static float _networkStatus;

@implementation SystemManager


+(void) init
{
    mlogCheckPoint(@"SystemManager Init");
    _delegates = [[NSMutableArray alloc] initWithCapacity:0];
    
    [self initSupportedLanguage];
    [self initDirectory];
    [self initOS];
    [self initSystemStatus];

    isInit = true;
}

+(void) initOS
{
    UIDevice* device    = [UIDevice currentDevice];
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
    
    
    [device setBatteryMonitoringEnabled:YES];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(batteryLevelUpdate)
                                                 name:UIDeviceBatteryLevelDidChangeNotification
                                            object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateNetworkStatus:)
                                                 name:kReachabilityChangedNotification object:nil];
    
}



+(void) addDelegate: (id<SystemManagerDelegate>) delegate
{
    // Additional code
    if (NO == [_delegates containsObject:delegate])
    {
        [_delegates addObject: delegate];
    }
}

+(void) removeDelegate: (id<SystemManagerDelegate>) delegate
{
    if (YES == [_delegates containsObject:delegate])
    {
        [_delegates removeObject:delegate];
    }
}

+(void) triggerBatterStatusChangeNotify
{
    for (id<SystemManagerDelegate> delegate in _delegates)
    {
        if ([delegate respondsToSelector:@selector(batteryStatusChange:)])
        {
            [delegate batteryStatusChange:_batteryLife];
        }
    }
}

+(void) triggerNetworkChangeStatusNotify
{
    for (id<SystemManagerDelegate> delegate in _delegates)
    {
        if ([delegate respondsToSelector:@selector( networkStatusChangeWifi:threeG:)])
        {
            [delegate networkStatusChangeWifi:_wifiStatus threeG:_threeGStatus];
        }
    }
}

+(void) triggerGpsStatusChangeNotify
{
    for (id<SystemManagerDelegate> delegate in _delegates)
    {
        if ([delegate respondsToSelector:@selector(gpsStatusChange:)])
        {
            [delegate gpsStatusChange:_gpsStatus];
        }
    }
}

+(void) updateNetworkStatus:(Reachability*) reachiability
{
    logfn();
    Reachability* networkStatus = _reachiability;
    NetworkStatus netStatus     = [networkStatus currentReachabilityStatus];
    BOOL connectionRequired     = [networkStatus connectionRequired];
    NSString* statusString= @"";
    switch (netStatus)
    {
        case NotReachable:
        {
            statusString = @"Access Not Available";
            //Minor interface detail- connectionRequired may return yes, even when the host is unreachable.  We cover that up here...
            connectionRequired= NO;
            _wifiStatus     = 0;
            _threeGStatus   = 0;
            _networkStatus  = 0;
            break;
        }
            
        case ReachableViaWWAN:
        {
            statusString = @"Reachable WWAN";
            _wifiStatus     = 0;
            _threeGStatus   = 1;
            _networkStatus  = 1;
            break;
        }
        case ReachableViaWiFi:
        {
            statusString= @"Reachable WiFi";
            _wifiStatus     = 1;
            _threeGStatus   = 0;
            _networkStatus  = 1;
            break;
        }
    }
    
    if(connectionRequired)
    {
        statusString= [NSString stringWithFormat: @"%@, Connection Required", statusString];
    }
    
    mlogInfo(@"%@\n", statusString);
    [self triggerNetworkChangeStatusNotify];
}

+(void) batteryLevelUpdate:(NSNotification *)notification
{
    logfn();
    _batteryLife = [[UIDevice currentDevice] batteryLevel];
    [self triggerBatterStatusChangeNotify];
}

+(float) getWifiStatus
{
    return _wifiStatus;
}

+(float) getThreeGStatus
{
    return _threeGStatus;
}

+(float) getBatteryLife
{
    return _batteryLife;
}

+(float) getGpsStatus
{
    return [CLLocationManager locationServicesEnabled] == YES ? 1:0;
}

+(float) getNetworkStatus
{
    return _networkStatus;
}

+(void) initSystemStatus
{
    _batteryLife = [[UIDevice currentDevice] batteryLevel];
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
    int i;
    NSDateFormatter *dateFormattor = [[NSDateFormatter alloc] init];
    NSFileManager *filemanager;
    NSString *currentPath;
    NSArray *dirPaths;
    NSString *tmpStr;

    
    [dateFormattor setDateFormat:@"HHMM"];

    filemanager =[NSFileManager defaultManager];
    currentPath = [filemanager currentDirectoryPath];
    

    
    
    dirPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    
    _pathArray = [NSMutableArray arrayWithCapacity:kSystemManager_Path_Max];
    for(i=0; i<kSystemManager_Path_Max; i++)
    {
        [_pathArray addObject:@""];
    }
    
    _tmpPath = NSTemporaryDirectory();
    _documentPath   = [dirPaths objectAtIndex:0];
    
    tmpStr = [NSString stringWithFormat:@"%@", _documentPath];
    [_pathArray replaceObjectAtIndex:kSystemManager_Path_Document   withObject:tmpStr];

    tmpStr = [NSString stringWithFormat:@"%@/user.json", _documentPath];
    [_pathArray replaceObjectAtIndex:kSystemManager_Path_User       withObject:tmpStr];

    tmpStr = [NSString stringWithFormat:@"%@/config.json", _documentPath];
    [_pathArray replaceObjectAtIndex:kSystemManager_Path_Config       withObject:tmpStr];
    
    tmpStr = [NSString stringWithFormat:@"%@log.txt", _tmpPath];
    [_pathArray replaceObjectAtIndex:kSystemManager_Path_Log        withObject:tmpStr];

    tmpStr = [NSString stringWithFormat:@"%@place", _tmpPath];
    [_pathArray replaceObjectAtIndex:kSystemManager_Path_Place      withObject:tmpStr];

    tmpStr = [NSString stringWithFormat:@"%@route", _tmpPath];
    [_pathArray replaceObjectAtIndex:kSystemManager_Path_Route      withObject:tmpStr];

    tmpStr = [NSString stringWithFormat:@"%@/track", _documentPath];
    [_pathArray replaceObjectAtIndex:kSystemManager_Path_Track      withObject:tmpStr];
    
    
    tmpStr = [NSString stringWithFormat:@"%@speech", _tmpPath];
    [_pathArray replaceObjectAtIndex:kSystemManager_Path_Speech     withObject:tmpStr];

    
    for(NSString *path in dirPaths)
    {
        printf("%s\n", [path UTF8String]);
    }
    
    [self cleanDirectory:_tmpPath];
    [self makeDirectory:[self getPath:kSystemManager_Path_Place]];
    [self makeDirectory:[self getPath:kSystemManager_Path_Route]];
    [self makeDirectory:[self getPath:kSystemManager_Path_Speech]];
  
    mlogInfo(@"   Document Path: %@", [self documentPath]);
    mlogInfo(@" Place File Path: %@", [self getPath:kSystemManager_Path_Place]);
    mlogInfo(@" Route File Path: %@", [self getPath:kSystemManager_Path_Route]);
    mlogInfo(@" Track File Path: %@", [self getPath:kSystemManager_Path_Track]);
    mlogInfo(@"Speech File Path: %@", [self getPath:kSystemManager_Path_Speech]);
    mlogInfo(@"Config File Path: %@", [self getPath:kSystemManager_Path_Config]);
    mlogInfo(@"  User File Path: %@", [self getPath:kSystemManager_Path_User]);
    mlogInfo(@"   Log File Path: %@", [self getPath:kSystemManager_Path_Log]);
    

}

+(NSString*) documentPath
{
    return _documentPath;
}

+(NSString*) tmpPath
{
    return _tmpPath;
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

+(NSString *) getPath:(SystemManagerPathType) pathType
{
    return [_pathArray objectAtIndex:pathType];

}
@end


