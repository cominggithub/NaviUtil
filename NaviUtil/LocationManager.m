//
//  LocationManager.m
//  NaviUtil
//
//  Created by Coming on 13/3/28.
//  Copyright (c) 2013年 Coming. All rights reserved.
//

#import "LocationManager.h"
#import "SystemConfig.h"
#import "SystemManager.h"

#define FILE_DEBUG FALSE
#include "Log.h"

#define LOCATION_UPDATE_DISTANCE_THRESHOLD 30 /* 30 meter */ 

static NSMutableArray* _manualPlaces;
static Place* _currentManualPlace;
static Place* _currentPlace;
static LocationManager *_locationManager;

static NSMutableArray* _delegates;
static int _currentSpeed; /* meter/s */
static int _currentDistance;
static CLLocationCoordinate2D _currentCLLocationCoordinate2D;
static int _locationLostCount;
static BOOL _hasLocation;
static NSDate* _lastUpdateTime;
static NSDate* _lastTriggerLocationUpdateTime;

@implementation LocationManager
{

}


@synthesize delegate=_delegate;

-(id) init
{
    self = [super init];
    if (self)
    {
        [self startMonitorLocationChange];
    }
    
    return self;
}

-(void)startMonitorLocationChange
{
    CLLocationManager *locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate=self;
    locationManager.desiredAccuracy=kCLLocationAccuracyBestForNavigation;
    [locationManager startUpdatingLocation];
}

- (void)locationManager:(CLLocationManager *)manager
	 didUpdateLocations:(NSArray *)locations
{
    [LocationManager addUpdatedCLLocations:locations];
}

+ (void) addDelegate: (id<LocationManagerDelegate>) delegate
{
    // Additional code
    [_delegates addObject: delegate];
}

+ (void) removeDelegate: (id<LocationManagerDelegate>) delegate
{
    // Additional code
    [_delegates removeObject: delegate];
}


+(void) init
{
    Place *p;
    _manualPlaces = [[NSMutableArray alloc] initWithCapacity:0];
    p = [Place newPlace:@"台灣" Address:@"台灣" Location:CLLocationCoordinate2DMake(23.845650,120.893555)];
    [_manualPlaces addObject:p];
    p = [Place newPlace:@"成大" Address:@"成大" Location:CLLocationCoordinate2DMake(22.996501,120.216678)];
    [_manualPlaces addObject:p];
    p = [Place newPlace:@"台南一中" Address:@"台南一中" Location:CLLocationCoordinate2DMake(22.9942340, 120.2159120)];
    [_manualPlaces addObject:p];
    p = [Place newPlace:@"智邦" Address:@"智邦" Location:CLLocationCoordinate2DMake(23.099313,120.284371)];
    [_manualPlaces addObject:p];
    p = [Place newPlace:@"永安租屋" Address:@"安平古堡" Location:CLLocationCoordinate2DMake(23.042724,120.245876)];
    [_manualPlaces addObject:p];
    p = [Place newPlace:@"冬山家" Address:@"冬山家" Location:CLLocationCoordinate2DMake(24.641790,121.798983)];
    [_manualPlaces addObject:p];
    
    _currentManualPlace                         = p;
    _currentSpeed                               = 0;
    _currentDistance                            = 0;
    _locationLostCount                          = 0;
    _currentCLLocationCoordinate2D.latitude     = 0;
    _currentCLLocationCoordinate2D.longitude    = 0;
    _hasLocation                                = NO;
    _lastUpdateTime                             = [NSDate date];
    _lastTriggerLocationUpdateTime              = [NSDate date];
    
    
    
    _locationManager = [[LocationManager alloc] init];
    _delegates = [[NSMutableArray alloc] initWithCapacity:0];

    
    
}

