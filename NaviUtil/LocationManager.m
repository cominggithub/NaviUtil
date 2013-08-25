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
#import "LocationSimulator.h"

#define FILE_DEBUG FALSE
#include "Log.h"

#define LOCATION_UPDATE_DISTANCE_THRESHOLD 30 /* 30 meter */ 

static NSMutableArray* _manualPlaces;
static Place* _currentManualPlace;
static Place* _currentPlace;
static LocationManager *_locationManager;
static LocationSimulator *_locationSimulator;
static NSMutableArray* _delegates;
static double _currentSpeed; /* meter/s */
static int _currentDistance;
static CLLocationDirection _currentHeading;
static CLLocationCoordinate2D _currentCLLocationCoordinate2D;
static CLLocationCoordinate2D _lastCLLocationCoordinate2D;
static NSDate* _lastUpdateTime;
static int _locationLostCount;
static BOOL _hasLocation;
static NSDate* _lastTriggerLocationUpdateTime;
static int _setLocationUpdateInterval; // in milliseconds
static int _skipLostDetectionCount;
static LocationManagerLocationUpdateType _locationUpdateType;
static BOOL _isTracking;
static NSDateFormatter *_dateFormatter1;
static NSDateFormatter *_dateFormatter2;
static NSString* _fileName;
static NSString* _kmlFileName;
static NSFileHandle *_fileHandle;
static NSMutableArray *_savedLocations;

@implementation LocationManager
{
    CLLocationManager *_locationManager;
}

@synthesize delegate=_delegate;

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
    _locationManager = [[CLLocationManager alloc] init];
    _locationManager.delegate=self;
    _locationManager.desiredAccuracy=kCLLocationAccuracyBestForNavigation;
    
}

-(void) startMonitorLocationChange
{
    [_locationManager startUpdatingLocation];
    [_locationManager startUpdatingHeading];
}

-(void) stopMonitorLocationChange
{
    [_locationManager stopUpdatingLocation];
    [_locationManager stopUpdatingHeading];
}


- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    [LocationManager addUpdatedCLLocations:locations];
}

-(void) locationManager:(CLLocationManager *)manager didUpdateHeading:(CLHeading *)newHeading
{
    
    if (newHeading.headingAccuracy < 0)
        return;
    
    // Use the true heading if it is valid.
    _currentHeading = ((newHeading.trueHeading > 0) ? newHeading.trueHeading : newHeading.magneticHeading);
    
}

+(void) addDelegate: (id<LocationManagerDelegate>) delegate
{
    // Additional code
    if (NO == [_delegates containsObject:delegate])
    {
        [_delegates addObject: delegate];
    }
}

