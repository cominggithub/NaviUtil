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
#import "Log.h"
#import "GeoUtil.h"

typedef enum PlaceType
{
    kPlaceType_None = 0,
    kPlaceType_Home,
    kPlaceType_Office,
    kPlaceType_Favor,
    kPlaceType_Max
    
}PlaceType;

typedef enum PlaceRouteType
{
    kPlaceRouteType_None = 0,
    kPlaceRouteType_Start,
    kPlaceRouteType_Middle,
    kPlaceRouteType_Favor,
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
-(NSDictionary*) toDictionary;
-(bool) isPlaceMatched:(NSString*) name;
-(bool) isCoordinateEqualTo:(Place*) p;
@end
