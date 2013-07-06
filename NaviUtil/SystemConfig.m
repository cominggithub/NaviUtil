//
//  SystemConfig.m
//  NaviUtil
//
//  Created by Coming on 13/6/19.
//  Copyright (c) 2013年 Coming. All rights reserved.
//

#import "SystemConfig.h"

#define FILE_DEBUG FALSE
#include "Log.h"

@implementation SystemConfig

static BOOL _isDebug;
static BOOL _isAd;
static BOOL _isManualPlace;
static BOOL _isDebugRouteDraw;
static double _triggerLocationUpdateInterval;


#pragma variable
+(BOOL) isDebug
{
    return _isDebug;
}

+(void) setIsDebug:(BOOL) value
{
    _isDebug = value;
}

+(BOOL) isAd
{
    return _isAd;
}

+(void) setIsAd:(BOOL) value
{
    _isAd = value;
}

+(BOOL) isManualPlace
{
    return _isManualPlace;
}
+(void) setIsManualPlace:(BOOL) value
{
    _isManualPlace = value;
}
+(BOOL) isDebugRouteDraw
{
    return _isDebugRouteDraw;
}

+(void) setIsDebugRouteDraw:(BOOL) value
{
    _isDebugRouteDraw = value;
}

+(double) triggerLocationInterval
{
    return _triggerLocationUpdateInterval;
}

+(void) setTriggerLocationInterval:(double) value
{
    _triggerLocationUpdateInterval = value;
}


#pragma function
+(BOOL) init
{
    _isDebug            = true;
    _isAd               = false;
    _isDebugRouteDraw   = true;
    _isManualPlace      = true;
    
    return [self parseJason];
}

+(BOOL) parseJason
{
    BOOL result = true;
    @try {
        
    }
    @catch (NSException *exception) {
        result = false;
    }

    return result;
}


@end
