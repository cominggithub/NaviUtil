//
//  SystemManager.m
//  NavUtil
//
//  Created by Coming on 13/2/27.
//  Copyright (c) 2013年 Coming. All rights reserved.
//

#define DEFAULT_GOOGLE_LANGUAGE @"en"
#import "SystemManager.h"
#import "NaviQueryManager.h"
#import <mach/mach.h>
#import <sys/utsname.h>
#import "SystemConfig.h"

#define FILE_DEBUG TRUE
#include "Log.h"


static bool isInit = false;
static NSString *_documentPath=@"";
static NSString *_tmpPath=@"";
static NSString *_defaultLanguage=@"en";
static NSArray *_supportedLanguage;
static CLLocationCoordinate2D _defaultLocation;
static CGRect _screenRect;
static CGRect _lanscapeScreenRect;
static NSMutableArray* _pathArray;
static Reachability *_reachiability;
static NSMutableArray* _delegates;
static float _wifiStatus;
static float _threeGStatus;
static float _batteryLife;
static float _networkStatus;
static NSDictionary *_googleLanguage;
static NSDictionary *_defaultLanguageDic;


@implementation SystemManager


+(void) init
{
    [self initDirectory];
    [SystemConfig init];
    mlogCheckPoint(@"SystemManager Init");
    
#ifdef DEBUG
    mlogInfo(@"DEBUG");
#elif RELEASE_TEST
    mlogInfo(@"RELEASE TEST");
#else
    mlogInfo(@"RELEASE");
#endif
    
    _delegates = [[NSMutableArray alloc] initWithCapacity:0];
    [self initSupportedLanguage];
    [self initOS];
    [self initSystemStatus];
    [self updateNetworkStatus];

    isInit = true;
}


+(void) initOS
{
    UIDevice* device    = [UIDevice currentDevice];
    CGRect screenBounds = [[UIScreen mainScreen] bounds];
    CGFloat screenScale = [[UIScreen mainScreen] scale];
    struct utsname systemInfo;
    uname(&systemInfo);
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
    mlogInfo(@"Language: %@", [[NSLocale preferredLanguages] objectAtIndex:0]);
    

/*
    
    [SystemConfig setValue:CONFIG_NAVIER_NAME string:[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleName"]];
    [SystemConfig setValue:CONFIG_NAVIER_VERSION string:[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"]];
    [SystemConfig setValue:CONFIG_DEVICE_MACHINE_NAME string:[NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding]];
    [SystemConfig setValue:CONFIG_DEVICE_SYSTEM_NAME string:device.systemName];
    [SystemConfig setValue:CONFIG_DEVICE_SYSTEM_VERSION string:device.systemVersion];
    [SystemConfig setValue:CONFIG_DEVICE_SCREEN string:[NSString stringWithFormat:@"screen %.0f X %.0f %s",
                                                        screenBounds.size.width, screenBounds.size.height, screenScale > 1.0 ? "Retina":""]];
    [SystemConfig setValue:CONFIG_LOCALE string:[[NSLocale currentLocale] localeIdentifier]];
*/    
    _screenRect                         = screenBounds;
    _lanscapeScreenRect.origin.x        = 0;
    _lanscapeScreenRect.origin.y        = 0;
    _lanscapeScreenRect.size.width      = _screenRect.size.height;
    _lanscapeScreenRect.size.height     = _screenRect.size.width;

    [device setBatteryMonitoringEnabled:YES];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateBatteryLevel)
                                                 name:UIDeviceBatteryLevelDidChangeNotification
                                            object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateNetworkStatus)
                                                 name:kReachabilityChangedNotification object:nil];
 
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateSystemStatus)
                                                 name:@"applicationDidBecomeActive"
                                               object:nil];
    
    
    

    
}


