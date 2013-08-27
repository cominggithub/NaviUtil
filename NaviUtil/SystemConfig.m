//
//  SystemConfig.m
//  NaviUtil
//
//  Created by Coming on 13/6/19.
//  Copyright (c) 2013年 Coming. All rights reserved.
//

#import "SystemConfig.h"
#import "JsonFile.h"
#import "NSString+category.h"

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

+(BOOL) getBoolValue:(NSString*) key
{
    return [[_configFile objectForKey:key] boolValue];
}

+(UIColor*) getUIColorValue:(NSString*) key
{
    return [(NSString*)[_configFile objectForKey:key] uicolorValue];
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

+(void) setValue:(NSString*) key uicolor:(UIColor*) value
{
    [_configFile setObjectForKey:key object:[NSString stringFromUIColor:value]];
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
    _configFile = [JsonFile jsonFileWithFileName:[SystemManager getPath:kSystemManager_Path_Config]];
    logo(_configFile);
    [self checkKeys];

    [self save];
    
    return TRUE;
}

+(void) checkKeys
{
    [self checkKey:CONFIG_IS_DEBUG                      defaultValue:[NSString stringFromBOOL:TRUE]];
    [self checkKey:CONFIG_IS_AD                         defaultValue:[NSString stringFromBOOL:TRUE]];
    [self checkKey:CONFIG_IS_DEBUG_ROUTE_DRAW           defaultValue:[NSString stringFromBOOL:TRUE]];
    [self checkKey:CONFIG_IS_MANUAL_PLACE               defaultValue:[NSString stringFromBOOL:FALSE]];
    [self checkKey:CONFIG_IS_LOCATION_UPDATE_FILTER     defaultValue:[NSString stringFromBOOL:FALSE]];
    [self checkKey:CONFIG_IS_LOCATION_SIMULATOR         defaultValue:[NSString stringFromBOOL:FALSE]];
    [self checkKey:CONFIG_IS_SPEECH                     defaultValue:[NSString stringFromBOOL:TRUE]];
    [self checkKey:CONFIG_TURN_ANGLE_DISTANCE           defaultValue:[NSString stringFromFloat:50.0]];
    [self checkKey:CONFIG_TARGET_ANGLE_DISTANCE         defaultValue:[NSString stringFromFloat:5.0]];
    [self checkKey:CONFIG_TRIGGER_LOCATION_INTERVAL     defaultValue:[NSString stringFromInt:500]];
    [self checkKey:CONFIG_IS_SPEED_UNIT_MPH             defaultValue:[NSString stringFromBOOL:FALSE]];
    [self checkKey:CONFIG_DEFAULT_COLOR                 defaultValue:[NSString stringFromUIColor:[UIColor greenColor]]];
    
    [self checkKey:CONFIG_CP1_COLOR                     defaultValue:[NSString stringFromUIColor:[UIColor greenColor]]];
    [self checkKey:CONFIG_CP1_IS_SPEED_UNIT_MPH         defaultValue:[NSString stringFromBOOL:FALSE]];
    [self checkKey:CONFIG_CP1_IS_HUD                    defaultValue:[NSString stringFromBOOL:FALSE]];
    [self checkKey:CONFIG_CP1_IS_COURSE                 defaultValue:[NSString stringFromBOOL:TRUE]];

    [self checkKey:CONFIG_RN1_COLOR                     defaultValue:[NSString stringFromUIColor:[UIColor greenColor]]];
    [self checkKey:CONFIG_RN1_IS_SPEED_UNIT_MPH         defaultValue:[NSString stringFromBOOL:FALSE]];
    [self checkKey:CONFIG_RN1_IS_HUD                    defaultValue:[NSString stringFromBOOL:FALSE]];
    [self checkKey:CONFIG_RN1_IS_COURSE                 defaultValue:[NSString stringFromBOOL:TRUE]];
    
    [self checkKey:CONFIG_MAX_OUT_OF_ROUTELINE_COUNT    defaultValue:[NSString stringFromInt:3]];
    
    [self save];
    
}

+(void) checkKey:(NSString*) key defaultValue:(NSString*) defaultValue
{
    id value;
    value = [_configFile objectForKey:key];

    if (nil == value)
    {
        [_configFile setObjectForKey:key object:defaultValue];
    }
}

+(void) save
{
    [_configFile save];
}

@end
