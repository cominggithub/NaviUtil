//
//  Place.h
//  NavUtil
//
//  Created by Coming on 13/2/26.
//  Copyright (c) 2013年 Coming. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import "NSDictionary+category.h"
#import "GoogleJson.h"
#import "GeoUtil.h"

typedef enum PlaceType
{

    kPlaceType_None,
    kPlaceType_Home,
    kPlaceType_Office,
    kPlaceType_Favor,
    kPlaceType_SearchedPlace,
    kPlaceType_SearchedPlaceText,
    kPlaceType_CurrentPlace,
    kPlaceType_Max
    
}PlaceType;

typedef enum PlaceRouteType
{
    kPlaceRouteType_None = 0,
    kPlaceRouteType_Start,
    kPlaceRouteType_Middle,
    kPlaceRouteType_End,
    kPlaceRouteType_Max
    
}PlaceRouteType;

@interface Place : NSObject

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *address;
@property (nonatomic) CLLocationCoordinate2D coordinate;
@property (nonatomic) PlaceType placeType;
@property (nonatomic) PlaceRouteType placeRouteType;


+(NSArray*) parseJson:(NSString*) fileName;
+(Place*) parseDictionary:(NSDictionary*) dic;
+(Place*) newPlace:(NSString*) name Address:(NSString*) address Location:(CLLocationCoordinate2D) location;
-(NSDictionary*) toDictionary;
-(bool) isPlaceMatched:(NSString*) name;
-(bool) isCoordinateEqualTo:(Place*) p;
-(void) copyTo:(Place*) p;
@end
