//
//  MapPlaceManager.m
//  NaviUtil
//
//  Created by Coming on 11/18/13.
//  Copyright (c) 2013 Coming. All rights reserved.
//

#import "MapManager.h"
#import "DownloadRequest.h"

#include "Log.h"

#define ZOOM_LEVEL_MAX 21
#define ZOOM_LEVEL_MIN 1
#define ZOOM_LEVEL_DEFAULT 12


@implementation MapManager 
{
    NSMutableArray *_searchedPlaces;
    Place *_selectedPlace;
    Place *_currentPlace;
    Place *_routeStartPlace;
    Place *_routeEndPlace;
    
    int zoomLevel;
    bool isRouteChanged;
    DownloadRequest *routeDownloadRequest;
    DownloadRequest *searchPlaceDownloadRequest;

    GMSMapView *_mapView;
    BOOL firstLocationUpdate;
}

@synthesize routePolyline;
@synthesize searchedPlaces=_searchedPlaces;
@synthesize hasRoute=_hasRoute;

-(id) init
{
    self = [super init];
    if (self)
    {

    }
    
    return self;
}

- (void)dealloc {
    if (_mapView != nil)
    {
        [_mapView removeObserver:self
                     forKeyPath:@"myLocation"
                        context:NULL];
    }
}


#pragma mark -- property

-(void) addPlace:(Place *)p
{
    
    
}

- (void) addPlaceToMapMaker:(Place*) p
{
#if 0
    GMSMarker *marker;
    
    if (nil == p)
        return;
    
    marker          = [[GMSMarker alloc] init];
    marker.title    = p.name;
    marker.snippet  = p.address;
    marker.position = p.coordinate;
    
    if ( p.placeType == kPlaceType_Home)
    {
        marker.icon     = [UIImage imageNamed:@"place_marker_home_48"];
    }
    else if ( p.placeType == kPlaceType_Office )
    {
        marker.icon     = [UIImage imageNamed:@"place_marker_office_48"];
    }
    else if ( p.placeType == kPlaceType_Favor )
    {
        marker.icon     = [UIImage imageNamed:@"place_marker_favor_48"];
    }
    else
    {
        marker.icon     = [UIImage imageNamed:@"place_marker_normal_48"];
    }
    
    marker.map      = _mapView;
    [markerPlaces addObject:p];
#endif
    
}

-(void) removePlace:(Place *) p
{
    
    
}

-(bool) isPlaceInSearchedPlaces:(Place*) place
{
    for (Place* p in _searchedPlaces)
    {
        if ( [p isCoordinateEqualTo:place])
            return true;
    }
    
    return false;
}


-(Place*) placeByGMSMarker:(GMSMarker*) marker
{
#if 0
    if (nil == marker)
        return nil;
    
    for (Place *p in markerPlaces)
    {
        if (true == [GeoUtil isCLLocationCoordinate2DEqual:p.coordinate To:marker.position])
            return p;
    }
    
#endif
    return nil;
}


-(void) planRoute
{
#if 0
    if (isRouteChanged == true)
    {
        if (nil != routeStartPlace && nil != routeEndPlace)
        {
            if (![routeStartPlace isCoordinateEqualTo:routeEndPlace])
            {
                routeDownloadRequest = [NaviQueryManager
                                        getRouteDownloadRequestFrom:routeStartPlace.coordinate
                                        To:routeEndPlace.coordinate];
                routeDownloadRequest.delegate = self;
                
                if ([GoogleJson getStatus:routeDownloadRequest.fileName] != kGoogleJsonStatus_Ok)
                {
                    [NaviQueryManager download:routeDownloadRequest];
                }
            }
            
        }
    }
    
    isRouteChanged = false;
#endif
}


-(void) setRouteStart:(Place*) p
{
#if 0
    if ([routeEndPlace isCoordinateEqualTo:p])
    {
        routeEndPlace = nil;
    }
    
    if (![routeStartPlace isCoordinateEqualTo:p])
    {
        isRouteChanged                  = true;
        routeStartPlace.placeRouteType  = kPlaceRouteType_None;
        routeStartPlace                 = p;
        routeStartPlace.placeRouteType  = kPlaceRouteType_Start;
        [self planRoute];
    }
#endif
}

-(void) setRouteEnd:(Place*) p
{
    
#if 0
    if ([routeStartPlace isCoordinateEqualTo:p])
    {
        routeStartPlace = nil;
    }
    
    if (![routeEndPlace isCoordinateEqualTo:p])
    {
        isRouteChanged                  = true;
        routeEndPlace.placeRouteType    = kPlaceRouteType_None;
        routeEndPlace                   = p;
        routeEndPlace.placeRouteType    = kPlaceRouteType_End;
        [self planRoute];
    }
#endif
    
}

-(void) addSearchedPlaces:(NSArray*) places
{
    
    
}

-(void) updateSearchedPlaces:(NSArray*) places
{
#if 0
    int i=0;
    Place* firstPlace = nil;
    if ( places.count < 1)
    {
        self.titleLabel.text = [SystemManager getLanguageString:@"Search fail"];
    }
    /* reserve previous search results */
    else
    {
        [searchedPlaces removeAllObjects];
    }
    
    /* only reserve the first three places */
    for(i=0; i<places.count && i < 3; i++)
    {
        Place *p = [places objectAtIndex:i];
        /* add the first search result no matter what */
        if (false == [self isPlaceInSearchedPlaces:p])
        {
            [searchedPlaces addObject:p];
            if (nil == firstPlace)
                firstPlace = p;
        }
    }
    
    [self refresh];
    [self moveToPlace:firstPlace];
#endif
}


