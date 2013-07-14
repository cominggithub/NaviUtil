//
//  LocationManager.h
//  NaviUtil
//
//  Created by Coming on 13/3/28.
//  Copyright (c) 2013年 Coming. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import "Place.h"
#import "Route.h"


@protocol LocationManagerDelegate <NSObject>

-(void) locationUpdate:(CLLocationCoordinate2D) location Speed:(int) speed Distance:(int) distance;
-(void) lostLocationUpdate;
@end

typedef enum
{
    kLocationManagerLocationUpdateType_ManualRoute,
    kLocationManagerLocationUpdateType_RealLocation,
    kLocationManagerLocationUpdateType_Line
    
}LocationManagerLocationUpdateType;

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
+(void) addDelegate: (id<LocationManagerDelegate>) delegate;

+(void) startMonitorLocation;
+(void) stopMonitorLocation;
+(void) startLocationSimulation;
+(void) stopLocationSimulation;
+(void) setLocationUpdateInterval;
+(void) triggerLocationUpdate;
+(void) setRoute:(Route*) route;
+(void) setLocationUpdateType:(LocationManagerLocationUpdateType) locationUpdateType;

-(void) locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations;
-(void) startMonitorLocationChange;
-(void) stopMonitorLocationChange;


@end
