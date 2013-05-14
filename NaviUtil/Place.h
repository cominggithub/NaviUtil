//
//  Place.h
//  NavUtil
//
//  Created by Coming on 13/2/26.
//  Copyright (c) 2013年 Coming. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

typedef enum PlaceType
{
    kPlaceType_None = 0,
    kPlaceType_Start,
    kPlaceType_End,
    kPlaceType_Middle,
    kPlaceType_Max
    
}PlaceType;

@interface Place : NSObject

@property (nonatomic, strong) NSString *name;
@property (nonatomic) CLLocationCoordinate2D coordinate;
@property (nonatomic) PlaceType placeType;


+(NSArray*) parseJson:(NSString*) fileName;

@end