-(void) removePlaceFromSearchedPlace:(Place*) placeToRemove
{
#if 0
    int i;
    
    
    for(i=0; i<searchedPlaces.count; i++)
    {
        Place* p = (Place*)[searchedPlaces objectAtIndex:i];
        if ([placeToRemove isCoordinateEqualTo:p])
        {
            [searchedPlaces removeObjectAtIndex:i];
            i--;
        }
    }
#endif
}

- (void) updateUserConfiguredLocation
{
#if 0
    int i;
    
    for(i=0; i<User.homePlaces.count; i++)
    {
        [self addPlaceToMapMaker:[User getHomePlaceByIndex:i]];
        [self removePlaceFromSearchedPlace:[User getHomePlaceByIndex:i]];
    }
    
    for(i=0; i<User.officePlaces.count; i++)
    {
        [self addPlaceToMapMaker:[User getOfficePlaceByIndex:i]];
        [self removePlaceFromSearchedPlace:[User getOfficePlaceByIndex:i]];
    }
    
    for(i=0; i<User.favorPlaces.count; i++)
    {
        [self addPlaceToMapMaker:[User getFavorPlaceByIndex:i]];
        [self removePlaceFromSearchedPlace:[User getFavorPlaceByIndex:i]];
    }
#endif
}

-(void) updateRoute
{
#if 0
    NSArray *routePoints;
    GMSPolyline *polyLine;
    GMSMutablePath *path;
    
    if (nil != routeStartPlace && currentPlace != routeStartPlace)
    {
        [self addPlaceToMapMaker:routeStartPlace];
    }
    
    if (nil != routeEndPlace && currentPlace != routeEndPlace)
    {
        [self addPlaceToMapMaker:routeEndPlace];
    }
    
    if (nil == currentRoute || nil == routeStartPlace || nil == routeEndPlace)
    {
        return;
    }
    
    routePoints             = [currentRoute getRoutePolyLineCLLocation];
    polyLine                = [[GMSPolyline alloc] init];
    polyLine.strokeWidth    = 5;
    polyLine.strokeColor    = [UIColor redColor];
    path                    = [GMSMutablePath path];
    
    for(CLLocation *location in routePoints)
    {
        [path addCoordinate:location.coordinate];
    }
    
    polyLine.path       = path;
    polyLine.geodesic   = NO;
    polyLine.map        = _mapView;
#endif
    
}

-(void) clearMapAll
{
    [_mapView clear];
//    [markerPlaces removeAllObjects];
}

-(void) clearRoute
{
    
}

-(NSArray*) placeMarkers
{
    
    return nil;
}

-(void) mapRefresh
{
#if 0
    [self clearMapAll];
    
    NSArray *placeMarkers;
    GMSPolyline *routePolyLine;
    placeMarkers    = mapManager.placeMarkers;
    routePolyLine   = mapManager.routePolyline;
    
    for(GMSMarker* p in placeMarkers)
    {
        p.map = mapView;
    }
    
    if (NULL != routePolyLine)
    {
        routePolyLine.map = mapView;
    }
#endif
    
}

-(GMSMapView*) mapView
{

    if (_mapView == nil) {
        zoomLevel = ZOOM_LEVEL_DEFAULT;
        
        _mapView = [[GMSMapView alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
        
        _mapView.accessibilityLabel = @"mapView";
        
#if 0
        if (nil != currentPlace)
        {
            mapView.camera = [GMSCameraPosition cameraWithLatitude:currentPlace.coordinate.latitude
                                                         longitude:currentPlace.coordinate.longitude
                                                              zoom:zoomLevel
                                                           bearing:10.f
                                                      viewingAngle:37.5f];
        }
#endif
        firstLocationUpdate = FALSE;
        [_mapView addObserver:self
                  forKeyPath:@"myLocation"
                     options:NSKeyValueObservingOptionNew
                     context:NULL];
      
        [_mapView animateToZoom:zoomLevel];
        _mapView.delegate = self;
        
        // Ask for My Location data after the map has already been added to the UI.
        dispatch_async(dispatch_get_main_queue(), ^{
            logfn();
            _mapView.myLocationEnabled = YES;
        });
    }
    
    return _mapView;
}



-(void) moveToCurrentPlace
{
#if 0
    [self moveToPlace:[LocationManager currentPlace]];
#endif
}


-(void) moveToPlace:(Place*) place
{
    if (nil != place)
    {
        [_mapView animateToLocation:place.coordinate];
    }
}


- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context {
#if 0
    if (!firstLocationUpdate) {
        printf("WWwwwWWWWWWWWWW\n");
        // If the first location update has not yet been recieved, then jump to that
        // location.
        firstLocationUpdate = YES;
        CLLocation *location = [change objectForKey:NSKeyValueChangeNewKey];
        mapView.camera = [GMSCameraPosition cameraWithTarget:location.coordinate
                                                        zoom:14];
    }
#endif
}


-(void) zoomIn
{
    if(zoomLevel > ZOOM_LEVEL_MIN)
    {
        zoomLevel--;
        [self.mapView animateToZoom:zoomLevel];
    }
    
    
}

-(void) zoomOut
{
    
    if(zoomLevel < ZOOM_LEVEL_MAX)
    {
        zoomLevel++;
        [self.mapView animateToZoom:zoomLevel];
    }
}


#pragma  mark -- Delegate

@end

