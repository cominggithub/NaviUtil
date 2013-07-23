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
static double _triggerLocationUpdateInterval; // in millisecond
static BOOL _isSpeech;
static BOOL _isLocationUpdateFilter;
static BOOL _turnAngleDistance;
static BOOL _targetAngleDistance;



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


+(BOOL) isSpeech
{
    return _isSpeech;
}

+(void) setIsSpeech:(BOOL) value
{
    _isSpeech = value;
}

+(BOOL) isLocationUpdateFilter
{
    return _isLocationUpdateFilter;
}

+(void) setLocationUpdateFilter:(BOOL) value
{
    _isLocationUpdateFilter = value;
}

+(double) turnAngleDistance
{
    return _turnAngleDistance;
}

+(void) setTurnAngleDistance:(double) value
{
    _turnAngleDistance = value;
}

+(double) targetAngleDistance
{
    return _targetAngleDistance;
}

+(void) setTargetAngleDistance:(double) value
{
    _targetAngleDistance = value;
}

#pragma function
+(BOOL) init
{
    _isDebug                        = TRUE;
    _isAd                           = TRUE;
    _isDebugRouteDraw               = TRUE;
    _isManualPlace                  = TRUE;
    _isLocationUpdateFilter         = FALSE;
    _isSpeech                       = TRUE;
    _turnAngleDistance              = 50.0; // 50 meters
    _targetAngleDistance              = 5.0; // 5 meters
    _triggerLocationUpdateInterval  = 500;
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
