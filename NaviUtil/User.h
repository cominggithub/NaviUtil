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
+(void) addHomeLocation:(Place*) p;
+(void) addOfficeLocation:(Place*) p;
+(void) addFavorLocation:(Place*) p;
+(void) addSearchedLocation:(NSString*) location;
+(void) removeHomeLocationAtIndex:(int) index;
+(void) removeOfficeLocationAtIndex:(int) index;
+(void) removeFavorLocationAtIndex:(int) index;
+(void) updateHomeLocationAtIndex:(int) index Location:(Place*) place;
+(void) updateOfficeLocationAtIndex:(int) index Location:(Place*) place;
+(void) updateFavorLocationAtIndex:(int) index Location:(Place*) place;

+(Place*) getHomeLocationByIndex:(int) index;
+(Place*) getOfficeLocationByIndex:(int) index;
+(Place*) getFavorLocationByIndex:(int) index;
+(NSString*) getSearchPlaceByIndex:(int) index;
+(NSString*) name;
+(NSString*) email;
+(NSArray*) homeLocations;
+(NSArray*) officeLocations;
+(NSArray*) favorLocations;
+(NSArray*) searchedLocations;

@end