+(void) addUpdatedCLLocations:(NSArray *) clLocations
{
    int distance = 0;
    CLLocationCoordinate2D nextLocation = _currentCLLocationCoordinate2D;
    NSDate *updateTime = [NSDate date];
    NSTimeInterval timeDiff;
    
    for (CLLocation* c in clLocations)
    {
        nextLocation.latitude = nextLocation.latitude*0.75 + c.coordinate.latitude*0.25;
        nextLocation.longitude = nextLocation.longitude*0.75 + c.coordinate.longitude*0.25;
    }
    
    
    if (_hasLocation)
    {
        if ([self isLocationDifferenceReasonable:_currentCLLocationCoordinate2D To:nextLocation])
        {

            distance = [GeoUtil getGeoDistanceFromLocation:_currentCLLocationCoordinate2D ToLocation:nextLocation];
            timeDiff = [updateTime timeIntervalSinceDate:_lastUpdateTime];
            
            _currentSpeed                   = 0.75*_currentSpeed + 0.25*(distance/timeDiff);
            _currentDistance                += distance;
            _currentCLLocationCoordinate2D  = nextLocation;
            _locationLostCount              = 0;
            _hasLocation                    = YES;
            _lastUpdateTime                 = updateTime;
            [self triggerLocationUpdateNotify];
            
        }
        else
        {
            _locationLostCount++;
        }
    }
    else
    {
        _currentCLLocationCoordinate2D  = nextLocation;
        _hasLocation                    = YES;
    }
    
    if (YES == _hasLocation && _locationLostCount > 3)
    {
        _hasLocation        = NO;
        _locationLostCount  = 0;
        [self triggerLostLocationUpdateNotify];
    }
}

+(int) getManualPlaceCount;
{
    return _manualPlaces.count;
}

+(Place*) getManualPlaceByIndex:(int) index
{
    return index < _manualPlaces.count ? [_manualPlaces objectAtIndex:index] : nil;
}

+(BOOL) isLocationDifferenceReasonable:(CLLocationCoordinate2D) fromLocation To:(CLLocationCoordinate2D) toLocation
{
    int distance = [GeoUtil getGeoDistanceFromLocation:fromLocation ToLocation:toLocation];
    if (distance > LOCATION_UPDATE_DISTANCE_THRESHOLD)
        return FALSE;
    
    return TRUE;
}

+(Place*) currentPlace
{
    Place *p = _currentPlace;
    
    if (SystemConfig.isManualPlace)
        p = _currentManualPlace;
    else
    {
        p = [Place newPlace:[SystemManager getLanguageString:@"Current Place"] Address:[SystemManager getLanguageString:@"Current Place"] Location:_currentCLLocationCoordinate2D];
    }

    
    return p;
}

+(void) setCurrentManualPlace:(Place*) p
{
    if (nil != _currentManualPlace)
    {
        _currentManualPlace.placeType = kPlaceType_None;
    }
    _currentManualPlace.placeType = kPlaceType_CurrentLocation;
    _currentManualPlace = p;
}

+(void) triggerLocationUpdateNotify
{
    NSDate *updateTime = [NSDate date];
    NSTimeInterval timeInterval = [updateTime timeIntervalSinceDate:_lastTriggerLocationUpdateTime];
    
    if ( SystemConfig.triggerLocationInterval > timeInterval)
        return;
    

    for (id<LocationManagerDelegate> delegate in _delegates)
    {
        if ([delegate respondsToSelector:@selector(locationUpdate::)])
        {
            [delegate locationUpdate:_currentCLLocationCoordinate2D
                               Speed:_currentSpeed
                            Distance:_currentDistance
             ];
        }
    }
    
    _lastTriggerLocationUpdateTime = updateTime;
}

+(void) triggerLostLocationUpdateNotify
{
    for (id<LocationManagerDelegate> delegate in _delegates)
    {
        if ([delegate respondsToSelector:@selector(lostLocationUpdate)])
        {
            [delegate lostLocationUpdate];
        }
    }
}

+(CLLocationCoordinate2D) getCurrentCLLocationCoordinate2D
{
   
    return _currentCLLocationCoordinate2D;
}

@end
