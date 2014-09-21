//
//  CumulativeDistanceCaculator.m
//  NaviUtil
//
//  Created by Coming on 9/21/14.
//  Copyright (c) 2014 Coming. All rights reserved.
//

#import "CumulativeDistanceCalculator.h"
#import "GeoUtil.h"

@interface CumulativeDistanceCalculator()
@property (nonatomic) double cumulativeDistance;
@end

@implementation CumulativeDistanceCalculator

-(void)setLocation:(CLLocationCoordinate2D)location
{
    
    double distance;
    // skip init location
    
    if ((self.location.latitude == 0 && self.location.latitude == 0) || (location.latitude == 0 && location.longitude == 0))
    {
        _location = CLLocationCoordinate2DMake(location.latitude, location.longitude);
        return;
    }
    
    distance = [GeoUtil getGeoDistanceFromLocation:self.location ToLocation:location];
    _location = CLLocationCoordinate2DMake(location.latitude, location.longitude);
    
    self.cumulativeDistance = self.cumulativeDistance + distance;
    
}


@end
