//
//  SystemManager.h
//  NavUtil
//
//  Created by Coming on 13/2/27.
//  Copyright (c) 2013年 Coming. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import <UIKit/UIKit.h>
#import "Reachability.h"

@interface SystemManager : NSObject

+(NSString *) documentPath;
+(NSString *) routeFilePath;
+(NSString *) placeFilePath;
+(NSString *) speechFilePath;
+(NSString *) logFilePath;
+(NSString *) userFilePath;
+(CGRect) lanscapeScreenRect;
+(CGRect) screenRect;
+(void) init;
+(void) initDirectory;
+(NSString *) getSystemLanguage;
+(NSString *) getSupportLanguage;
+(CLLocationCoordinate2D) getDefaultLocation;
+(NSString*) getUsedMemoryStr;
+(NSString *) getLanguageString:(NSString*) stringIndex;


@end

