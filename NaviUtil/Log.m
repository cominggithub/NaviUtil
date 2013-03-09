//
//  Log.m
//  NaviUtil
//
//  Created by Coming on 13/3/4.
//  Copyright (c) 2013年 Coming. All rights reserved.
//

#import "Log.h"
#include <stdarg.h>

void logInfo(id formatString, ...)
{
    NSString *str;
    va_list args;
    va_start(args, formatString);
    str = [[NSString alloc] initWithFormat:formatString arguments:args];
    NSLog(@"[INFO]%@", str);
    va_end(args);
}

void logWarning(id formatString, ...)
{
    NSString *str;
    va_list args;
    va_start(args, formatString);
    str = [[NSString alloc] initWithFormat:formatString arguments:args];
    NSLog(@"[WARN]%@", str);
    va_end(args);
}


void logError(id formatString, ...)
{
    NSString *str;
    va_list args;
    va_start(args, formatString);
    str = [[NSString alloc] initWithFormat:formatString arguments:args];
    NSLog(@"[EROR]%@", str);
    va_end(args);
}

void logDebug(id formatString, ...)
{
    NSString *str;
    va_list args;
    va_start(args, formatString);
    str = [[NSString alloc] initWithFormat:formatString arguments:args];
    NSLog(@"[DEBG]%@", str);
    va_end(args);
}







