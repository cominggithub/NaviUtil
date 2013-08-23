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

typedef enum
{
    kSystemManager_Path_Document,
    kSystemManager_Path_Route,
    kSystemManager_Path_Track,
    kSystemManager_Path_Place,
    kSystemManager_Path_Log,
    kSystemManager_Path_User,
    kSystemManager_Path_Speech,
    kSystemManager_Path_Config,
    kSystemManager_Path_Max
}SystemManagerPathType;

@protocol SystemManagerDelegate <NSObject>
@optional -(void) networkStatusChangeWifi:(float) wifiStatus threeG:(float) threeGStatus;
@optional -(void) gpsStatusChange:(float) status;
@optional -(void) batteryStatusChange:(float) status;
@end

@interface SystemManager : NSObject
{

}

+(NSString *) documentPath;
+(CGRect) lanscapeScreenRect;
+(CGRect) screenRect;
+(void) init;
+(void) initDirectory;
+(NSString *) getSystemLanguage;
+(NSString *) getSupportLanguage;
+(CLLocationCoordinate2D) getDefaultLocation;
+(NSString*) getUsedMemoryStr;
+(NSString *) getLanguageString:(NSString*) stringIndex;
+(NSString *) getPath:(SystemManagerPathType) pathType;
+(void) updateNetworkStatus;
+(void) addDelegate: (id<SystemManagerDelegate>) delegate;
+(void) removeDelegate: (id<SystemManagerDelegate>) delegate;

+(float) getWifiStatus;
+(float) getThreeGStatus;
+(float) getBatteryLife;
+(float) getGpsStatus;
+(float) getNetworkStatus;

@end