+(void) removeDelegate: (id<LocationManagerDelegate>) delegate
{
    if (YES == [_delegates containsObject:delegate])
    {
        [_delegates removeObject: delegate];
    }
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
    _locationUpdateType                         = kLocationManagerLocationUpdateType_RealLocation;

    
    _locationManager            = [[LocationManager alloc] init];
    _locationSimulator          = [[LocationSimulator alloc] init];
    _locationSimulator.delegate = _locationManager;
    _delegates = [[NSMutableArray alloc] initWithCapacity:0];

    
    _dateFormatter1 = [[NSDateFormatter alloc] init];
    [_dateFormatter1 setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    
    _dateFormatter2 = [[NSDateFormatter alloc] init];
    [_dateFormatter2 setDateFormat:@"yyyy-MM-dd HH-mm"];
    
    NSDateFormatter *dateFormattor = [[NSDateFormatter alloc] init];
    NSFileManager *filemanager;
    NSString *currentPath;
    
    [dateFormattor setDateFormat:@"HHMM"];
    filemanager =[NSFileManager defaultManager];
    currentPath = [filemanager currentDirectoryPath];
    
    [LocationManager reprobeLocation];
    
}

+(void) reprobeLocation
{
    mlogWarning(@"reprobe location\n");
    _hasLocation            = NO;
    _locationLostCount      = 0;
    _skipLostDetectionCount = 20;
}

+(void) addUpdatedCLLocations:(NSArray *) clLocations
{
    int distance = 0;
    int updateLocationCount = 0;
    CLLocationCoordinate2D nextLocation = _currentCLLocationCoordinate2D;
    NSDate *updateTime = [NSDate date];
    NSTimeInterval timeDiff;
    BOOL isLocationUpdated = FALSE;
    BOOL hasNewLocationInThisUpdate   = FALSE;
    CLLocationSpeed speed = 0;
    CLLocationDirection heading = 0;
    CLLocationCoordinate2D lastUpdatedLocation;
    if (YES == _isTracking)
    {
        [_savedLocations addObjectsFromArray:clLocations];
        [self writeLocationToFile:clLocations];
    }
    
    _skipLostDetectionCount = _skipLostDetectionCount > 0 ? (_skipLostDetectionCount-1):0;
    
    for (CLLocation* c in clLocations)
    {
        if (c.horizontalAccuracy >=0 )
        {
            nextLocation.latitude       = c.coordinate.latitude;
            nextLocation.longitude      = c.coordinate.longitude;
            if (c.speed > 0 && !isnan(c.speed))
            {
                speed += c.speed;
                updateLocationCount++;
            }
            
            heading = TO_RADIUS(c.course);
            hasNewLocationInThisUpdate  = TRUE;
            lastUpdatedLocation         = c.coordinate;
        }
    }

    if ( NO == hasNewLocationInThisUpdate )
    {
        return;
    }
    
    if (_hasLocation && _skipLostDetectionCount == 0)
    {
        if ([self isLocationDifferenceReasonable:_currentCLLocationCoordinate2D To:nextLocation])
        {

            isLocationUpdated = TRUE;
        }
        else
        {
            _locationLostCount++;
        }
    }
    else
    {
        isLocationUpdated   = TRUE;
    }

    
    if (YES == isLocationUpdated)
    {
        // calculate location update parameter
        if (updateLocationCount > 0)
        {
            speed /= updateLocationCount;
        }
        
        distance = [GeoUtil getGeoDistanceFromLocation:_currentCLLocationCoordinate2D ToLocation:nextLocation];
        timeDiff = [updateTime timeIntervalSinceDate:_lastUpdateTime];

        if (YES == [GeoUtil isCLLocationCoordinate2DEqual:_lastCLLocationCoordinate2D To:lastUpdatedLocation])
        {
            _currentSpeed = 0;
        }
        else
        {
            _currentSpeed = 0.75*_currentSpeed + 0.25*speed;
        }
        
        _currentDistance                += distance;
        _currentCLLocationCoordinate2D  = nextLocation;

        _locationLostCount              = 0;
        _hasLocation                    = YES;
        _lastUpdateTime                 = updateTime;
        
        if (heading > 0)
        {
            _currentHeading                 = 0.75*_currentHeading + 0.25*heading;
        }
        
        [self triggerLocationUpdateNotify];
    }
    
    if (YES == _hasLocation && _locationLostCount > 3)
    {
        [self triggerLostLocationUpdateNotify];
        [self reprobeLocation];
    }

    
    _lastCLLocationCoordinate2D = lastUpdatedLocation;
    
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
    if (TRUE == [SystemConfig getBoolValue:CONFIG_IS_LOCATION_UPDATE_FILTER])
    {
        int distance = [GeoUtil getGeoDistanceFromLocation:fromLocation ToLocation:toLocation];
        if (distance > LOCATION_UPDATE_DISTANCE_THRESHOLD)
        {
            return FALSE;
        }
    }
    return TRUE;
}

+(Place*) currentPlace
{
    Place *p = _currentPlace;
    
    if (TRUE == [SystemConfig getBoolValue:CONFIG_IS_MANUAL_PLACE])
        p = _currentManualPlace;
    else
    {
        p = [Place newPlace:[SystemManager getLanguageString:@"Current Place"] Address:[SystemManager getLanguageString:@"Current Place"] Location:_currentCLLocationCoordinate2D];
    }

    p.placeRouteType = kPlaceType_CurrentPlace;
    return p;
}

+(void) setCurrentManualPlace:(Place*) p
{
    if (nil != _currentManualPlace)
    {
        _currentManualPlace.placeType = kPlaceType_None;
    }
    _currentManualPlace.placeType = kPlaceType_CurrentPlace;
    _currentManualPlace = p;
}

+(void) triggerLocationUpdateNotify
{
    NSDate *updateTime = [NSDate date];
    NSTimeInterval timeInterval = [updateTime timeIntervalSinceDate:_lastTriggerLocationUpdateTime]*1000;

    if ( [SystemConfig getDoubleValue:CONFIG_TRIGGER_LOCATION_INTERVAL] > timeInterval && _lastTriggerLocationUpdateTime != nil)
    {
        mlogDebug(@"skip location update notify %.0fms > %.0fms", [SystemConfig getDoubleValue:CONFIG_TRIGGER_LOCATION_INTERVAL], timeInterval);
        return;
    }
#if 0
    mlogDebug(@"notify location update: (%.8f, %.8f), speed: %.2f, distance: %.2f, heading: %.2f\n",
              _currentCLLocationCoordinate2D.latitude,
              _currentCLLocationCoordinate2D.longitude,
              _currentSpeed,
              _currentDistance,
              _currentHeading
              );
#endif
    for (id<LocationManagerDelegate> delegate in _delegates)
    {
        if ([delegate respondsToSelector:@selector(locationUpdate:speed:distance:heading:)])
        {
            [delegate locationUpdate:_currentCLLocationCoordinate2D
                               speed:_currentSpeed
                            distance:_currentDistance
                             heading:_currentHeading
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

+(void) startMonitorLocation
{
    [_locationSimulator stop];
    [_locationManager startMonitorLocationChange];

}

+(void) stopMonitorLocation
{
    [_locationManager stopMonitorLocationChange];
}

+(void) startLocationSimulation
{
    [_locationManager stopMonitorLocationChange];
    [_locationSimulator start];
}

+(void) stopLocationSimulation
{
    [_locationSimulator stop];
    
}

+(void) triggerLocationUpdate
{
    [_locationSimulator triggerLocationUpdate];
}

+(void) setRoute:(Route*) route
{
    [_locationSimulator setRoute:route];
}

+(void) setLocationUpdateType:(LocationManagerLocationUpdateType) locationUpdateType
{
    _locationUpdateType = locationUpdateType;
    switch (_locationUpdateType)
    {
        case kLocationManagerLocationUpdateType_Line:
            _locationSimulator.type = kLocationSimulator_Line;
            break;
        case kLocationManagerLocationUpdateType_ManualRoute:
            _locationSimulator.type = kLocationManagerLocationUpdateType_ManualRoute;
            break;
        default:
            _locationSimulator.type = kLocationManagerLocationUpdateType_ManualRoute;
            break;
    }
}

+(void) startLocationTracking
{
    _isTracking = TRUE;
    [self newFile];
}

+(void) stopLocationTracking
{
    _isTracking = FALSE;
    [self saveFile];
}

+(void) writeLocationToFile:(NSArray *)locations
{
    int i;
    NSString *msg;
    NSDateFormatter *formater = [[NSDateFormatter alloc] init];
    NSDate *now = [NSDate date];
    NSTimeInterval timeDiffer;
    timeDiffer = [now timeIntervalSinceDate:_lastUpdateTime];
    [formater setDateFormat:@"HH:mm:ss"];

    if (nil == locations)
    {
        return;
    }
        
    for( i=0; i<locations.count; i++)
    {
        
        CLLocation *location = [locations objectAtIndex:i];
        
        msg = [NSString stringWithFormat:@"%@ %d, %.8f, %.8f, %.1f, %.1f, %.1f, %.2f, %.2f, %.2f, %.2f, %.2f\n",
               [formater stringFromDate:[NSDate date]],     // 1. time
               i,                                           // 2. index
               location.coordinate.latitude,                // 3. latitude
               location.coordinate.longitude,               // 4. longitude
               location.altitude,                           // 5. altitude
               location.horizontalAccuracy,                 // 6. h accuracy
               location.verticalAccuracy,                   // 7. v accuracy
               location.speed,                              // 8. speed
               location.course,                             // 9. course
                                                            // 10. distance
               [GeoUtil getGeoDistanceFromLocation:_lastCLLocationCoordinate2D ToLocation:location.coordinate],
                                                            // 11. time difference
               timeDiffer,
                                                            // 12. calculate speed
               [GeoUtil getGeoDistanceFromLocation:_lastCLLocationCoordinate2D ToLocation:location.coordinate]/timeDiffer
               
               ];
        
    }
    
//    mlogDebug(@"%@", msg);
    
    if (nil != _fileHandle)
    {
        [_fileHandle writeData:[msg dataUsingEncoding:NSUTF8StringEncoding]];
        [_fileHandle synchronizeFile];
    }
}

+(void) saveToKml
{
    logfn();
    NSMutableString *content = [[NSMutableString alloc] init];
    NSMutableString *coordinates = [[NSMutableString alloc] init];
    NSError *err;
    
    
    for(CLLocation* cl in _savedLocations)
    {
        [coordinates appendFormat:@"%f,%f,0 \n", cl.coordinate.longitude, cl.coordinate.latitude];
    }
    
    [content appendString:@"<?xml version=\"1.0\" standalone=\"yes\"?>\n"];
    [content appendString:@"<kml xmlns=\"http://earth.google.com/kml/2.2\">\n"];
    [content appendString:@"<Document>\n"];
    [content appendFormat:@"<name>KK</name>\n"];
    [content appendString:@"<Placemark>\n"];
    [content appendString:@"<Style>\n"];
    [content appendString:@"<LineStyle>\n"];
    [content appendString:@"<color>FF00FF00</color>\n"];
    [content appendString:@"<width>10</width>\n"];
    [content appendString:@"</LineStyle>\n"];
    [content appendString:@"</Style>\n"];
    [content appendString:@"<MultiGeometry>\n"];
    [content appendString:@"<LineString>\n"];
    [content appendString:@"<tessellate>1</tessellate>\n"];
    [content appendString:@"<altitudeMode>clampToGround</altitudeMode>\n"];
    [content appendString:@"<coordinates>\n"];
    [content appendString:coordinates];
    
    [content appendString:@"</coordinates>\n"];
    [content appendString:@"</LineString>\n"];
    [content appendString:@"</MultiGeometry>\n"];
    [content appendString:@"</Placemark>\n"];
    [content appendString:@"</Document>\n"];
    [content appendString:@"</kml>"];
    
    
    
    [content writeToFile:_kmlFileName atomically:YES encoding:NSUnicodeStringEncoding error:&err];
    
}

+(void) newFile
{
    logfn();
    _savedLocations = [[NSMutableArray alloc] initWithCapacity:0];
    _fileName = [NSString stringWithFormat:@"%@/GT_%@.txt", [SystemManager documentPath], [_dateFormatter2 stringFromDate:[NSDate date]]];
    
    _kmlFileName = [NSString stringWithFormat:@"%@/GT_%@.kml", [SystemManager documentPath], [_dateFormatter2 stringFromDate:[NSDate date]]];
    
    mlogDebug(@"%@", _fileName);
    mlogDebug(@"%@", _kmlFileName);
    @try
    {
        _fileHandle = [NSFileHandle fileHandleForWritingAtPath:_fileName];
        if(_fileHandle == nil) {
            [[NSFileManager defaultManager] createFileAtPath:_fileName contents:nil attributes:nil];
            _fileHandle = [NSFileHandle fileHandleForWritingAtPath:_fileName];
        }
    }
    @catch (NSException *exception)
    {

    }
}

+(void) saveFile
{
    logfn();
    if (nil != _fileHandle)
    {
        [_fileHandle closeFile];
    }
    
    [self saveToKml];
}
@end