+(void) updateSystemStatus
{
    [self updateNetworkStatus];
    [self triggerBatterStatusChangeNotify];
    [self triggerNetworkChangeStatusNotify];
    [self triggerGpsStatusChangeNotify];

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
            [delegate gpsStatusChange:[self getGpsStatus]];
        }
    }
}

+(void) updateNetworkStatus
{
    Reachability* networkStatus = [Reachability reachabilityForInternetConnection];
    NetworkStatus netStatus     = [networkStatus currentReachabilityStatus];
    BOOL connectionRequired     = [networkStatus connectionRequired];
    NSString* statusString= @"";
    switch (netStatus)
    {
        case NotReachable:
        {
            statusString        = @"None";
            //Minor interface detail- connectionRequired may return yes, even when the host is unreachable.  We cover that up here...
            connectionRequired  = NO;
            _wifiStatus         = 0;
            _threeGStatus       = 0;
            _networkStatus      = 0;
            break;
        }

        case ReachableViaWWAN:
        {
            statusString        = @"3G";
            _wifiStatus         = 0;
            _threeGStatus       = 1;
            _networkStatus      = 1;
            break;
        }
        
        case ReachableViaWiFi:
        {
            statusString        = @"Wifi";
            _wifiStatus         = 1;
            _threeGStatus       = 0;
            _networkStatus      = 1;
            break;
        }
        default:
        {
            statusString        = @"None";
            _wifiStatus         = 0;
            _threeGStatus       = 0;
            _networkStatus      = 0;
            break;
        }

    }

    mlogInfo(@"Network: %@\n", statusString);
    [self triggerNetworkChangeStatusNotify];
}

+(void) updateBatteryLevel
{
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
    _batteryLife = [[UIDevice currentDevice] batteryLevel];

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
    NSString *path;
    _supportedLanguage = [[NSArray alloc] initWithObjects:@"en", @"zh-Hant", @"zh-Hans", @"nl", nil];
    if ([_supportedLanguage containsObject:[self getSystemLanguage]])
    {
        _defaultLanguage = [self getSystemLanguage];
    }
         
    path = [[NSBundle mainBundle] pathForResource:@"Localizable"
                                           ofType:@"strings"
                                      inDirectory:nil
                                  forLocalization:self.defaultLanguage];
    _defaultLanguageDic = [NSDictionary dictionaryWithContentsOfFile:path];
    
    [self initGoogleLanguageSetting];

}

+(void) initDirectory
{
    int i;
    NSDateFormatter *dateFormattor;
    NSFileManager *filemanager;
    NSString *currentPath;
    NSArray *dirPaths;
    NSString *tmpStr;

    
    dateFormattor  = [[NSDateFormatter alloc] init];
    [dateFormattor setDateFormat:@"yyyy-MM-dd"];

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

    tmpStr = [NSString stringWithFormat:@"%@", _tmpPath];
    [_pathArray replaceObjectAtIndex:kSystemManager_Path_Tmp        withObject:tmpStr];
    
    tmpStr = [NSString stringWithFormat:@"%@/log", _documentPath];
    [_pathArray replaceObjectAtIndex:kSystemManager_Path_Log        withObject:tmpStr];

    tmpStr = [NSString stringWithFormat:@"%@place", _tmpPath];
    [_pathArray replaceObjectAtIndex:kSystemManager_Path_Place      withObject:tmpStr];

    tmpStr = [NSString stringWithFormat:@"%@route", _tmpPath];
    [_pathArray replaceObjectAtIndex:kSystemManager_Path_Route      withObject:tmpStr];

    tmpStr = [NSString stringWithFormat:@"%@/track", _documentPath];
    [_pathArray replaceObjectAtIndex:kSystemManager_Path_Track      withObject:tmpStr];
    
    tmpStr = [NSString stringWithFormat:@"%@speech", _tmpPath];
    [_pathArray replaceObjectAtIndex:kSystemManager_Path_Speech     withObject:tmpStr];

    [self cleanDirectory:_tmpPath];
    [self makeDirectory:[self getPath:kSystemManager_Path_Place]];
    [self makeDirectory:[self getPath:kSystemManager_Path_Route]];
    [self makeDirectory:[self getPath:kSystemManager_Path_Speech]];
    [self makeDirectory:[self getPath:kSystemManager_Path_Track]];
    [self makeDirectory:[self getPath:kSystemManager_Path_Log]];
  
    mlogInfo(@"   Document Path: %@", [self documentPath]);
    mlogInfo(@" Place File Path: %@", [self getPath:kSystemManager_Path_Place]);
    mlogInfo(@" Route File Path: %@", [self getPath:kSystemManager_Path_Route]);
    mlogInfo(@" Track File Path: %@", [self getPath:kSystemManager_Path_Track]);
    mlogInfo(@"Speech File Path: %@", [self getPath:kSystemManager_Path_Speech]);
    mlogInfo(@"Config File Path: %@", [self getPath:kSystemManager_Path_Config]);
    mlogInfo(@"  User File Path: %@", [self getPath:kSystemManager_Path_User]);
    mlogInfo(@"   Log File Path: %@", [self getPath:kSystemManager_Path_Log]);
    mlogInfo(@"   tmp File Path: %@", [self getPath:kSystemManager_Path_Tmp]);

    

}

