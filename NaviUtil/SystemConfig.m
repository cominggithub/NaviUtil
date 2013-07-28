//
//  SystemConfig.m
//  NaviUtil
//
//  Created by Coming on 13/6/19.
//  Copyright (c) 2013年 Coming. All rights reserved.
//

#import "SystemConfig.h"
#import "JsonFile.h"

#define FILE_DEBUG FALSE
#include "Log.h"

@implementation SystemConfig

static UIColor *_defaultColor;
static JsonFile *_configFile;

#pragma variable

+(int) getIntValue:(NSString*) key
{
    return [[_configFile objectForKey:key] intValue];
}

+(double) getDoubleValue:(NSString*) key
{
    return [[_configFile objectForKey:key] doubleValue];
}

+(float) getFloatValue:(NSString*) key
{
    return [[_configFile objectForKey:key] floatValue];
}

+(BOOL) getBOOLValue:(NSString*) key
{
    return [[_configFile objectForKey:key] boolValue];
}

+(void) setValue:(NSString*) key int:(int) value
{
    [_configFile setObjectForKey:key object:[NSString stringFromInt:value]];
    [self save];
}

+(void) setValue:(NSString*) key double:(double) value
{
    [_configFile setObjectForKey:key object:[NSString stringFromDouble:value]];
    [self save];
}

+(void) setValue:(NSString*) key float:(float) value
{
    [_configFile setObjectForKey:key object:[NSString stringFromFloat:value]];
    [self save];
}

+(void) setValue:(NSString*) key BOOL:(BOOL) value
{
    [_configFile setObjectForKey:key object:[NSString stringFromBOOL:value]];
    [self save];
}

+(UIColor*) defaultColor
{
    return _defaultColor;
}

+(void) setDefaultColor:(UIColor*) value
{
    _defaultColor = value;
}


#pragma mark - function
+(BOOL) init
{
    _defaultColor                   = [UIColor greenColor];
    _configFile                     = [JsonFile jsonFileWithFileName:[SystemManager getPath:kSystemManager_Path_Config]];

    /* initialization System Config */
    if ( 0 == _configFile.root.count)
    {
        logfn();
        [_configFile setBOOLForKey:CONFIG_IS_DEBUG                      value:TRUE];
        [_configFile setBOOLForKey:CONFIG_IS_AD                         value:TRUE];
        [_configFile setBOOLForKey:CONFIG_IS_DEBUG_ROUTE_DRAW           value:TRUE];
        [_configFile setBOOLForKey:CONFIG_IS_MANUAL_PLACE               value:FALSE];
        [_configFile setBOOLForKey:CONFIG_IS_LOCATION_UPDATE_FILTER     value:FALSE];
        [_configFile setBOOLForKey:CONFIG_IS_SPEECH                     value:TRUE];
        [_configFile setFloatForKey:CONFIG_TURN_ANGLE_DISTANCE          value:50.0]; // meters
        [_configFile setFloatForKey:CONFIG_TARGET_ANGLE_DISTANCE        value:5.0]; // meters
        [_configFile setFloatForKey:CONFIG_TRIGGER_LOCATION_INTERVAL    value:500]; // 200 millisecond
        [self save];
    }
    
    return TRUE;
}

+(void) save
{
    [_configFile save];
}

@end
