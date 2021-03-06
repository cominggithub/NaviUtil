//
//  NaviUtil.h
//  NaviUtil
//
//  Created by Coming on 13/2/28.
//  Copyright (c) 2013年 Coming. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Appirater.h"
#import "BatteryLifeView.h"
#import "CarPanelSetting.h"
#import "CarPanelUsage.h"
#import "CarPanel1UIView.h"
#import "DigitalNumDrawBlock.h"
#import "DownloadManager.h"
#import "DownloadRequest.h"
#import "DrawBlock.h"
#import "FBUtil.h"
#import "FileDownloader.h"
#import "GeoUtil.h"
#import "GoogleUtil.h"
#import "GuideRouteUIView.h"
#import "LocationManager.h"
#import "LocationSimulator.h"
#import "MapManager.h"
#import "NaviQueryManager.h"
#import "NSString+category.h"
#import "NSValue+category.h"
#import "NSDictionary+category.h"
#import "NavierHUDIAPHelper.h"
#import "UIView+category.h"
#import "UILabel+category.h"
#import "UIImageView+category.h"
#import "UIColor+category.h"
#import "UIFont+category.h"
#import "Place.h"
#import "Route.h"
#import "RouteInstruction.h"
#import "SoundUtil.h"
#import "Speech.h"
#import "SystemConfig.h"
#import "SystemManager.h"
#import "TimeDrawBlock.h"
#import "TwitterUtil.h"
#import "User.h"
#import "UIAnimation.h"

@interface NaviUtil : NSObject

+(void) setGoogleAPIKey:(NSString*) key;
+(void) setGooglePlaceAPIKey:(NSString*) key;
+(NSString*) getGoogleAPIKey;
+(NSString*) getGooglePlaceAPIKey;
+(void) init;
@end
