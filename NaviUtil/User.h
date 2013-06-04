//
//  User.h
//  NaviUtil
//
//  Created by Coming on 13/3/17.
//  Copyright (c) 2013年 Coming. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SystemManager.h"
#import "Place.h"

@interface User : NSObject



+(void) init;
+(bool) parseJson:(NSString*) fileName;
+(void) save;
+(void) addHomePlace:(Place*) p;
+(void) addOfficePlace:(Place*) p;
+(void) addFavorPlace:(Place*) p;
+(void) addSearchedPlace:(NSString*) Place;
+(void) removeHomePlaceAtIndex:(int) index;
+(void) removeOfficePlaceAtIndex:(int) index;
+(void) removeFavorPlaceAtIndex:(int) index;
+(void) updateHomePlaceAtIndex:(int) index Place:(Place*) place;
+(void) updateOfficePlaceAtIndex:(int) index Place:(Place*) place;
+(void) updateFavorPlaceAtIndex:(int) index Place:(Place*) place;

+(Place*) getHomePlaceByIndex:(int) index;
+(Place*) getOfficePlaceByIndex:(int) index;
+(Place*) getFavorPlaceByIndex:(int) index;
+(int) getPlaceCountBySection:(int) section;
+(Place*) getPlaceBySection:(int) section index:(int) index;

+(NSString*) getSearchPlaceByIndex:(int) index;
+(NSString*) name;
+(NSString*) email;
+(NSArray*) homePlaces;
+(NSArray*) officePlaces;
+(NSArray*) favorPlaces;
+(NSArray*) searchedPlaces;

@end
