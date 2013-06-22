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

@end
