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
#import "RSSecrets.h"

#define FILE_DEBUG FALSE
#include "Log.h"

@implementation SystemConfig

static JsonFile *_configFile;
static JsonFile *_hiddenConfigFile;

#pragma variable

+(NSString*) getStringValue:(NSString*) key
{
    if ([key hasPrefix:@"@"])
        return [_hiddenConfigFile objectForKey:key];
    
    return [_configFile objectForKey:key];
}

+(int) getIntValue:(NSString*) key
{
    if ([key hasPrefix:@"@"])
        return [[_hiddenConfigFile objectForKey:key] intValue];
    
    return [[_configFile objectForKey:key] intValue];
}

+(double) getDoubleValue:(NSString*) key
{
    if ([key hasPrefix:@"@"])
        return [[_hiddenConfigFile objectForKey:key] doubleValue];
    
    return [[_configFile objectForKey:key] doubleValue];
}

+(float) getFloatValue:(NSString*) key
{
    if ([key hasPrefix:@"@"])
        return [[_hiddenConfigFile objectForKey:key] floatValue];
    
    return [[_configFile objectForKey:key] floatValue];
}

+(BOOL) getBoolValue:(NSString*) key
{
    if ([key hasPrefix:@"IAP_"])
    {
        return [self hasIAPItem:key];
    }
    else if ([key hasPrefix:@"@"])
    {
        return [[_hiddenConfigFile objectForKey:key] boolValue];
    }
    
    return [[_configFile objectForKey:key] boolValue];
}

+(UIColor*) getUIColorValue:(NSString*) key
{
    if ([key hasPrefix:@"@"])
        return [(NSString*)[_hiddenConfigFile objectForKey:key] uicolorValue];

    return [(NSString*)[_configFile objectForKey:key] uicolorValue];
}

+ (void)removeIAPItem:(NSString*) key
{
    mlogAssertStrNotEmpty(key);
    return [RSSecrets removeKey:key];
}

+ (void)addIAPItem:(NSString*) key
{
    mlogAssertStrNotEmpty(key);
    return [RSSecrets addKey:key];
}

+ (BOOL)hasIAPItem:(NSString*) key
{
    mlogAssertStrNotEmptyR(key, FALSE);
    return [RSSecrets hasKey:key];
}

+(void) setValue:(NSString*) key string:(NSString*) value
{
    if ([key hasPrefix:@"@"])
    {
        [_hiddenConfigFile setObjectForKey:key object:value];
    }
    else
    {
        [_configFile setObjectForKey:key object:value];
        [self save];
    }
    
}

+(void) setValue:(NSString*) key int:(int) value
{
    if ([key hasPrefix:@"@"])
    {
        [_hiddenConfigFile setObjectForKey:key object:[NSString stringFromInt:value]];
    }
    else
    {
        [_configFile setObjectForKey:key object:[NSString stringFromInt:value]];
        [self save];
    }

}

+(void) setValue:(NSString*) key double:(double) value
{
    if ([key hasPrefix:@"@"])
    {
        [_hiddenConfigFile setObjectForKey:key object:[NSString stringFromDouble:value]];
    }
    else
    {
        [_configFile setObjectForKey:key object:[NSString stringFromDouble:value]];
        [self save];
    }
}

+(void) setValue:(NSString*) key float:(float) value
{
    if ([key hasPrefix:@"@"])
    {
        [_hiddenConfigFile setObjectForKey:key object:[NSString stringFromFloat:value]];
    }
    else
    {
        [_configFile setObjectForKey:key object:[NSString stringFromFloat:value]];
        [self save];
    }
}

+(void) setValue:(NSString*) key BOOL:(BOOL) value
{
    if ([key hasPrefix:@"@"])
    {
        [_hiddenConfigFile setObjectForKey:key object:[NSString stringFromBOOL:value]];
    }
    else
    {
        [_configFile setObjectForKey:key object:[NSString stringFromBOOL:value]];
        [self save];
    }
}

+(void) setValue:(NSString*) key uicolor:(UIColor*) value
{
    if ([key hasPrefix:@"@"])
    {
        [_hiddenConfigFile setObjectForKey:key object:[NSString stringFromUIColor:value]];
    }
    else
    {
        [_configFile setObjectForKey:key object:[NSString stringFromUIColor:value]];
        [self save];
    }
}


#pragma mark - function
+(BOOL) init
{
    _configFile         = [JsonFile jsonFileWithFileName:[SystemManager getPath:kSystemManager_Path_Config]];
    _hiddenConfigFile   = [JsonFile jsonFileWithFileName:@"a.aa"];
    [self checkKeys];

    [self save];
    
    return TRUE;
}

