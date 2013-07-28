//
//  SystemConfig.h
//  NaviUtil
//
//  Created by Coming on 13/6/19.
//  Copyright (c) 2013年 Coming. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#define CONFIG_IS_DEBUG                         @"isDebug"
#define CONFIG_IS_AD                         @"isAd"
#define CONFIG_IS_MANUAL_PLACE               @"isManualPlace"
#define CONFIG_IS_DEBUG_ROUTE_DRAW           @"isDebugRouteDraw"
#define CONFIG_IS_SPEECH                     @"isSpeech"
#define CONFIG_IS_LOCATION_UPDATE_FILTER     @"isLocationUpdateFilter"
#define CONFIG_TRIGGER_LOCATION_INTERVAL     @"TriggerLocationUpdateInterval"
#define CONFIG_TURN_ANGLE_DISTANCE           @"TurnAngleDistance"
#define CONFIG_TARGET_ANGLE_DISTANCE         @"TargetAngleDistance"
#define CONFIG_DEFAULT_COLOR                 @"DefaultColor"

@interface SystemConfig : NSObject

+(BOOL) init;

+(int) getIntValue:(NSString*) key;
+(double) getDoubleValue:(NSString*) key;
+(float) getFloatValue:(NSString*) key;
+(BOOL) getBOOLValue:(NSString*) key;
+(void) setValue:(NSString*) key int:(int) value;
+(void) setValue:(NSString*) key double:(double) value;
+(void) setValue:(NSString*) key float:(float) value;
+(void) setValue:(NSString*) key BOOL:(BOOL) value;

+(UIColor*) defaultColor;
+(void) setDefaultColor:(UIColor*) value;
+(void) save;

@end
