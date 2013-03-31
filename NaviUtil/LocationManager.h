//
//  LocationManager.h
//  NaviUtil
//
//  Created by Coming on 13/3/28.
//  Copyright (c) 2013年 Coming. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import "log.h"

@protocol LocationManagerDelegate <NSObject>

-(void) locationUpdate:(CLLocationCoordinate2D) location;
-(void) speedUpdate:(int) speed;
@end

@interface LocationManager : NSObject<CLLocationManagerDelegate>
{
    CLLocationManager* clLocationManager;
}
- (void)locationManager:(CLLocationManager *)manager
    didUpdateToLocation:(CLLocation *)newLocation
           fromLocation:(CLLocation *)oldLocation;

- (void)locationManager:(CLLocationManager *)manager
     didUpdateLocations:(NSArray *)locations;

@property (nonatomic, weak) id<LocationManagerDelegate> delegate;
@end
