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

NSDateFormatter *outputFormatter;


void logOut(NSString *level, NSString* msg);
void logToFile(NSString* msg);
void logToConsole(NSString* msg);
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
void logInfo(id formatString, ...)
{
    NSString *str;
    va_list args;
    va_start(args, formatString);
    str = [[NSString alloc] initWithFormat:formatString arguments:args];
    logOut(@"[INFO]", str);
    va_end(args);
}

void logWarning(id formatString, ...)
{

    NSString *str;
    va_list args;
    va_start(args, formatString);
    str = [[NSString alloc] initWithFormat:formatString arguments:args];
    logOut(@"[INFO]", str);
    va_end(args);
}


void logError(id formatString, ...)
{

    NSString *str;
    va_list args;
    va_start(args, formatString);
    str = [[NSString alloc] initWithFormat:formatString arguments:args];
    logOut(@"[INFO]", str);
    va_end(args);
}

void logDebug(id formatString, ...)
{

    NSString *str;
    va_list args;
    va_start(args, formatString);
    str = [[NSString alloc] initWithFormat:formatString arguments:args];
    logOut(@"[INFO]", str);
    va_end(args);
}

void logOut(NSString *level, NSString* msg)
{
    logInit();
#if 0
    NSString *outputStr = [NSString stringWithFormat:@"%@ %@ %@\n",
                           level,
                           [outputFormatter stringFromDate:[NSDate date]],
                           msg
                           ];
#else
    NSString *outputStr = [NSString stringWithFormat:@"%@ %@\n",
                           level,
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
    NSLog(@"%@", fileHandle);
    [fileHandle writeData:[msg dataUsingEncoding:NSUTF8StringEncoding]];
    [fileHandle synchronizeFile];
    
}

void logToConsole(NSString* msg)
{
    printf("%s", [msg UTF8String]);
}
