//
//  SystemManager.m
//  NavUtil
//
//  Created by Coming on 13/2/27.
//  Copyright (c) 2013年 Coming. All rights reserved.
//

#import "SystemManager.h"
#import "linmsdebug.h"
#import "NaviQueryManager.h"


static bool isInit = false;
static NSString *_documentPath=@"";
static NSString *_tmpPath=@"";
static NSString *_routeFilePath=@"";
static NSString *_placeFilePath=@"";
static NSString *_speechFilePath=@"";
static NSString *_logFilePath=@"";
static NSString *_defaultLanguage=@"en-US";
static NSDictionary *_supportedLanguage;
static CLLocationCoordinate2D _defaultLocation;


@implementation SystemManager


+(void) init
{
    [self initSupportedLanguage];
    [self initDirectory];
    [NaviQueryManager init];
    isInit = true;
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
    _logFilePath    = [NSString stringWithFormat:@"%@%@.log", _tmpPath, [dateFormattor stringFromDate:[NSDate date]]];
    
    for(NSString *path in dirPaths)
    {
        printf("%s\n", [path UTF8String]);
    }

    linmso([self documentPath]);
    linmso([self placeFilePath]);
    linmso([self routeFilePath]);
    linmso([self speechFilePath]);
    linmso([self logFilePath]);

    [self cleanDirectory:_tmpPath];
    [self makeDirectory:[self placeFilePath]];
    [self makeDirectory:[self routeFilePath]];
    [self makeDirectory:[self speechFilePath]];
  

    logInfo(@"System Init");
    logInfo(@"   Document Path: %@", [self documentPath]);
    logInfo(@" Place File Path: %@", [self placeFilePath]);
    logInfo(@" Route File Path: %@", [self routeFilePath]);
    logInfo(@"Speech File Path: %@", [self speechFilePath]);
    logInfo(@"   Log File Path: %@", [self logFilePath]);
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


@end


