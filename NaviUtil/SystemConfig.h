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
#define CONFIG_IS_USER_PLACE                 @"IsUserPlace"
#define CONFIG_IS_MANUAL_PLACE               @"IsManualPlace"
#define CONFIG_IS_DEBUG_ROUTE_DRAW           @"IsDebugRouteDraw"
#define CONFIG_IS_SPEECH                     @"IsSpeech"
#define CONFIG_IS_LOCATION_UPDATE_FILTER     @"IsLocationUpdateFilter"
#define CONFIG_IS_LOCATION_SIMULATOR         @"IsLocationSimulator"
#define CONFIG_TRIGGER_LOCATION_INTERVAL     @"TriggerLocationUpdateInterval"
#define CONFIG_TURN_ANGLE_DISTANCE           @"TurnAngleDistance"
#define CONFIG_TARGET_ANGLE_DISTANCE         @"TargetAngleDistance"
#define CONFIG_DEFAULT_COLOR                 @"DefaultColor"
#define CONFIG_IS_SPEED_UNIT_MPH             @"IsSpeedUnitMPH"
#define CONFIG_NUMBER_OF_COLOR               @"NumberOfColor"
#define CONFIG_MAX_OUT_OF_ROUTELINE_COUNT    @"MaxOutOfRouteLineCount"
#define CONFIG_DEFAULT_TRACK_FILE            @"DefaultTrack"
#define CONFIG_DEFAULT_ROUTE_FILE            @"DefaultRoute"
#define CONFIG_IS_TRACK_FILE                 @"IsTrackFile"

#define CONFIG_IAP_IS_NO_AD                  @"IAP_IsNoAd"
#define CONFIG_IAP_IS_USER_PLACE             @"IAP_IsUserPlace"


/* for car panel 1 */
#define CONFIG_CP1_COLOR                    @"CP1_Color"
#define CONFIG_CP1_IS_HUD                   @"CP1_IsHud"
#define CONFIG_CP1_IS_COURSE                @"CP1_IsCourse"
#define CONFIG_CP1_IS_SPEED_UNIT_MPH        @"CP1_IsSpeedUnitMPH"

/* for route navigation 1 */
#define CONFIG_RN1_COLOR                    @"RN1_Color"
#define CONFIG_RN1_IS_HUD                   @"RN1_IsHud"
#define CONFIG_RN1_IS_COURSE                @"RN1_Course"
#define CONFIG_RN1_IS_SPEED_UNIT_MPH        @"RN1_IsSpeedUnitMPH"


@interface SystemConfig : NSObject

+(BOOL) init;

+(NSString*) getStringValue:(NSString*) key;
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