+(void) initGoogleLanguageSetting
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *fileName;
    
    fileName = [[NSBundle mainBundle] pathForResource:@"googleLanguage" ofType:@"plist"];

    if (![fileManager fileExistsAtPath:fileName]){
        mlogError(@"cannot get configuration file: gogoleLanguage.plist\n");
    }
    
    _googleLanguage = [[NSDictionary alloc] initWithContentsOfFile:fileName];
}
+(NSString *) getFilePathInDocument:(NSString*) fileName
{
    return [NSString stringWithFormat:@"%@/%@", _documentPath, fileName];
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
    /* file directory doesn't exist, then create it */
    if (![[NSFileManager defaultManager] fileExistsAtPath:path]) {
        
        [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:NULL];
    }

}

+(NSString *) getSystemLanguage
{
    return [[NSLocale preferredLanguages] objectAtIndex:0];
}

+(NSString *) getGoogleLanguage
{
    NSString *language;
    language = DEFAULT_GOOGLE_LANGUAGE;
    
    if (nil != _googleLanguage)
    {

        language = [_googleLanguage objectForKey:[[NSLocale preferredLanguages] objectAtIndex:0]];

        if (nil == language)
        {
            language = DEFAULT_GOOGLE_LANGUAGE;
        }
    }

    
    return language;
}

+(NSString *) defaultLanguage;
{
    return _defaultLanguage;
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
            result = [NSString stringWithFormat:@"%d Bytes", (int)info.resident_size];
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
    NSString *string = [_defaultLanguageDic valueForKey:stringIndex];
    
    return string != nil ? string : stringIndex;
}

#if 0
+(NSString *) getLanguageString:(NSString*) stringIndex
{
    
    NSString *result = NSLocalizedString(stringIndex, stringIndex);

    if (nil  == result)
        return stringIndex;
    
    return result;

    
}

#endif

+(NSString *) getPath:(SystemManagerPathType) pathType
{
    return [_pathArray objectAtIndex:pathType];
}

+(BOOL) hostReachable:(NSString *)host
{
    bool success = false;
    const char *host_name = [host cStringUsingEncoding:NSASCIIStringEncoding];
    
    SCNetworkReachabilityRef reachability = SCNetworkReachabilityCreateWithName(NULL, host_name);
    SCNetworkReachabilityFlags flags;
    success = SCNetworkReachabilityGetFlags(reachability, &flags);
    bool isAvailable = success && (flags & kSCNetworkFlagsReachable) && !(flags & kSCNetworkFlagsConnectionRequired);
    
    return isAvailable;
}

+(void) dinit
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end


