//
//  SystemConfig.h
//  NaviUtil
//
//  Created by Coming on 13/6/19.
//  Copyright (c) 2013年 Coming. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#define CONFIG_IS_DEBUG                      @"IsDebug"
#define CONFIG_IS_AD                         @"IsAd"
#define CONFIG_IS_MANUAL_PLACE               @"IsManualPlace"
#define CONFIG_IS_DEBUG_ROUTE_DRAW           @"IsDebugRouteDraw"
#define CONFIG_IS_SPEECH                     @"IsSpeech"
#define CONFIG_IS_LOCATION_UPDATE_FILTER     @"IsLocationUpdateFilter"
#define CONFIG_TRIGGER_LOCATION_INTERVAL     @"TriggerLocationUpdateInterval"
#define CONFIG_TURN_ANGLE_DISTANCE           @"TurnAngleDistance"
#define CONFIG_TARGET_ANGLE_DISTANCE         @"TargetAngleDistance"
#define CONFIG_DEFAULT_COLOR                 @"DefaultColor"
#define CONFIG_IS_SPEED_UNIT_MPH             @"IsSpeedUnitMPH"
#define CONFIG_NUMBER_OF_COLOR               @"NumberOfColor"


/* for car panel 1 */
#define CONFIG_CP1_COLOR                    @"CP1_Color"
#define CONFIG_CP1_IS_HUD                   @"CP1_IsHud"
#define CONFIG_CP1_IS_COURSE                @"CP1_IsCourse"
#define CONFIG_CP1_IS_SPEED_UNIT_MPH        @"CP1_IsSpeedUnitMPH"




@interface SystemConfig : NSObject

+(BOOL) init;

+(int) getIntValue:(NSString*) key;
+(double) getDoubleValue:(NSString*) key;
+(float) getFloatValue:(NSString*) key;
+(BOOL) getBoolValue:(NSString*) key;
+(UIColor*) getUIColorValue:(NSString*) key;
+(void) setValue:(NSString*) key int:(int) value;
+(void) setValue:(NSString*) key double:(double) value;
+(void) setValue:(NSString*) key float:(float) value;
+(void) setValue:(NSString*) key BOOL:(BOOL) value;
+(void) setValue:(NSString*) key uicolor:(UIColor*) value;
+(void) save;

@end
