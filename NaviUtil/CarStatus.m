//
//  CarStatus.m
//  NaviUtil
//
//  Created by Coming on 4/26/14.
//  Copyright (c) 2014 Coming. All rights reserved.
//


#import "CarStatus.h"


@implementation CarStatus
{
    int zeroSpeedCount;
}
-(id) init
{
    self = [super init];
    if (self)
    {
        [self initSelf];
    }
    return self;
}

-(void) initSelf
{
    _location   = CLLocationCoordinate2DMake(0, 0);
    _speed      = 0;
    _heading    = 0;
    zeroSpeedCount = 0;
}

-(void) updateLocation:(CLLocationCoordinate2D)location speed:(double)speed heading:(double)heading
{

    _location   = location;
    _speed      = [self filterSpeed:speed];
    _heading    = heading;
}

-(double)filterSpeed:(double)speed
{
    if (speed == 0)
    {
        zeroSpeedCount++;
        if (zeroSpeedCount >= 2)
        {
            return 0;
        }
        else
        {
            return self.speed;
        }
    }
    
    return speed;
}
-(float) getMoveTimeByDistance:(double) distance
{
    // speed is meter/s
    // distance is in terms of meter
    
    if (_speed == 0)
        return DBL_MAX;
    else
        return distance/_speed;
    
}
@end
