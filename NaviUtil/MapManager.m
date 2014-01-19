//
//  MapPlaceManager.m
//  NaviUtil
//
//  Created by Coming on 11/18/13.
//  Copyright (c) 2013 Coming. All rights reserved.
//

#import <objc/runtime.h>
#import <objc/message.h>

#import "MapManager.h"
#import "DownloadRequest.h"
#import "LocationManager.h"
#import "User.h"
#import "NaviQueryManager.h"
#import "NSDictionary+category.h"
#import "GeoUtil.h"

#include "Log.h"

#define ZOOM_LEVEL_MAX 21
#define ZOOM_LEVEL_MIN 1
#define ZOOM_LEVEL_DEFAULT 10
#define VIEW_ANGLE 37.f
#define SEARCHED_PLACE_MAX 5
#define ROUTE_POLYLINE_WIDTH 20

#define NEAR_PLACE_SEARCH_RADIUS 50000  // 50,000 meters, 50Km
#define UPDATE_CURRENT_DISTANCE_THRESHOLD 5

@implementation MapManager 
{
    NSMutableArray *_searchedPlaces;
    Place *selectedPlace;
    Place *currentPlace;
    Place *lastPlace;

    
    int zoomLevel;
    bool isRouteChanged;
    DownloadRequest *routeDownloadRequest;
    DownloadRequest *searchPlaceDownloadRequest;
    DownloadRequest *searchNearPlaceDownloadRequest;

    NSMutableArray* markers;
    NSMutableArray* placesInMarkers;
    GMSMapView *_mapView;
    BOOL _updateToCurrentPlace;
    
    /* marker */
    UIImage* homeMarkerImage;
    UIImage* officeMarkerImage;
    UIImage* favorMarkerImage;
    UIImage* normalMarkerImage;
 
    /* route */
    Route* currentRoute;
    Place* _routeStartPlace;
    Place* _routeEndPlace;
    GMSPolyline* routePolyline;
    
    BOOL _useCurrentPlaceAsRouteStart;

    BOOL isSearchPlaceFinished;
    BOOL isSearchNearPlaceFinished;
}

@synthesize routePolyline;
@synthesize searchedPlaces  = _searchedPlaces;
@synthesize routeStartPlace = _routeStartPlace;
@synthesize routeEndPlace   = _routeEndPlace;

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
    markers             = [[NSMutableArray alloc] initWithCapacity:10];
    placesInMarkers     = [[NSMutableArray alloc] initWithCapacity:10];
    _searchedPlaces     = [[NSMutableArray alloc] initWithCapacity:10];
    homeMarkerImage     = [UIImage imageNamed:@"marker_home"];
    officeMarkerImage   = [UIImage imageNamed:@"marker_office"];
    favorMarkerImage    = [UIImage imageNamed:@"marker_favor"];
    normalMarkerImage   = [UIImage imageNamed:@"marker_normal"];
    
    
    self.useCurrentPlaceAsRouteStart    = TRUE;
    isSearchPlaceFinished               = FALSE;
    isSearchNearPlaceFinished           = FALSE;
    lastPlace                           = nil;
    currentPlace                        = nil;
    
    [self addUserPlacesToMarkers];
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
-(Place*) routeStartPlace
{
    return _routeStartPlace;
}

-(void) setRouteStartPlace:(Place *) p
{
    if (nil == p)
        return;
    
    [self removeRoutePolyline];
    
    /* check on exchanging route start and end place  */
    if ([_routeEndPlace isCoordinateEqualTo:p])
    {
        _routeEndPlace = nil;
    }

    if (![_routeStartPlace isCoordinateEqualTo:p])
    {
        isRouteChanged                   = true;
        /* clear route placeRouteType on previous route start place */
        _routeStartPlace.placeRouteType  = kPlaceRouteType_None;
        _routeStartPlace                 = p;
        _routeStartPlace.placeRouteType  = kPlaceRouteType_Start;
        [self planRoute];
    }
    
    self.hasRoute                       = FALSE;
    
    /* notify the delegate */
    if (nil != self.delegate && [self.delegate respondsToSelector:@selector(mapManager:routeChangedFrom:to:)])
    {
        [self.delegate mapManager:self routeChangedFrom:self.routeStartPlace to:self.routeEndPlace];
    }
    
}

