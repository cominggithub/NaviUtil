//
//  LocationManager.m
//  NaviUtil
//
//  Created by Coming on 13/3/28.
//  Copyright (c) 2013年 Coming. All rights reserved.
//

#import "LocationManager.h"

@implementation LocationManager

@synthesize delegate=_delegate;


-(id) init
{
    self = [super init];
    if(self)
    {
        logfn();
        clLocationManager = [[CLLocationManager alloc] init];
        clLocationManager.delegate = self;
        
        [clLocationManager startUpdatingLocation];
    }
    
    return self;
    
}

- (void)locationManager:(CLLocationManager *)manager
    didUpdateToLocation:(CLLocation *)newLocation
           fromLocation:(CLLocation *)oldLocation
{
    logfns("depre\n");
    logfn();
}

- (void)locationManager:(CLLocationManager *)manager
     didUpdateLocations:(NSArray *)locations
{
    if(self.delegate)
    {
        if( [self.delegate respondsToSelector:@selector(locationUpdate:)])
        {
            [self.delegate locationUpdate:((CLLocation*)[locations objectAtIndex:locations.count-1]).coordinate];
        }
    }
}

+(Place*) getCurrentPlace
{
    Place *p = [[Place alloc] init];
    p.name = [SystemManager getLanguageString:@"Current Location"];
    p.placeType = kPlaceType_CurrentLocation;
    p.coordinate = CLLocationCoordinate2DMake(22.9967080, 120.2198480);
//    p.coordinate = CLLocationCoordinate2DMake(23.099313,120.284371);

    
    return p;
}
@end
