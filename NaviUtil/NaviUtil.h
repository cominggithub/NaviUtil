//
//  NaviUtil.h
//  NaviUtil
//
//  Created by Coming on 13/2/28.
//  Copyright (c) 2013年 Coming. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BatteryLifeView.h"
#import "CarPanel1UIView.h"
#import "DigitalNumDrawBlock.h"
#import "DownloadManager.h"
#import "DownloadRequest.h"
#import "DrawBlock.h"
#import "FileDownloader.h"
#import "GeoUtil.h"
#import "GuideRouteUIView.h"
#import "LocationManager.h"
#import "LocationSimulator.h"
#import "MapPlaceManager.h"
#import "NaviQueryManager.h"
#import "NSString+category.h"
#import "NSValue+category.h"
#import "NSDictionary+category.h"
#import "UIView+category.h"
#import "UILabel+category.h"
#import "UIImageView+category.h"
#import "UIColor+category.h"
#import "UIFont+category.h"
#import "Place.h"
#import "Route.h"
#import "RouteInstruction.h"
#import "Speech.h"
#import "SystemConfig.h"
#import "SystemManager.h"
#import "TestFlight.h"
#import "TimeDrawBlock.h"
#import "User.h"
#import "UIAnimation.h"

@interface NaviUtil : NSObject

+(void) setGoogleAPIKey:(NSString*) key;
+(void) setGooglePlaceAPIKey:(NSString*) key;
+(NSString*) getGoogleAPIKey;
+(NSString*) getGooglePlaceAPIKey;
+(void) init;
@end
