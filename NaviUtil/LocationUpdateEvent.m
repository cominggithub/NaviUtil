//
//  LocationUpdateEvent.m
//  NaviUtil
//
//  Created by Coming on 9/17/14.
//  Copyright (c) 2014 Coming. All rights reserved.
//

#import "LocationUpdateEvent.h"

@implementation LocationUpdateEvent

-(id) initWitchCLLocationCoordinate2D:(CLLocationCoordinate2D) location speed:(double) speed distance:(int) distance heading:(double) heading
{
    self = [super init];
    if (self)
    {
        self.location = location;
        self.speed = speed;
        self.distance = distance;
        self.heading = heading;
    }
    return self;
}
@end
