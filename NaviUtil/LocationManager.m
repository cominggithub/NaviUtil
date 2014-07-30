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
    mlogInfo(@"Init Location Manager\n");
    _locationManager = [[CLLocationManager alloc] init];
    _locationManager.delegate = self;
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
    _currentHeading = ((newHeading.trueHeading >= 0) ? newHeading.trueHeading : newHeading.magneticHeading);
    
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
    // 0 台灣
    p = [[Place alloc] initWithName:@"台灣" address:@"台灣" coordinate:CLLocationCoordinate2DMake(23.845650,120.893555)];
    [_manualPlaces addObject:p];
    
    // 1 成大
    p = [[Place alloc] initWithName:@"成大" address:@"成大" coordinate:CLLocationCoordinate2DMake(22.996501,120.216678)];
    [_manualPlaces addObject:p];
    
    // 2 台南一中
    p = [[Place alloc] initWithName:@"台南一中" address:@"台南一中" coordinate:CLLocationCoordinate2DMake(22.9942340, 120.2159120)];
    [_manualPlaces addObject:p];
    
    // 3 智邦
    p = [[Place alloc] initWithName:@"智邦" address:@"智邦" coordinate:CLLocationCoordinate2DMake(23.099313,120.284371)];
    [_manualPlaces addObject:p];
 
    // 4 永安租屋
    p = [[Place alloc] initWithName:@"永安租屋" address:@"安平古堡" coordinate:CLLocationCoordinate2DMake(23.042724,120.245876)];
    [_manualPlaces addObject:p];
 
    // 5 冬山家
    p = [[Place alloc] initWithName:@"冬山家" address:@"冬山家" coordinate:CLLocationCoordinate2DMake(24.641790,121.798983)];
    [_manualPlaces addObject:p];
    
    _currentManualPlace                         = [_manualPlaces objectAtIndex:1];
    _currentSpeed                               = 0;
    _currentDistance                            = 0;
    _locationLostCount                          = 0;
    _currentCLLocationCoordinate2D.latitude     = 0;
    _currentCLLocationCoordinate2D.longitude    = 0;
    _hasLocation                                = NO;
    _lastUpdateTime                             = [NSDate date];
    _lastTriggerLocationUpdateTime              = [NSDate date];
    _locationUpdateType                         = kLocationManagerLocationUpdateType_File;

    
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
            
            logF(c.course);
            heading = TO_RADIUS(c.course);
            hasNewLocationInThisUpdate  = TRUE;
            lastUpdatedLocation         = c.coordinate;
        }
    }

    if ( NO == hasNewLocationInThisUpdate )
    {
        return;
    }

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
        _currentSpeed = speed;
    }
        
    _currentDistance                += distance;
    _currentHeading                 = heading;
    _currentCLLocationCoordinate2D  = nextLocation;

    _locationLostCount              = 0;
    _hasLocation                    = YES;
    _lastUpdateTime                 = updateTime;


        
    [self triggerLocationUpdateNotify];
    
    if (YES == _hasLocation && _locationLostCount > 3)
    {
        [self triggerLostLocationUpdateNotify];
        [self reprobeLocation];
    }

    _lastCLLocationCoordinate2D = lastUpdatedLocation;
    
}

+(int) getManualPlaceCount;
{
    return (int)_manualPlaces.count;
}

+(Place*) getManualPlaceByIndex:(int) index
{
    return index < _manualPlaces.count ? [_manualPlaces objectAtIndex:index] : nil;
}

