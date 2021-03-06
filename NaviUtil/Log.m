//
//  Log.m
//  NaviUtil
//
//  Created by Coming on 13/3/4.
//  Copyright (c) 2013年 Coming. All rights reserved.
//

#import "Log.h"
#include <stdarg.h>
#include <stdio.h>
#include <stdlib.h>


static bool isInit = false;
static NSFileHandle *fileHandle = nil;
static bool isLogToFile = true;
static bool isLogToConsole = true;

NSDateFormatter *outputFormatter;

const char* getLevelStr(int level);


void _logOut(int level, const char* func_name, int lineNo, NSString* msg);
void logToFile(NSString* msg);
void logToConsole(NSString* msg);



void logInit()
{
    if(false == isInit)
    {
        NSDateFormatter* dateFormattor  = [[NSDateFormatter alloc] init];
        [dateFormattor setDateFormat:@"yyyy-MM-dd.HHmmss"];
        NSString *logFileName = [NSString stringWithFormat:@"%@/%@.log",
                                 [SystemManager getPath:kSystemManager_Path_Log], [dateFormattor stringFromDate:[NSDate date]]];
        
        [[NSFileManager defaultManager] createFileAtPath:logFileName
                                                contents:nil
                                              attributes:nil];
        
        fileHandle  = [NSFileHandle fileHandleForWritingAtPath:logFileName];
        outputFormatter = [[NSDateFormatter alloc] init];
        [outputFormatter setDateFormat:@"MM-dd HH:mm:ss"];
    }
    isInit = true;
}


void logOut(int level, const char* func_name, int lineNo, id formatString, ...)
{
    
    NSString *str;
    va_list args;
    va_start(args, formatString);
    str = [[NSString alloc] initWithFormat:formatString arguments:args];
    _logOut(level, func_name, lineNo, str);
    va_end(args);
}

void _logOut(int level, const char* func_name, int lineNo, NSString* msg)
{
    logInit();
#if DEBUG || RELEASE_TEST
    NSString *outputStr = [NSString stringWithFormat:@"%s %s(%d): %@\n",
                           getLevelStr(level),
                           func_name,
                           lineNo,
                           msg
                           ];
#else
    NSString *outputStr = [NSString stringWithFormat:@"%@ %s %s(%d): %@\n",
                           [outputFormatter stringFromDate:[NSDate date]],
                           getLevelStr(level),
                           func_name,
                           lineNo,
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
    
    if (level == kLogCheckPoint)
    {

    }
    else if (level == kLogInfo || level == kLogError)
    {

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
    @try
    {
        if (nil != fileHandle)
        {
            [fileHandle writeData:[msg dataUsingEncoding:NSUTF8StringEncoding]];
            [fileHandle synchronizeFile];
        }
    }
    @catch (NSException *exception)
    {
        
    }

}

void logToConsole(NSString* msg)
{
    printf("%s", [msg UTF8String]);
}

const char* getLevelStr(int level)
{
    switch (level)
    {
        case kLogDebug:
            return "[DEBUG]";
        case kLogError:
            return "[ERROR]";
        case kLogInfo:
            return "[INFO]";
        case kLogWarning:
            return "[WARNING]";
        case kLogCheckPoint:
            return "[CheckPoint]";
    }
    
    return "[DEBUG]";
}

void classProtocol(id a)
{
    
    if (class_conformsToProtocol([a class], @protocol(NSCopying)))
    {
        logfns("conforms NSCopying\n");
    }
    else
    {
        logfns("not conforms NSCopying\n");
    }
}