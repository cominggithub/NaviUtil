//
//  NaviUtil.h
//  NaviUtil
//
//  Created by Coming on 13/2/28.
//  Copyright (c) 2013年 Coming. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DownloadManager.h"
#import "DownloadRequest.h"
#import "FileDownloader.h"
#import "GeoUtil.h"
#import "GuideRouteUIView.h"
#import "Log.h"
#import "NaviQueryManager.h"
#import "NSString+category.h"
#import "NSValue+category.h"
#import "NSDictionary+category.h"
#import "Place.h"
#import "Route.h"
#import "RouteInstruction.h"
#import "Speech.h"
#import "SystemManager.h"
#import "User.h"

@interface NaviUtil : NSObject

+(void) setGoogleAPIKey:(NSString*) key;
+(void) setGooglePlaceAPIKey:(NSString*) key;
+(NSString*) getGoogleAPIKey;
+(NSString*) getGooglePlaceAPIKey;
+(void) init;
@end
