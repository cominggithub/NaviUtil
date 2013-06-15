//
//  Log.m
//  NaviUtil
//
//  Created by Coming on 13/3/4.
//  Copyright (c) 2013年 Coming. All rights reserved.
//

#import "Log.h"
#include <stdarg.h>

static bool isInit = false;
static NSFileHandle *fileHandle = nil;
static bool isLogToFile = true;
static bool isLogToConsole = true;
//static unsigned long long logModule = (ALL&~DOWNLOAD_MANAGER & ~NAVI_QUERY_MANAGER & ~LOCATION_SIMULATOR & ~GEOUTIL);
static unsigned long long logModule = (ALL & ~LOCATION_SIMULATOR & ~GEOUTIL & ~ROUTE & ~FILE_DOWNLOADER & ~DOWNLOAD_MANAGER) ;
static LogLevel logLevel = kLogAll;

NSDateFormatter *outputFormatter;

void logOut(const char* level, const char* moduleName, NSString* msg);
void logToFile(NSString* msg);
void logToConsole(NSString* msg);

int isLogModule(unsigned long long module)
{
 //   printf("%llX %llX %d\n", logModule, module, (logModule & module) == module);
    
    return (logModule & module) == module;
}

void logInit()
{
    if(false == isInit)
    {
        [[NSFileManager defaultManager] createFileAtPath:[SystemManager logFilePath]
                                                contents:nil
                                              attributes:nil];
        
        fileHandle  = [NSFileHandle fileHandleForWritingAtPath:SystemManager.logFilePath];
        outputFormatter = [[NSDateFormatter alloc] init];
        [outputFormatter setDateFormat:@"MM-dd HH:mm:ss"];
    }
    isInit = true;
}

void logInfo(const char* moduleName, id formatString, ...)
{
    
    NSString *str;
    va_list args;
    va_start(args, formatString);
    str = [[NSString alloc] initWithFormat:formatString arguments:args];
    logOut("[INFO]", moduleName, str);
    va_end(args);
}

void logWarning(const char* moduleName, id formatString, ...)
{
    NSString *str;
    va_list args;
    va_start(args, formatString);
    str = [[NSString alloc] initWithFormat:formatString arguments:args];
    logOut("[WARNING]", moduleName, str);

    va_end(args);
}


void logError(const char* moduleName, id formatString, ...)
{
    
    NSString *str;
    va_list args;
    va_start(args, formatString);
    str = [[NSString alloc] initWithFormat:formatString arguments:args];
    logOut("[ERROR]", moduleName, str);
    va_end(args);
}

void logDebug(const char* moduleName, id formatString, ...)
{
    if(logLevel < kLogDebug)
        return;
            
    NSString *str;
    va_list args;
    va_start(args, formatString);
    str = [[NSString alloc] initWithFormat:formatString arguments:args];
    logOut("[DEBUG]", moduleName, str);
    va_end(args);
}

void logOut(const char* level, const char* moduleName, NSString* msg)
{
    logInit();
#if 0
    NSString *outputStr = [NSString stringWithFormat:@"%s %s %@ %@\n",
                           level,
                           moduleName,
                           [outputFormatter stringFromDate:[NSDate date]],
                           msg
                           ];
#else
    NSString *outputStr = [NSString stringWithFormat:@"%s %s %@\n",
                           level,
                           moduleName,
                           msg
                           ];
    
#endif
    
    if( true == isLogToFile )
    {
        logToFile(outputStr);
    }
    
    if( true == isLogToConsole )
    {
        logToConsole(outputStr);
    }
}
void logToFile(NSString* msg)
{

#if 0
    [msg writeToFile:[SystemManager logFilePath]
              atomically:NO
                encoding:NSStringEncodingConversionAllowLossy
                   error:nil];
#endif
    [fileHandle writeData:[msg dataUsingEncoding:NSUTF8StringEncoding]];
    [fileHandle synchronizeFile];
    
}

void logToConsole(NSString* msg)
{
    printf("%s", [msg UTF8String]);
}

bool isDebug()
{
    if(logLevel < kLogDebug)
        return false;
    return true;
}