+(void) checkKeys
{
#if DEBUG
    [self checkKey:CONFIG_H_IS_DEBUG                      defaultValue:[NSString stringFromBOOL:TRUE]];
    [self checkKey:CONFIG_H_IS_AD                         defaultValue:[NSString stringFromBOOL:TRUE]];
    [self checkKey:CONFIG_H_IS_USER_PLACE                 defaultValue:[NSString stringFromBOOL:TRUE]];
    [self checkKey:CONFIG_H_IS_DEBUG_ROUTE_DRAW           defaultValue:[NSString stringFromBOOL:TRUE]];
    [self checkKey:CONFIG_H_IS_MANUAL_PLACE               defaultValue:[NSString stringFromBOOL:FALSE]];
    [self checkKey:CONFIG_H_IS_LOCATION_UPDATE_FILTER     defaultValue:[NSString stringFromBOOL:FALSE]];
    [self checkKey:CONFIG_H_IS_LOCATION_SIMULATOR         defaultValue:[NSString stringFromBOOL:FALSE]];
    [self checkKey:CONFIG_H_IS_SIMULATE_LOCATION_LOST     defaultValue:[NSString stringFromBOOL:TRUE]];
    [self checkKey:CONFIG_H_IS_SIMULATE_CAR_MOVEMENT      defaultValue:[NSString stringFromBOOL:FALSE]];
#elif RELEASE_TEST
    [self checkKey:CONFIG_H_IS_DEBUG                      defaultValue:[NSString stringFromBOOL:FALSE]];
    [self checkKey:CONFIG_H_IS_AD                         defaultValue:[NSString stringFromBOOL:TRUE]];
    [self checkKey:CONFIG_H_IS_USER_PLACE                 defaultValue:[NSString stringFromBOOL:TRUE]];
    [self checkKey:CONFIG_H_IS_DEBUG_ROUTE_DRAW           defaultValue:[NSString stringFromBOOL:FALSE]];
    [self checkKey:CONFIG_H_IS_MANUAL_PLACE               defaultValue:[NSString stringFromBOOL:FALSE]];
    [self checkKey:CONFIG_H_IS_LOCATION_UPDATE_FILTER     defaultValue:[NSString stringFromBOOL:FALSE]];
    [self checkKey:CONFIG_H_IS_LOCATION_SIMULATOR         defaultValue:[NSString stringFromBOOL:FALSE]];
    [self checkKey:CONFIG_H_IS_SIMULATE_LOCATION_LOST     defaultValue:[NSString stringFromBOOL:FALSE]];
    [self checkKey:CONFIG_H_IS_SIMULATE_CAR_MOVEMENT      defaultValue:[NSString stringFromBOOL:FALSE]];
#else
    [self checkKey:CONFIG_H_IS_DEBUG                      defaultValue:[NSString stringFromBOOL:FALSE]];
    [self checkKey:CONFIG_H_IS_AD                         defaultValue:[NSString stringFromBOOL:TRUE]];
    [self checkKey:CONFIG_H_IS_USER_PLACE                 defaultValue:[NSString stringFromBOOL:TRUE]];
    [self checkKey:CONFIG_H_IS_DEBUG_ROUTE_DRAW           defaultValue:[NSString stringFromBOOL:FALSE]];
    [self checkKey:CONFIG_H_IS_MANUAL_PLACE               defaultValue:[NSString stringFromBOOL:FALSE]];
    [self checkKey:CONFIG_H_IS_LOCATION_UPDATE_FILTER     defaultValue:[NSString stringFromBOOL:FALSE]];
    [self checkKey:CONFIG_H_IS_LOCATION_SIMULATOR         defaultValue:[NSString stringFromBOOL:FALSE]];
    [self checkKey:CONFIG_H_IS_SIMULATE_LOCATION_LOST     defaultValue:[NSString stringFromBOOL:FALSE]];
    [self checkKey:CONFIG_H_IS_SIMULATE_CAR_MOVEMENT      defaultValue:[NSString stringFromBOOL:FALSE]];
#endif
    

    [self checkKey:CONFIG_IS_SPEECH                     defaultValue:[NSString stringFromBOOL:TRUE]];
    [self checkKey:CONFIG_TURN_ANGLE_DISTANCE           defaultValue:[NSString stringFromFloat:130.0]];
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
    
    [self checkKey:CONFIG_MAX_OUT_OF_ROUTELINE_COUNT    defaultValue:[NSString stringFromInt:10]];
    [self checkKey:CONFIG_DEFAULT_TRACK_FILE            defaultValue:@"Track.tr"];
    [self checkKey:CONFIG_DEFAULT_ROUTE_FILE            defaultValue:@"Route.json"];
    [self checkKey:CONFIG_IS_TRACK_FILE                 defaultValue:[NSString stringFromBOOL:TRUE]];
    [self checkKey:CONFIG_IS_TRACK_LOCATION                 defaultValue:[NSString stringFromBOOL:TRUE]];
    [self checkKey:CONFIG_DEFAULT_BRIGHTNESS            defaultValue:[NSString stringFromFloat:.5]];
    
    [self checkKey:CONFIG_NAVIER_NAME                   defaultValue:@"NavierHUD"];
    [self checkKey:CONFIG_NAVIER_VERSION                defaultValue:@"0.0.0"];
    [self checkKey:CONFIG_DEVICE_MACHINE_NAME           defaultValue:@"unknown"];
    [self checkKey:CONFIG_DEVICE_SYSTEM_NAME            defaultValue:@"unknown"];
    [self checkKey:CONFIG_DEVICE_SYSTEM_VERSION         defaultValue:@"unknown"];
    [self checkKey:CONFIG_DEVICE_SCREEN                 defaultValue:@"unknown"];
    [self checkKey:CONFIG_LOCALE                        defaultValue:@"unknown"];
    [self checkKey:CONFIG_TRIGGER_LOCATION_INTERVAL     defaultValue:[NSString stringFromInt:0]];
    
    [self save];
    
}

+(void) checkKey:(NSString*) key defaultValue:(NSString*) defaultValue
{
    id value;
    if ([key hasPrefix:@"@"])
    {
        value = [_hiddenConfigFile objectForKey:key];
        
        if (nil == value)
        {
            [_hiddenConfigFile setObjectForKey:key object:defaultValue];
        }
    }
    else
    {
        value = [_configFile objectForKey:key];

        if (nil == value)
        {
            [_configFile setObjectForKey:key object:defaultValue];
        }
    }
}

+(void) save
{
    [_configFile save];
}

@end