-(Place*) routeEndPlace
{
    return _routeEndPlace;
}

-(void) setRouteEndPlace:(Place *) p
{
    if (nil == p)
        return;

    logO(p);
    [self removeRoutePolyline];
    
    /* check on exchanging route start and end place  */
    if ([_routeStartPlace isCoordinateEqualTo:p])
    {
        _routeStartPlace = nil;
    }
    
    if (![_routeEndPlace isCoordinateEqualTo:p])
    {
        isRouteChanged                  = true;
        /* clear route placeRouteType on previous route end place */
        _routeEndPlace.placeRouteType    = kPlaceRouteType_None;
        _routeEndPlace                   = p;
        _routeEndPlace.placeRouteType    = kPlaceRouteType_End;
        [self planRoute];
    }
    
    self.hasRoute                       = FALSE;
    
    /* notify the delegate */
    if (nil != self.delegate && [self.delegate respondsToSelector:@selector(mapManager:routeChangedFrom:to:)])
    {
        [self.delegate mapManager:self routeChangedFrom:self.routeStartPlace to:self.routeEndPlace];
    }
}


#pragma mark -- MapView
-(GMSMapView*) mapView
{
    if (_mapView == nil) {
        zoomLevel                   = ZOOM_LEVEL_DEFAULT;
        _updateToCurrentPlace       = TRUE;
        currentPlace                = [LocationManager currentPlace];
        
        _mapView                    = [[GMSMapView alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
        
        _mapView.accessibilityLabel = @"mapView";

        _mapView.camera = [GMSCameraPosition cameraWithLatitude:currentPlace.coordinate.latitude
                                                         longitude:currentPlace.coordinate.longitude
                                                              zoom:zoomLevel
                                                           bearing:10.f
                                                        viewingAngle:VIEW_ANGLE];

        [_mapView addObserver:self
                   forKeyPath:@"myLocation"
                      options:NSKeyValueObservingOptionNew
                      context:NULL];

        _mapView.delegate = self;
        
        // Ask for My Location data after the map has already been added to the UI.
        dispatch_async(dispatch_get_main_queue(), ^{
            _mapView.myLocationEnabled = YES;
        });
    }
    
    return _mapView;
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



-(void) clearMap
{
    [_mapView clear];
    [self removeUserPlacesFromMarkers];
    [self removeSearchedPlacesFromMarkers];
    [self removeRoutePolyline];
}

-(void) moveToMyLocation
{
    [self moveToPlace:currentPlace];
}

-(void) moveToPlace:(Place*) place
{
    if (nil != place)
    {
        [_mapView animateToLocation:place.coordinate];
    }
}

-(void) moveToSearchedPlaceByIndex:(int) index
{
    if (index >= 0 && index < _searchedPlaces.count)
    {
        [self moveToPlace:[_searchedPlaces objectAtIndex:index]];
    }
    
}

-(void) observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context {
    CLLocation *location;
    
    location        = [change objectForKey:NSKeyValueChangeNewKey];
    
    if ([GeoUtil getGeoDistanceFromLocation:lastPlace.coordinate ToLocation:location.coordinate] > UPDATE_CURRENT_DISTANCE_THRESHOLD)
    {
        lastPlace               = currentPlace;
        currentPlace            = [[Place alloc] initWithName:[SystemManager getLanguageString:@"Current Location"]
                                                      address:@""
                                                   coordinate:CLLocationCoordinate2DMake(location.coordinate.latitude, location.coordinate.longitude)];
        currentPlace.placeType  = kPlaceType_CurrentPlace;

    
        // reset route start place
        if (YES == self.useCurrentPlaceAsRouteStart && YES == [currentPlace.name isEqualToString:self.routeStartPlace.name])
        {
            [self setRouteStartPlace:currentPlace];
        
        }

        if ( YES == self.updateToCurrentPlace )
        {
            self.mapView.camera         = [GMSCameraPosition cameraWithTarget:location.coordinate zoom:zoomLevel];
            self.updateToCurrentPlace   = NO;
        }
    
    }
}

-(void) refreshMap
{
    [self clearMap];
    
    [self addUserPlacesToMarkers];
    [self addSearchedPlacesToMarkers];
    [self addRoutePolyline];
    
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


#pragma mark -- Route

-(void) addRoutePolyline
{
    NSArray *routePoints;
    GMSMutablePath *path;
    
    if (nil == currentRoute || nil == self.routeStartPlace || nil == self.routeEndPlace)
    {
        return;
    }
    
    routePoints                 = [currentRoute getRoutePolyLineCLLocation];
    routePolyline               = [[GMSPolyline alloc] init];
    routePolyline.strokeWidth   = ROUTE_POLYLINE_WIDTH;
    routePolyline.strokeColor   = [UIColor blueColor];
    path                        = [GMSMutablePath path];
    
    for(CLLocation *location in routePoints)
    {
        [path addCoordinate:location.coordinate];
    }
    
    routePolyline.path       = path;
    routePolyline.geodesic   = NO;
    routePolyline.map        = _mapView;
    
}



-(void) planRoute
{
    if (FALSE == [NaviQueryManager mapServerReachable])
    {
        if (nil != self.delegate && [self.delegate respondsToSelector:@selector(mapManager:connectToServer:)])
        {
            [self.delegate mapManager:self connectToServer:FALSE];
        }
    }
    
    if (isRouteChanged == true)
    {
        if (nil != self.routeStartPlace && nil != self.routeEndPlace)
        {
            if (![self.routeStartPlace isCoordinateEqualTo:self.routeEndPlace])
            {
                routeDownloadRequest = [NaviQueryManager
                                        getRouteDownloadRequestFrom:self.routeStartPlace.coordinate
                                        To:self.routeEndPlace.coordinate];
                routeDownloadRequest.delegate = self;
                
                if ([GoogleJson getStatus:routeDownloadRequest.fileName] != kGoogleJsonStatus_Ok)
                {
                    [NaviQueryManager download:routeDownloadRequest];
                }
            }
            
        }
    }
    
    isRouteChanged = false;
}

-(void) processRouteDownloadRequestStatusChange
{
    bool updateStatus = false;
    /* search place finished */
    if (routeDownloadRequest.status == kDownloadStatus_Finished)
    {
        GoogleJsonStatus status = [GoogleJson getStatus:routeDownloadRequest.filePath];
        
        if ( kGoogleJsonStatus_Ok == status)
        {
            currentRoute = [Route parseJson:routeDownloadRequest.filePath];
            [User addRecentPlace:self.routeEndPlace];
            [User save];
            [self removeRoutePolyline];
            [self addRoutePolyline];
            self.hasRoute = TRUE;
        }
        else
        {
            updateStatus = true;
        }
    }
    /* search failed */
    else if(routeDownloadRequest.status == kDownloadStatus_DownloadFail)
    {
        updateStatus = true;
        
        if (nil != self.delegate && [self.delegate respondsToSelector:@selector(mapManager:routePlanning:)])
        {
            [self.delegate mapManager:self routePlanning:FALSE];
        }
    }
}

-(void) removeRoutePolyline
{
    if (nil != routePolyline)
        routePolyline.map = nil;
    
    routePolyline = nil;
}

-(BOOL) checkNetwork
{
    
    if (nil != self.delegate && [self.delegate respondsToSelector:@selector(mapManager:connectToServer:)])
    {
        [self.delegate mapManager:self connectToServer:TRUE];
    }
    
    return TRUE;
}

#pragma mark -- Marker

-(void) addPlaceToMarker:(Place*) p
{
    GMSMarker *marker;

    if (nil == p)
        return;

    marker          = [[GMSMarker alloc] init];
    marker.title    = p.name;
    marker.snippet  = p.address;
    marker.position = p.coordinate;
    
    if (p.placeType == kPlaceType_Home)
    {
        marker.icon = homeMarkerImage;
    }
    else if (p.placeType == kPlaceType_Office )
    {
        marker.icon = officeMarkerImage;
    }
    else if (p.placeType == kPlaceType_Favor )
    {
        marker.icon = favorMarkerImage;
    }
    else
    {
        marker.icon = normalMarkerImage;
    }
    
    marker.map      = self.mapView;

    [markers addObject:marker];
    [placesInMarkers addObject:p];
    
}

-(void) addCurrentPlaceToMarkers
{
    if (nil != currentPlace)
    {
        [self addPlaceToMarker:currentPlace];
    }
    
}
-(void) addUserPlacesToMarkers
{
    int i;
    
    for(i=0; i<User.homePlaces.count; i++)
    {
        [self addPlaceToMarker:[User getHomePlaceByIndex:i]];
    }
    
    for(i=0; i<User.officePlaces.count; i++)
    {
        [self addPlaceToMarker:[User getOfficePlaceByIndex:i]];
    }
    
    for(i=0; i<User.favorPlaces.count; i++)
    {
        [self addPlaceToMarker:[User getFavorPlaceByIndex:i]];
    }
}

-(void) addNearSearchedPlaces:(NSArray*) places
{
    int i;
    int insertedCount;
    
    
    /* only reserve the first three places */
    for(i=0, insertedCount=0; i<places.count && i < SEARCHED_PLACE_MAX; i++)
    {
        Place *p = [places objectAtIndex:i];
        /* add the first search result no matter what */
        if (false == [self isPlaceInSearchedPlaces:p])
        {
            [_searchedPlaces insertObject:p atIndex:insertedCount++];
        }
    }

    [self addSearchedPlacesToMarkers];
}

-(void) addSearchedPlaces:(NSArray*) places
{
    int i=0;
    
    /* only reserve the first three places */
    for(i=0; i<places.count && i < SEARCHED_PLACE_MAX; i++)
    {
        Place *p = [places objectAtIndex:i];
        /* add the first search result no matter what */
        if (false == [self isPlaceInSearchedPlaces:p])
        {
            [_searchedPlaces addObject:p];
        }
    }
    

    [self addSearchedPlacesToMarkers];
}


-(void) addSearchedPlacesToMarkers
{
    for (Place *p in self.searchedPlaces)
    {
    
        if (FALSE == [self isPlaceInUserPlaces:p])
        {
            [self addPlaceToMarker:p];
        }
    }
}

-(BOOL) isPlaceInUserPlaces:(Place *) p
{
    
    for (Place *tp in User.homePlaces)
    {
        if ([tp isCoordinateEqualTo:p])
            return TRUE;
    }

    for (Place *tp in User.officePlaces)
    {
        if ([tp isCoordinateEqualTo:p])
            return TRUE;
    }
    
    for (Place *tp in User.favorPlaces)
    {
        if ([tp isCoordinateEqualTo:p])
            return TRUE;
    }
    
    return FALSE;
}

-(void) processSearchPlaceDownloadRequestStatusChange:(DownloadRequest*) downloadRequest
{
    
    bool isFail = true;
    bool updateStatus = false;
    /* search place finished */
    if(downloadRequest.status == kDownloadStatus_Finished )
    {
        NSArray* places;
        GoogleJsonStatus status = [GoogleJson getStatus:downloadRequest.filePath];
        
        if ( kGoogleJsonStatus_Ok == status)
        {
            places = [Place parseJson:downloadRequest.filePath];
            if(places != nil && places.count > 0)
            {
                /* clear search result */
                if (FALSE == isSearchNearPlaceFinished && FALSE == isSearchPlaceFinished)
                {
                    [self removeSearchedPlaces];
                }
                
                if (downloadRequest == searchNearPlaceDownloadRequest)
                {
                    [self addNearSearchedPlaces:places];
                    isSearchNearPlaceFinished = TRUE;
                }
                else
                {
                    [self addSearchedPlaces:places];
                    isSearchPlaceFinished = TRUE;
                }
                
                if (YES == isSearchPlaceFinished && YES == isSearchNearPlaceFinished)
                {
                    /* move to first place */
                    if (_searchedPlaces.count > 0)
                    {
                        for (Place* p in _searchedPlaces)
                        {
                            [User addSearchedPlace:p];
                        }
                        [self moveToPlace:[_searchedPlaces objectAtIndex:0]];
                    }

                    /* notify the delegate */
                    if (nil != self.delegate && [self.delegate respondsToSelector:@selector(mapManager:placeSearchResult:)])
                    {
                        [self.delegate mapManager:self placeSearchResult:self.searchedPlaces];
                    }
                    

                    isFail = false;
                }
            }
        }
        updateStatus = true;
    }
    /* search place failed */
    else if( searchPlaceDownloadRequest.status == kDownloadStatus_DownloadFail)
    {
        updateStatus = true;
    }
    
    if (FALSE == isSearchNearPlaceFinished && FALSE == isSearchPlaceFinished)
    {
        [self removeSearchedPlaces];
    }
    
    /* set search place status */
    if (downloadRequest == searchNearPlaceDownloadRequest)
    {
        isSearchNearPlaceFinished   = TRUE;
    }
    else
    {
        isSearchPlaceFinished       = TRUE;
    }
    
}

-(void) removeCurrentPlaceFromMarkers
{

    @@@@@
}
-(void) removeUserPlacesFromMarkers
{
    int i=0;
    GMSMarker* marker;
    NSMutableArray* markersToRemove;
    
    markersToRemove = [[NSMutableArray alloc] initWithCapacity:10];
    
    
    /* get these markers to be removed */
    for (i=0; i<markers.count; i++)
    {
        marker = [markers objectAtIndex:i];
        if (marker.icon == homeMarkerImage || marker.icon == officeMarkerImage || marker.icon == favorMarkerImage)
        {
            [markers removeObjectAtIndex:i];
            [placesInMarkers removeObjectAtIndex:i];
            i--;
        }
    }
}

-(void) removeSearchedPlacesFromMarkers
{
    int i=0;
    GMSMarker* marker;
    NSMutableArray* markersToRemove;
    
    markersToRemove = [[NSMutableArray alloc] initWithCapacity:10];
    
    
    /* get these markers to be removed */
    for (i=0; i<markers.count; i++)
    {
        marker = [markers objectAtIndex:i];
        if (marker.icon == normalMarkerImage)
        {
            [markers removeObjectAtIndex:i];
            [placesInMarkers removeObjectAtIndex:i];
        }
    }
}


#pragma mark -- Place
-(Place*) placeByMarker:(GMSMarker*) k
{
    int i;
    GMSMarker *marker;

    if (nil == k)
        return nil;

    
    for (i=0; i<markers.count; i++)
    {
        marker = [markers objectAtIndex:i];
        
        if ([GeoUtil isCLLocationCoordinate2DEqual:marker.position To:k.position])
        {
            return [placesInMarkers objectAtIndex:i];
        }
    }


    return nil;
}


-(void) searchPlace:(NSString*) place
{
    if (nil != place && place.length > 0)
    {
        searchNearPlaceDownloadRequest          = [NaviQueryManager getNearPlaceDownloadRequest:place
                                                                                       locaiton:currentPlace.coordinate
                                                                                         radius:NEAR_PLACE_SEARCH_RADIUS];
        searchNearPlaceDownloadRequest.delegate = self;
        searchPlaceDownloadRequest              = [NaviQueryManager getPlaceDownloadRequest:place];
        searchPlaceDownloadRequest.delegate     = self;
        
        [NaviQueryManager download:searchNearPlaceDownloadRequest];
        [NaviQueryManager download:searchPlaceDownloadRequest];
        
        isSearchNearPlaceFinished   = FALSE;
        isSearchPlaceFinished       = FALSE;
    }
}




-(void) removeSearchedPlaces
{
    [self removeSearchedPlacesFromMarkers];
    [_searchedPlaces removeAllObjects];
    [User removeAllSearchedPlaces];
}




#pragma  mark -- Delegate

-(void) downloadRequestStatusChange: (DownloadRequest*) downloadRequest
{
    if (nil == downloadRequest)
        return;
    if (searchPlaceDownloadRequest == downloadRequest || searchNearPlaceDownloadRequest == downloadRequest)
    {
        [self processSearchPlaceDownloadRequestStatusChange:downloadRequest];
    }
    else if (routeDownloadRequest == downloadRequest)
    {
        [self processRouteDownloadRequestStatusChange];
    }

}
@end

