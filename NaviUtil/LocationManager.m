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

@end
