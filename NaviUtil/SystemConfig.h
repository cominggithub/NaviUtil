//
//  SystemConfig.h
//  NaviUtil
//
//  Created by Coming on 13/6/19.
//  Copyright (c) 2013年 Coming. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SystemConfig : NSObject

+(BOOL) init;
+(BOOL) isDebug;
+(void) setIsDebug:(BOOL) value;
+(BOOL) isAd;
+(void) setIsAd:(BOOL) value;
+(BOOL) isManualPlace;
+(void) setIsManualPlace:(BOOL) value;
+(BOOL) isDebugRouteDraw;
+(void) setIsDebugRouteDraw:(BOOL) value;

+(BOOL) isSpeech;
+(void) setIsSpeech:(BOOL) value;

+(BOOL) isLocationUpdateFilter;
+(void) setLocationUpdateFilter:(BOOL) value;


+(double) triggerLocationInterval;// in millisecond
+(void) setTriggerLocationInterval:(double) value;

+(double) turnAngleDistance;
+(void) setTurnAngleDistance:(double) value;

+(double) targetAngleDistance;
+(void) setTargetAngleDistance:(double) value;

@end
