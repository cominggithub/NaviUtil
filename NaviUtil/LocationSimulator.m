//
//  LocationSimulator.m
//  NaviUtil
//
//  Created by Coming on 13/3/28.
//  Copyright (c) 2013年 Coming. All rights reserved.
//

#import "LocationSimulator.h"
#import "SystemConfig.h"

#define LOCATION_UPDATE_INTERVAL 1000
#define SIMULATION_SPEED 60 // in kmh
#define FILE_DEBUG TRUE
#include "Log.h"

@implementation LocationSimulator
{
    CLLocationCoordinate2D _lastLocationCoordinate2D;
    float _locationCoordinate2DChangeStep;
    double speedCnt;
    double courseCnt;
    BOOL _isTrackFileLoaded;
    NSMutableArray *_locationsOfTraceFile;
    int _locationIndexOfTrackFile;
    
    NSArray *routeLineCoordinates;
    Route* route;
    int curRouteLineNo;
    int advanceDistance;
    int stepCount;
    BOOL simulateLocationLost;
}

@synthesize delegate     = _delegate;


-(id) init
{
    self = [super init];
    if(self)
    {
        _locationUpdateInterval         = LOCATION_UPDATE_INTERVAL; // in millisecond
        _simulationSpeed                = SIMULATION_SPEED;
        nextRouteLineIndex              = 0;
        _isStart                        = false;
        _type                           = kLocationSimulator_ManualRoute;
        _lastLocationCoordinate2D       = CLLocationCoordinate2DMake(0, 0);
        _locationCoordinate2DChangeStep = 0.00005;
        speedCnt                        = 0;
        courseCnt                       = 0;
        _vibrant                        = FALSE;
        curRouteLineNo                  = -1;
        advanceDistance                 = (_simulationSpeed*1000*1000)/(3600*LOCATION_UPDATE_INTERVAL);
        stepCount                       = 0;
        simulateLocationLost            = FALSE;

        [self loadLocationFromTraceFile:[SystemConfig getStringValue:CONFIG_DEFAULT_TRACK_FILE]];
        
    }
    return self;
}

-(void) loadLocationFromTraceFile:(NSString*) fileName
{

    NSString *fileContents = [NSString stringWithContentsOfFile:[SystemManager getFilePathInDocument:fileName] encoding:NSUTF8StringEncoding error:NULL];
    CLLocation *location;
    NSDateFormatter *formatter;

    _locationIndexOfTrackFile       = 0;
    
    formatter = [[NSDateFormatter alloc]init];
    [formatter setDateFormat:@"HH:mm:ss"];
    _locationsOfTraceFile = [[NSMutableArray alloc] initWithCapacity:0];
    
    for (NSString *line in [fileContents componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]])
    {
        NSArray *fields = [line componentsSeparatedByString:@","];
        NSString *dateStr;
        if (nil == fields || 11 != fields.count)
            continue;
        
        dateStr = [[[fields objectAtIndex:0] componentsSeparatedByString:@" "] objectAtIndex:0];
        location = [[CLLocation alloc]
                    initWithCoordinate:CLLocationCoordinate2DMake([[fields objectAtIndex:1] doubleValue], [[fields objectAtIndex:2] doubleValue])
                    altitude:[[fields objectAtIndex:3] doubleValue]
                    horizontalAccuracy:[[fields objectAtIndex:4] doubleValue]
                    verticalAccuracy:[[fields objectAtIndex:5] doubleValue]
                    course:[[fields objectAtIndex:6] doubleValue]
                    speed:[[fields objectAtIndex:7] doubleValue]
                    timestamp:[formatter dateFromString:dateStr]
                    ];
        [_locationsOfTraceFile addObject:location];
    }

    location = [self getNextLocationFromFile];

    while(nil != location)
    {
        location = [self getNextLocationFromFile];
    };

}

-(CLLocation *) getNextLocationFromFile
{
    if (_locationIndexOfTrackFile >= _locationsOfTraceFile.count)
        return nil;
    
    return [_locationsOfTraceFile objectAtIndex:_locationIndexOfTrackFile++];
}

-(CLLocationCoordinate2D) getNextLineLocation
{
    double lngOffset = (arc4random() % 30)/10000.0;
    
    _lastLocationCoordinate2D.longitude += _locationCoordinate2DChangeStep + lngOffset;
    
    return _lastLocationCoordinate2D;
    
}

