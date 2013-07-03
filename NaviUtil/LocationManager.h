//
//  LocationManager.h
//  NaviUtil
//
//  Created by Coming on 13/3/28.
//  Copyright (c) 2013年 Coming. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import "Log.h"
#import "Place.h"


@protocol LocationManagerDelegate <NSObject>

-(void) locationUpdate:(CLLocationCoordinate2D) location Speed:(int) speed Distance:(int) distance;
-(void) lostLocationUpdate;
@end

@interface LocationManager : NSObject<CLLocationManagerDelegate>
{
    CLLocationManager* clLocationManager;
}
@property (nonatomic, weak) id<LocationManagerDelegate> delegate;



+(void) init;
+(int) getManualPlaceCount;
+(Place*) getManualPlaceByIndex:(int) index;
+(void) setCurrentManualPlace:(Place*) p;
+(Place*) currentPlace;
+(void) addUpdatedCLLocations:(NSArray *) clLoctions;


- (void)locationManager:(CLLocationManager *)manager
     didUpdateLocations:(NSArray *)locations;

@end
