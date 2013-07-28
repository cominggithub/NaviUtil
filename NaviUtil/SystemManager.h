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

@interface SystemManager : NSObject

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

@end

