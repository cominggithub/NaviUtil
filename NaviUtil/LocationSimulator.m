//
//  LocationSimulator.m
//  NaviUtil
//
//  Created by Coming on 13/3/28.
//  Copyright (c) 2013年 Coming. All rights reserved.
//

#import "LocationSimulator.h"

#define FILE_DEBUG FALSE
#include "Log.h"

@implementation LocationSimulator
{
    CLLocationCoordinate2D _lastLocationCoordinate2D;
    float _locationCoordinate2DChangeStep;
    double _speedCnt;
    double _courseCnt;
}
@synthesize delegate=_delegate;
@synthesize timeInterval=_timeInterval;


-(id) init
{
    self = [super init];
    if(self)
    {
        _timeInterval                   = 2000; // in millisecond
        _nextLocationIndex              = 0;
        _isStart                        = false;
        _type                           = kLocationSimulator_ManualRoute;
        _lastLocationCoordinate2D       = CLLocationCoordinate2DMake(0, 0);
        _locationCoordinate2DChangeStep = 0.00005;
        _speedCnt                       = 0;
        _courseCnt                      = 0;
        
    }
    return self;
}


-(CLLocationCoordinate2D) getNextLineLocation
{
    double lngOffset = (arc4random() % 30)/10000.0;
    
    _lastLocationCoordinate2D.longitude += _locationCoordinate2DChangeStep + lngOffset;
    
    return _lastLocationCoordinate2D;
    
}

-(CLLocationCoordinate2D) getNextRouteLocation
{
    int i = _nextLocationIndex;
    double lngOffset = [self GetRandomDouble];
    double latOffset = [self GetRandomDouble];

    CLLocationCoordinate2D tmpLocationCoordinate2D = CLLocationCoordinate2DMake(0, 0);
    if(_nextLocationIndex == 0)
    {
        tmpLocationCoordinate2D = [[self.locationPoints objectAtIndex:0] CLLocationCoordinate2DValue];
        _currentLocation = [[CLLocation alloc] initWithCoordinate:
                            CLLocationCoordinate2DMake(tmpLocationCoordinate2D.latitude + latOffset,
                                                       tmpLocationCoordinate2D.longitude + lngOffset)
                                                         altitude:0.0
                                               horizontalAccuracy:1.0
                                                 verticalAccuracy:1.0
                                                           course:_courseCnt
                                                            speed:_speedCnt
                                                        timestamp:[NSDate date]];
        
        _nextLocationIndex++;
    }
    else if(_nextLocationIndex < self.locationPoints.count)
    {
        for(i = _nextLocationIndex; i<self.locationPoints.count; i++)
        {
            tmpLocationCoordinate2D = [[self.locationPoints objectAtIndex:i] CLLocationCoordinate2DValue];
            _nextLocation = [[CLLocation alloc] initWithCoordinate:
                             CLLocationCoordinate2DMake(tmpLocationCoordinate2D.latitude + latOffset,
                                                        tmpLocationCoordinate2D.longitude + lngOffset)
                                                          altitude:0.0
                                                horizontalAccuracy:1.0
                                                  verticalAccuracy:1.0
                                                            course:_courseCnt
                                                             speed:_speedCnt
                                                         timestamp:[NSDate date]];
            

            
            
            if([_nextLocation distanceFromLocation:_currentLocation] > 10.0)
                break;
        }
        _currentLocation = _nextLocation;
        _nextLocationIndex = i+1;
    }
    
    _speedCnt   += 0.1;
    _courseCnt  += 1;
    _courseCnt  = (int)(_courseCnt)%362;
    
/*
    mlogDebug(@"%.7f, %.7f +- (%.7f, %.7f)\n",
             _currentLocation.coordinate.latitude,
             _currentLocation.coordinate.longitude,
             latOffset,
             lngOffset
             );
*/    
    _lastLocationCoordinate2D = _currentLocation.coordinate;
    return _currentLocation.coordinate;
}

-(double) GetRandomDouble
{
    int index = arc4random() % 30 - 15;

    return index/100000.0;
}

-(void) updateLocation
{
    CLLocationCoordinate2D locationCoordinate2D;
    switch (self.type)
    {
        case kLocationSimulator_Line:
            locationCoordinate2D = [self getNextLineLocation];
            break;
        case kLocationSimulator_ManualRoute:
            locationCoordinate2D = [self getNextRouteLocation];
            break;
            
    }
    
    CLLocation* location = [[CLLocation alloc] initWithCoordinate:locationCoordinate2D altitude:0.0 horizontalAccuracy:1.0 verticalAccuracy:1.0 course:_courseCnt speed:_speedCnt timestamp:[NSDate date]];

    _speedCnt   += 0.1;
    _courseCnt  += 1;
    _courseCnt  = (int)(_courseCnt)%362;
    
    if (self.delegate)
    {
        if([self.delegate respondsToSelector:@selector(locationManager:didUpdateLocations:)])
        {
            [self.delegate locationManager:nil
                        didUpdateLocations:[NSArray arrayWithObject:location]];
        }
    }
    
}

-(void) timeout:(NSTimer *)theTimer
{
    if (_type == kLocationSimulator_ManualRoute && _nextLocationIndex >= self.locationPoints.count)
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

    if(true == _isStart)
    {
        [self stop];
    }
    _timer   = [NSTimer scheduledTimerWithTimeInterval:self.timeInterval/1000.0 target:self selector:@selector(timeout:) userInfo:nil repeats:YES];
    _isStart = true;
}

-(void) stop
{
    if (nil != _timer)
    {
        [_timer invalidate];
        _timer      = nil;
    }
    _isStart    = false;
}

-(void) triggerLocationUpdate
{
    [self updateLocation];
}

-(void) setRoute:(Route*) route;
{
    self.locationPoints = [route getRoutePolyLineCLLocationCoordinate2D];
}
@end
