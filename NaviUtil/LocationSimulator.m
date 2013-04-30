//
//  LocationSimulator.m
//  NaviUtil
//
//  Created by Coming on 13/3/28.
//  Copyright (c) 2013年 Coming. All rights reserved.
//

#import "LocationSimulator.h"

@implementation LocationSimulator

@synthesize delegate=_delegate;
@synthesize timeInterval=_timeInterval;


-(id) init
{
    self = [super init];
    if(self)
    {
        self.timeInterval   = 1;
        nextLocationIndex   = 0;
        isStart             = false;
    }
    return self;
}

-(CLLocationCoordinate2D) getNextLocation
{
    int i = nextLocationIndex;
    double lngOffset = [self GetRandomDouble];
    double latOffset = [self GetRandomDouble];

    CLLocationCoordinate2D tmpLocationCoordinate2D = CLLocationCoordinate2DMake(0, 0);
    if(nextLocationIndex == 0)
    {
        tmpLocationCoordinate2D = [[self.locationPoints objectAtIndex:0] CLLocationCoordinate2DValue];
        currentLocation = [[CLLocation alloc] initWithLatitude:tmpLocationCoordinate2D.latitude + latOffset
                                                     longitude:tmpLocationCoordinate2D.longitude + lngOffset];
        nextLocationIndex++;
    }
    else if(nextLocationIndex < self.locationPoints.count)
    {
        for(i = nextLocationIndex; i<self.locationPoints.count; i++)
        {
            tmpLocationCoordinate2D = [[self.locationPoints objectAtIndex:i] CLLocationCoordinate2DValue];
            nextLocation = [[CLLocation alloc] initWithLatitude:tmpLocationCoordinate2D.latitude + latOffset
                                                      longitude:tmpLocationCoordinate2D.longitude + lngOffset];
            if([nextLocation distanceFromLocation:currentLocation] > 10.0)
                break;
        }
        currentLocation = nextLocation;
        nextLocationIndex = i;
    }
    
    mlogInfo(LOCATION_SIMULATOR, @"%.7f, %.7f +- (%.7f, %.7f)\n",
             currentLocation.coordinate.latitude,
             currentLocation.coordinate.longitude,
             latOffset,
             lngOffset
             );
    return currentLocation.coordinate;
}

-(double) GetRandomDouble
{
    int index = arc4random() % 6 - 3;

    return index/10000.0;
}

-(void) updateLocation
{
    CLLocationCoordinate2D locationCoordinate2D = [self getNextLocation];
    if (self.delegate)
    {
        if([self.delegate respondsToSelector:@selector(locationUpdate:)])
        {
            [self.delegate locationUpdate:locationCoordinate2D];
        }
    }
}

-(void) timeout:(NSTimer *)theTimer
{
    if (nextLocationIndex >= self.locationPoints.count)
    {
        [self stop];
    }
    else
    {
       [self updateLocation];
    }
}

-(void) start
{
    if(true == isStart)
    {
        [self stop];
    }
    timer   = [NSTimer scheduledTimerWithTimeInterval:self.timeInterval target:self selector:@selector(timeout:) userInfo:nil repeats:YES];
    isStart = true;
}

-(void) stop
{
    [timer invalidate];
    isStart = false;
}

@end
