//
//  SystemConfig.h
//  NaviUtil
//
//  Created by Coming on 13/6/19.
//  Copyright (c) 2013年 Coming. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIColor.h>



#define CONFIG_H_IS_DEBUG                       @"@IsDebug"
#define CONFIG_H_IS_AD                          @"@IsAd"
#define CONFIG_H_IS_USER_PLACE                  @"@IsUserPlace"
#define CONFIG_H_IS_MANUAL_PLACE                @"@IsManualPlace"
#define CONFIG_H_IS_DEBUG_ROUTE_DRAW            @"@IsDebugRouteDraw"
#define CONFIG_H_IS_LOCATION_UPDATE_FILTER      @"@IsLocationUpdateFilter"
#define CONFIG_H_IS_LOCATION_SIMULATOR          @"@IsLocationSimulator"
#define CONFIG_H_IS_SIMULATE_LOCATION_LOST      @"@IsSimulateLocationLost"
#define CONFIG_H_IS_SIMULATE_OUT_OF_ROUTE_LINE  @"@IsSimulateOutOfRouteLine"
#define CONFIG_H_IS_SIMULATE_CAR_MOVEMENT       @"@IsSimulateCarMovement"

#define CONFIG_IS_SPEECH                     @"IsSpeech"
#define CONFIG_TRIGGER_LOCATION_INTERVAL     @"TriggerLocationUpdateInterval"
#define CONFIG_TURN_ANGLE_BEFORE_DISTANCE    @"TurnAngleBeforeDistance"
#define CONFIG_TURN_ANGLE_BEFORE_TIME        @"TurnAngleBeforeTime"
#define CONFIG_TARGET_ANGLE_DISTANCE         @"TargetAngleDistance"
#define CONFIG_DEFAULT_COLOR                 @"DefaultColor"
#define CONFIG_IS_SPEED_UNIT_MPH             @"IsSpeedUnitMPH"
#define CONFIG_NUMBER_OF_COLOR               @"NumberOfColor"
#define CONFIG_MAX_OUT_OF_ROUTELINE_COUNT    @"MaxOutOfRouteLineCount"
#define CONFIG_MAX_OUT_OF_ROUTELINE_TIME     @"MaxOutOfRouteLineTime"
#define CONFIG_DEFAULT_TRACK_FILE            @"DefaultTrack"
#define CONFIG_DEFAULT_ROUTE_FILE            @"DefaultRoute"
#define CONFIG_IS_TRACK_FILE                 @"IsTrackFile"
#define CONFIG_IS_TRACK_LOCATION             @"IsTrackLocation"
#define CONFIG_DEFAULT_BRIGHTNESS            @"DefaultBrightness"
#define CONFIG_ROUTE_PLAN_TIMEOUT            @"RoutePlanTimeout"


#define CONFIG_NAVIER_NAME                   @"NavierName"
#define CONFIG_NAVIER_VERSION                @"NavierVersion"

#define CONFIG_DEVICE_MACHINE_NAME           @"DeviceMachineName"
#define CONFIG_DEVICE_SYSTEM_NAME            @"DeviceSystemName"
#define CONFIG_DEVICE_SYSTEM_VERSION         @"DeviceSystemVersion"
#define CONFIG_DEVICE_SCREEN                 @"DeviceScreen"
#define CONFIG_LOCALE                        @"LOCALE"
#define CONFIG_USE_COUNT                     @"UseCount"


#define CONFIG_IS_SHARE_ON_FB                @"SHARE_ON_FB"
#define CONFIG_IS_SHARE_ON_TWITTER           @"SHARE_ON_TWITTER"



#define CONFIG_IAP_IS_ADVANCED_VERSION      @"IAP_AdvancedVersion"
#define CONFIG_IAP_IS_CAR_PANEL_2           @"IAP_CarPanel2"
#define CONFIG_IAP_IS_CAR_PANEL_3           @"IAP_CarPanel3"
#define CONFIG_IAP_IS_CAR_PANEL_4           @"IAP_CarPanel4"

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

+ (BOOL)init;
+ (NSString*)getStringValue:(NSString*) key;
+ (int)getIntValue:(NSString*) key;
+ (double)getDoubleValue:(NSString*) key;
+ (float)getFloatValue:(NSString*) key;
+ (BOOL)getBoolValue:(NSString*) key;
+ (UIColor*)getUIColorValue:(NSString*) key;
//+ (NSObject*)getUIColorValue:(NSString*) key;
+ (void)setValue:(NSString*) key int:(int) value;
+ (void)setValue:(NSString*) key double:(double) value;
+ (void)setFloatValue:(NSString*) key float:(float) value;
+ (void)setValue:(NSString*) key BOOL:(BOOL) value;

+ (void)setValue:(NSString*) key uicolor:(UIColor*) value;
//+ (void)setValue:(NSString*) key uicolor:(NSObject*) value;
+(void) setValue:(NSString*) key string:(NSString*) value;
+ (void)removeIAPItem:(NSString*) key;
+ (void)addIAPItem:(NSString*) key;
+ (BOOL)hasIAPItem:(NSString*) key;
+ (void)save;

+ (void)setFloatValue:(float)value forKey:(NSString *)key;
+ (void)setValueGGGswers:(NSString*) key BOOL:(BOOL) value;
@end
