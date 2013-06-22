//
//  LocationManager.m
//  NaviUtil
//
//  Created by Coming on 13/3/28.
//  Copyright (c) 2013年 Coming. All rights reserved.
//

#import "LocationManager.h"
#import "SystemConfig.h"

static NSMutableArray* _manualPlaces;
static Place* _currentManualPlace;
@implementation LocationManager
{
    
}

@synthesize delegate=_delegate;


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
    
    _currentManualPlace = p;
}

+(int) getManualPlaceCount;
{
    return _manualPlaces.count;
}

+(Place*) getManualPlaceByIndex:(int) index
{
    return index < _manualPlaces.count ? [_manualPlaces objectAtIndex:index] : nil;
}

+(Place*) currentPlace
{
    Place *p = nil;
    
    if (SystemConfig.isManualPlace)
        p = _currentManualPlace;
    
    return p;
}

-(id) init
{
    self = [super init];
    if(self)
    {
        logfn();
        clLocationManager = [[CLLocationManager alloc] init];
        clLocationManager.delegate = self;
        
        [clLocationManager startUpdatingLocation];
    }
    
    return self;
    
}

- (void)locationManager:(CLLocationManager *)manager
    didUpdateToLocation:(CLLocation *)newLocation
           fromLocation:(CLLocation *)oldLocation
{
    logfns("depre\n");
    logfn();
}

- (void)locationManager:(CLLocationManager *)manager
     didUpdateLocations:(NSArray *)locations
{
    if(self.delegate)
    {
        if( [self.delegate respondsToSelector:@selector(locationUpdate:)])
        {
            [self.delegate locationUpdate:((CLLocation*)[locations objectAtIndex:locations.count-1]).coordinate];
        }
    }
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
@end