#if 0
-(CLLocationCoordinate2D) getNextRouteLocation
{
    int i = nextRouteLineIndex;
    double lngOffset = [self GetRandomDouble];
    double latOffset = [self GetRandomDouble];
    
    CLLocationCoordinate2D tmpLocationCoordinate2D = CLLocationCoordinate2DMake(0, 0);
    /* get first location from route line */
    if(nextRouteLineIndex == 0)
    {
        tmpLocationCoordinate2D = [[routeLineCoordinates objectAtIndex:0] CLLocationCoordinate2DValue];
        _currentLocation = [[CLLocation alloc] initWithCoordinate:
                            CLLocationCoordinate2DMake(tmpLocationCoordinate2D.latitude + latOffset,
                                                       tmpLocationCoordinate2D.longitude + lngOffset)
                                                         altitude:0.0
                                               horizontalAccuracy:1.0
                                                 verticalAccuracy:1.0
                                                           course:_courseCnt
                                                            speed:_speedCnt
                                                        timestamp:[NSDate date]];
        
        nextRouteLineIndex++;
    }
    /* */
    else if(nextRouteLineIndex < routeLineCoordinates.count)
    {
        for(i = nextRouteLineIndex; i<routeLineCoordinates.count; i++)
        {
            tmpLocationCoordinate2D = [[routeLineCoordinates objectAtIndex:i] CLLocationCoordinate2DValue];
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
        nextRouteLineIndex = i+1;
    }
    
    /* update speed and courst constant */
    _speedCnt   += 0.1;
    _courseCnt  += 1;
    _courseCnt  = (int)(_courseCnt)%362;
    
    _lastLocationCoordinate2D = _currentLocation.coordinate;
    
    return _currentLocation.coordinate;
}
#endif

-(CLLocationCoordinate2D) getNextRouteLocation
{
    RouteLine *curRouteLine;
    double latOffset = 0;
    double lngOffset = 0;

    if (YES == self.vibrant)
    {
        latOffset = [self GetRandomDouble];
        lngOffset = [self GetRandomDouble];
    }

    CLLocationCoordinate2D nextCoordinate2D = CLLocationCoordinate2DMake(_lastLocationCoordinate2D.latitude, _lastLocationCoordinate2D.longitude);

    
    advanceDistance                 = (_simulationSpeed*1000*1000)/(3600*LOCATION_UPDATE_INTERVAL);
    logI(advanceDistance);
    
    /* get first location from first route line */
    if(curRouteLineNo == -1)
    {
        curRouteLineNo              = 0;
        curRouteLine                = [route.routeLines objectAtIndex:curRouteLineNo];
        nextCoordinate2D.latitude   = curRouteLine.startLocation.latitude;
        nextCoordinate2D.longitude  = curRouteLine.startLocation.longitude;
    }
    else if (curRouteLineNo < route.routeLines.count)
    {
        double requiredDistance;
        double tmpDistance;
        double distanceFromStart;
        
        requiredDistance            = advanceDistance;
        curRouteLine                = [route.routeLines objectAtIndex:curRouteLineNo];
        
        nextCoordinate2D.latitude   = _currentLocation.coordinate.latitude;
        nextCoordinate2D.longitude  = _currentLocation.coordinate.longitude;
        
        while (requiredDistance > 0)
        {
            /* get the distance from the end point of the route line */
            tmpDistance = [GeoUtil getGeoDistanceFromLocation:nextCoordinate2D ToLocation:curRouteLine.endLocation];

            /* if required distance cannot be satisfied, move to next route line */
            if (tmpDistance < requiredDistance)
            {
                
                if (curRouteLineNo < route.routeLines.count-1)
                {
                    curRouteLineNo++;
                    curRouteLine  = [route.routeLines objectAtIndex:curRouteLineNo];
                    nextCoordinate2D.latitude   = curRouteLine.startLocation.latitude;
                    nextCoordinate2D.longitude  = curRouteLine.startLocation.longitude;
                }
                /* reach the last route line, leave the loop */
                else
                {
                    nextCoordinate2D.latitude   = curRouteLine.endLocation.latitude;
                    nextCoordinate2D.longitude  = curRouteLine.endLocation.longitude;
                    break;
                }
            }
            /* the required distance can be satisfied in the current route line */
            else
            {
                
                nextCoordinate2D.latitude   = nextCoordinate2D.latitude + (curRouteLine.endLocation.latitude - nextCoordinate2D.latitude) * (requiredDistance/tmpDistance);
                nextCoordinate2D.longitude  = nextCoordinate2D.longitude + (curRouteLine.endLocation.longitude - nextCoordinate2D.longitude) * (requiredDistance/tmpDistance);
            }
            

            requiredDistance -= tmpDistance;

            distanceFromStart = [GeoUtil getGeoDistanceFromLocation:nextCoordinate2D ToLocation:curRouteLine.startLocation];
        }
    }
    else
    {
        nextCoordinate2D.latitude   = _currentLocation.coordinate.latitude;
        nextCoordinate2D.longitude  = _currentLocation.coordinate.longitude;
    }
    
    /* update speed and courst constant */
    speedCnt   += 0.1;
    courseCnt  += 1;
    courseCnt  = (int)(courseCnt)%362;
    stepCount++;
    
    /* keep non-vibrant location */
    _lastLocationCoordinate2D = CLLocationCoordinate2DMake(nextCoordinate2D.latitude, nextCoordinate2D.longitude);
    
    _currentLocation = [[CLLocation alloc] initWithCoordinate:
                        CLLocationCoordinate2DMake(nextCoordinate2D.latitude + latOffset,
                                                   nextCoordinate2D.longitude + lngOffset)
                                                     altitude:0.0
                                           horizontalAccuracy:1.0
                                             verticalAccuracy:1.0
                                                       course:courseCnt
                                                        speed:speedCnt
                                                    timestamp:[NSDate date]];
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
    CLLocation* location;
    BOOL shouldNotify;
    
    shouldNotify = TRUE;
    switch (self.type)
    {
        case kLocationSimulator_Line:
            locationCoordinate2D = [self getNextLineLocation];
            break;
        case kLocationSimulator_ManualRoute:
            locationCoordinate2D = [self getNextRouteLocation];
            location = [[CLLocation alloc] initWithCoordinate:locationCoordinate2D altitude:0.0
                                           horizontalAccuracy:1.0 verticalAccuracy:1.0 course:courseCnt speed:speedCnt timestamp:[NSDate date]];
            speedCnt   += 0.1;
            courseCnt  += 1;
            courseCnt  = (int)(courseCnt)%362;
            
            break;
        case kLocationSimulator_File:
            location = [self getNextLocationFromFile];
            break;
            
    }

    if (TRUE == simulateLocationLost && stepCount > 10 )
    {
        if (stepCount%20 >= 0 && stepCount%20 <= 5)
        {
            /* for every 40 steps, zero location coordinate */
            //if (stepCount%40 >= 0 && stepCount%40 <= 5)
            if (1)
            {
                location = [[CLLocation alloc] initWithCoordinate:CLLocationCoordinate2DMake(1, 1) altitude:0.0
                                               horizontalAccuracy:1.0 verticalAccuracy:1.0 course:courseCnt speed:speedCnt timestamp:[NSDate date]];
                mlogDebug(@"simulate out of location");
            }
            /* for every 20 steps, skip update location */
            else
            {
                mlogDebug(@"simulate location lost");
                shouldNotify = FALSE;
            }
        }
    }
    
    if (self.delegate && TRUE == shouldNotify)
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
    if (_type == kLocationSimulator_ManualRoute && nextRouteLineIndex >= routeLineCoordinates.count)
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

    _isStart                = TRUE;
    stepCount               = 0;
    simulateLocationLost    = [SystemConfig getBoolValue:CONFIG_H_IS_SIMULATE_LOCATION_LOST];
   _timer                   = [NSTimer scheduledTimerWithTimeInterval:self.locationUpdateInterval/1000.0
                                                               target:self selector:@selector(timeout:) userInfo:nil repeats:YES];
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

-(void) setRoute:(Route*) r;
{
    curRouteLineNo          = -1;
    route                   = r;
    routeLineCoordinates    = [r getRoutePolyLineCLLocationCoordinate2D];
}
@end
