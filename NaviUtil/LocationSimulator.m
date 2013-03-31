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
    CLLocationCoordinate2D tmpLocationCoordinate2D = CLLocationCoordinate2DMake(0, 0);
    logi(nextLocationIndex);
    logi(self.locationPoints.count);
    if(nextLocationIndex == 0)
    {
        logfn();
        tmpLocationCoordinate2D = [[self.locationPoints objectAtIndex:0] CLLocationCoordinate2DValue];
        currentLocation = [[CLLocation alloc] initWithLatitude:tmpLocationCoordinate2D.latitude longitude:tmpLocationCoordinate2D.longitude];
        nextLocationIndex++;
    }
    else if(nextLocationIndex < self.locationPoints.count)
    {
        logfn();
        for(i = nextLocationIndex; i<self.locationPoints.count; i++)
        {
            logfn();
            tmpLocationCoordinate2D = [[self.locationPoints objectAtIndex:i] CLLocationCoordinate2DValue];
            nextLocation = [[CLLocation alloc] initWithLatitude:tmpLocationCoordinate2D.latitude longitude:tmpLocationCoordinate2D.longitude];
            if([nextLocation distanceFromLocation:currentLocation] > 10.0)
                break;
        }
        logfn();
        currentLocation = nextLocation;
        nextLocationIndex = i;
    }
    
    mlogInfo(LOCATION_SIMULATOR, @"%.7f, %.7f\n", currentLocation.coordinate.latitude, currentLocation.coordinate.longitude);
    return currentLocation.coordinate;
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