+(BOOL) isLocationDifferenceReasonable:(CLLocationCoordinate2D) fromLocation To:(CLLocationCoordinate2D) toLocation
{
    if (TRUE == [SystemConfig getBoolValue:CONFIG_H_IS_LOCATION_UPDATE_FILTER])
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
    
    if (TRUE == [SystemConfig getBoolValue:CONFIG_H_IS_MANUAL_PLACE])
        p = _currentManualPlace;
    else
    {
        p = [[Place alloc] initWithName:[SystemManager getLanguageString:@"Current Location"]
                                address:@""
                             coordinate:_currentCLLocationCoordinate2D];
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



    for (id<LocationManagerDelegate> delegate in _delegates)
    {
        if ([delegate respondsToSelector:@selector(locationManager:update:speed:distance:heading:)])
        {
            [delegate locationManager:nil
                               update:_currentCLLocationCoordinate2D
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
        if ([delegate respondsToSelector:@selector(locationManager:lostLocation:)])
        {
            [delegate locationManager:nil lostLocation:YES];
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
            // update location for every 1.0s
            _locationSimulator.locationUpdateInterval = 1000;
            break;
        case kLocationManagerLocationUpdateType_ManualRoute:
            _locationSimulator.type = kLocationManagerLocationUpdateType_ManualRoute;
            // update location for every 1.0s
            _locationSimulator.locationUpdateInterval = 1000;
            break;
        case kLocationManagerLocationUpdateType_File:
            _locationSimulator.type = kLocationSimulator_File;
            // update location for every 0.25s
            _locationSimulator.locationUpdateInterval = 1000;
            break;
        default:
            _locationSimulator.type = kLocationManagerLocationUpdateType_ManualRoute;
            // update location for every 1.0s
            _locationSimulator.locationUpdateInterval = 1000;
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
    [formater setDateFormat:@"HH:mm:ss.SSS"];

    if (nil == locations)
    {
        return;
    }
        
    for( i=0; i<locations.count; i++)
    {
        
        CLLocation *location = [locations objectAtIndex:i];
        
        msg = [NSString stringWithFormat:@"%@ %d, %.8f, %.8f, %.1f, %.1f, %.1f, %.2f, %.2f, %.2f, %.2f, %.2f\n",
               [formater stringFromDate:[NSDate date]],     // 1. time              0
               i,                                           // 2. index             0
               location.coordinate.latitude,                // 3. latitude          1
               location.coordinate.longitude,               // 4. longitude         2
               location.altitude,                           // 5. altitude          3
               location.horizontalAccuracy,                 // 6. h accuracy        4
               location.verticalAccuracy,                   // 7. v accuracy        5
               location.speed,                              // 8. speed             6
               location.course,                             // 9. course            7
                                                            // 10. distance         8
               [GeoUtil getGeoDistanceFromLocation:_lastCLLocationCoordinate2D ToLocation:location.coordinate],
                                                            // 11. time difference  9
               timeDiffer,
                                                            // 12. calculate speed 10
               [GeoUtil getGeoDistanceFromLocation:_lastCLLocationCoordinate2D ToLocation:location.coordinate]/timeDiffer
               
               ];
        
    }
    
    if (nil != _fileHandle)
    {
        [_fileHandle writeData:[msg dataUsingEncoding:NSUTF8StringEncoding]];
        [_fileHandle synchronizeFile];
    }
}

+(void) saveToKml
{
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
    
    for(int i=0; i<_savedLocations.count; i++)
    {
        CLLocation *cl = [_savedLocations objectAtIndex:i];
        CLLocationCoordinate2D location = cl.coordinate;
        [content appendString:@"<Placemark>\n"];
        [content appendString:[NSString stringWithFormat:@"<name>%d</name>", i]];
        [content appendString:@"<Point>\n"];
        [content appendString:[NSString stringWithFormat:@"<name>%d</name>", i]];
        [content appendString:[NSString stringWithFormat:@"<coordinates>%.8f,%.8f</coordinates>", location.longitude, location.latitude]];
        [content appendString:@"</Point>\n"];
        [content appendString:@"</Placemark>\n"];
    }
    [content appendString:@"</Document>\n"];
    [content appendString:@"</kml>"];
    
    
    
    [content writeToFile:_kmlFileName atomically:YES encoding:NSUnicodeStringEncoding error:&err];
    
}

+(void) newFile
{
    _savedLocations = [[NSMutableArray alloc] initWithCapacity:0];
    _fileName = [NSString stringWithFormat:@"%@/GT_%@.txt", [SystemManager getPath:kSystemManager_Path_Track], [_dateFormatter2 stringFromDate:[NSDate date]]];
    
    _kmlFileName = [NSString stringWithFormat:@"%@/GT_%@.kml", [SystemManager getPath:kSystemManager_Path_Track], [_dateFormatter2 stringFromDate:[NSDate date]]];
    
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
    if (nil != _fileHandle)
    {
        [_fileHandle closeFile];
    }
    
    [self saveToKml];
}
@end
