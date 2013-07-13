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

typedef enum
{
    kSectionMode_Home,
    kSectionMode_Office,
    kSectionMode_Favor,
    kSectionMode_Home_Office_Favor,
    kSectionMode_Home_Office_Favor_Searched,
    kSectionMode_Home_Office_Favor_SearchedText,
    kSectionMode_Max
}SectionMode;


+(void) init;
+(bool) parseJson:(NSString*) fileName;
+(void) save;
+(void) addHomePlace:(Place*) p;
+(void) addOfficePlace:(Place*) p;
+(void) addFavorPlace:(Place*) p;
+(void) addSearchedPlace:(Place*) p;
+(void) addSearchedPlaceText:(NSString*) PlaceText;
+(void) removeHomePlaceAtIndex:(int) index;
+(void) removeOfficePlaceAtIndex:(int) index;
+(void) removeFavorPlaceAtIndex:(int) index;
+(void) updateHomePlaceAtIndex:(int) index place:(Place*) place;
+(void) updateOfficePlaceAtIndex:(int) index place:(Place*) place;
+(void) updateFavorPlaceAtIndex:(int) index place:(Place*) place;

+(Place*) getHomePlaceByIndex:(int) index;
+(Place*) getOfficePlaceByIndex:(int) index;
+(Place*) getFavorPlaceByIndex:(int) index;


+(int) getSectionCount:(SectionMode) sectionMode;
+(int) getPlaceCountBySectionMode:(SectionMode) sectionMode section:(int) section;
+(Place*) getPlaceBySectionMode:(SectionMode) sectionMode section:(int) section index:(int) index;
+(void) addPlaceBySectionMode:(SectionMode) sectionMode section:(int) section place:(Place*) p;

+(NSString*) getSearchedPlaceTextByIndex:(int) index;
+(NSString*) name;
+(NSString*) email;
+(NSArray*) homePlaces;
+(NSArray*) officePlaces;
+(NSArray*) favorPlaces;
+(NSArray*) searchedPlaces;
+(NSArray*) searchedPlaceText;

@end
