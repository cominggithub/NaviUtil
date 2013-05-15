//
//  User.h
//  NaviUtil
//
//  Created by Coming on 13/3/17.
//  Copyright (c) 2013年 Coming. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SystemManager.h"
#import "Location.h"
#import "Place.h"

@interface User : NSObject



+(void) init;
+(bool) parseJson:(NSString*) fileName;
+(void) save;
+(void) addSearchedPlace:(NSString*) place;
+(NSString*) getSearchPlaceByIndex:(int) index;
+(NSString*) name;
+(NSString*) email;
+(Location*) homeLocation;
+(NSArray*) officeLocations;
+(NSArray*) favorLocations;
+(NSArray*) searchedPlaces;

@end
