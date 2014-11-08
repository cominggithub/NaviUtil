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

#define FILE_DEBUG TRUE
#include "Log.h"

#define ZOOM_LEVEL_MAX 21
#define ZOOM_LEVEL_MIN 1
#define ZOOM_LEVEL_DEFAULT 10
#define VIEW_ANGLE 37.f
#define SEARCHED_PLACE_MAX 5
#define ROUTE_POLYLINE_WIDTH 10

#define NEAR_PLACE_SEARCH_RADIUS 50000  // 50,000 meters, 50Km
#define UPDATE_CURRENT_DISTANCE_THRESHOLD  2

@implementation MapManager 
{
    NSMutableArray *_searchedPlaces;
    Place *selectedPlace;

    Place *lastPlace;

    
    int zoomLevel;
    bool isRouteChanged;
    DownloadRequest *routeDownloadRequest;
    DownloadRequest *searchPlaceTextSearchDownloadRequest;
    DownloadRequest *searchPlaceRadarSearchDownloadRequest;

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
    UIColor *routePolyLineColor;
    
    /* cache searched places */
    NSMutableDictionary *cachedSearch;
    int newLocationCount;
    
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
    cachedSearch        = [[NSMutableDictionary alloc] init];
    homeMarkerImage     = [UIImage imageNamed:@"marker_home"];
    officeMarkerImage   = [UIImage imageNamed:@"marker_office"];
    favorMarkerImage    = [UIImage imageNamed:@"marker_favor"];
    normalMarkerImage   = [UIImage imageNamed:@"marker_normal"];
    
    
    self.useCurrentPlaceAsRouteStart            = TRUE;
    lastPlace                                   = nil;
    self.currentPlace                           = nil;
    self.isShowPlanRouteFailedForCurrentPlace   = TRUE;
    routePolyLineColor                          = [UIColor redColor];
    newLocationCount                            = 1;
    [self addUserPlacesToMarkers];

}

- (void)dealloc
{
    if (_mapView != nil)
    {
        [_mapView removeObserver:self
                     forKeyPath:@"myLocation"
                        context:NULL];
        _mapView.delegate   = nil;
        _mapView            = nil;
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
    
    /* check on exchanging route start and end place  */
    if ([_routeEndPlace isCoordinateEqualTo:p])
    {
        _routeEndPlace = nil;
        [self removeRoutePolyline];
    }
    
    if (!self.hasRoute || ![_routeStartPlace isCoordinateEqualTo:p] || ![_routeStartPlace.name isEqualToString:p.name])
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

    /* check on exchanging route start and end place  */
    if ([_routeStartPlace isCoordinateEqualTo:p])
    {
        _routeStartPlace = nil;
        [self removeRoutePolyline];
    }
    
    if (!self.hasRoute || ![_routeEndPlace isCoordinateEqualTo:p] || ![_routeEndPlace.name isEqualToString:p.name])
    {
        isRouteChanged                   = true;
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
        self.currentPlace           = [LocationManager currentPlace];
        
        _mapView                    = [[GMSMapView alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
        
        _mapView.accessibilityLabel = @"mapView";

        _mapView.camera = [GMSCameraPosition cameraWithLatitude:self.currentPlace.coordinate.latitude
                                                      longitude:self.currentPlace.coordinate.longitude
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
}

-(void) moveToMyLocation
{
    [self moveToPlace:self.currentPlace];
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

/* capture mylocation update event */
-(void) observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context {
    CLLocation *location;
    location        = [change objectForKey:NSKeyValueChangeNewKey];
    static float gg = 0.00000;

    if (NO == self.viewAppear)
    {
        return;
    }

    if (nil == lastPlace || [GeoUtil getGeoDistanceFromLocation:lastPlace.coordinate ToLocation:location.coordinate] > UPDATE_CURRENT_DISTANCE_THRESHOLD)
    {
        gg += 0.00001;
        lastPlace               = self.currentPlace;
        self.currentPlace       = [[Place alloc] initWithName:[SystemManager getLanguageString:@"Current Location"]
                                                      address:@""
                                                   coordinate:CLLocationCoordinate2DMake(location.coordinate.latitude, location.coordinate.longitude)];
        self.currentPlace.placeType  = kPlaceType_CurrentPlace;
        [self removeCurrentPlaceFromMarkers];
        [self addCurrentPlaceToMarkers];

        // reset route start place
        if ((self.useCurrentPlaceAsRouteStart && nil == self.routeStartPlace) ||
            self.routeStartPlace.placeType == kPlaceType_CurrentPlace)
        {
            [self setRouteStartPlace:self.currentPlace];
        }
        else if (self.routeEndPlace.placeType == kPlaceType_CurrentPlace)
        {
            [self setRouteEndPlace:self.currentPlace];
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
    /* google map bug, deleted marker is still on the map */
    for (GMSMarker *marker in markers)
    {
        marker.map = nil;
    }
    
    
    
    [markers removeAllObjects];
    [_mapView clear];
    
    [self addCurrentPlaceToMarkers];
    [self addUserPlacesToMarkers];
    [self addSearchedPlacesToMarkers];
    [self replaceRoutePolyline];
    
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

-(void) replaceRoutePolyline
{
    NSArray *routePoints;
    GMSMutablePath *path;
    GMSPolyline *prevRoutePolyLine;
    
    prevRoutePolyLine = routePolyline;
    
    if (nil == currentRoute || nil == self.routeStartPlace || nil == self.routeEndPlace)
    {
        return;
    }
    
    routePoints                 = [currentRoute getRoutePolyLineCLLocation];
    routePolyline               = [[GMSPolyline alloc] init];
    routePolyline.strokeWidth   = ROUTE_POLYLINE_WIDTH;
    routePolyline.strokeColor   = routePolyLineColor;
    path                        = [GMSMutablePath path];
    
    for(CLLocation *location in routePoints)
    {
        [path addCoordinate:location.coordinate];
    }
    
    routePolyline.path       = path;
    routePolyline.geodesic   = NO;
    routePolyline.map        = _mapView;
    
    if (nil != prevRoutePolyLine)
    {
        prevRoutePolyLine.map = nil;
        prevRoutePolyLine = nil;
    }
    
}

-(void) planRoute
{
    if (isRouteChanged == true)
    {
        if (nil != self.routeStartPlace && nil != self.routeEndPlace)
        {
            if (FALSE == [NaviQueryManager mapServerReachable])
            {
                if (nil != self.delegate && [self.delegate respondsToSelector:@selector(mapManager:connectToServer:)])
                {
                    
                    [self.delegate mapManager:self connectToServer:FALSE];
                }
                self.isShowPlanRouteFailedForCurrentPlace = FALSE;
            }

            if (![self.routeStartPlace isCoordinateEqualTo:self.routeEndPlace])
            {
                routeDownloadRequest = [NaviQueryManager
                                        getRouteDownloadRequestFrom:self.routeStartPlace.coordinate
                                        To:self.routeEndPlace.coordinate];
                
                routeDownloadRequest.delegate = self;
                
                if ([GoogleJson getStatus:routeDownloadRequest.fileName] != kGoogleJsonStatus_Ok)
                {
                    if (nil != self.delegate && [self.delegate respondsToSelector:@selector(mapManager:startRoutePlanning:)])
                    {
                        
                        [self.delegate mapManager:self startRoutePlanning:TRUE];
                    }
                    
                    [NaviQueryManager download:routeDownloadRequest];
                }
            }
            
        }
    }
    
    isRouteChanged = false;
}

-(void) processRouteDownloadRequestStatusChange
{
    /* search place finished */
    if (routeDownloadRequest.status == kDownloadStatus_Finished)
    {
        GoogleJsonStatus status = [GoogleJson getStatus:routeDownloadRequest.filePath];
        
        if ( kGoogleJsonStatus_Ok == status)
        {
            currentRoute = [Route parseJson:routeDownloadRequest.filePath];

                // should not save route end place here
//            if (self.routeEndPlace.placeType == kPlaceType_Home ||
//                self.routeEndPlace.placeType == kPlaceType_Favor ||
//                self.routeEndPlace.placeType == kPlaceType_Office ||
//                self.routeEndPlace.placeType == kPlaceType_SearchedPlace ||
//                self.routeEndPlace.placeType == kPlaceType_None)
//            {
//                [User addRecentPlace:self.routeEndPlace];
//                [User save];
//            }
            
            [self replaceRoutePolyline];
            self.hasRoute = TRUE;
            self.isShowPlanRouteFailedForCurrentPlace = TRUE;
        }
        
        if (nil != self.delegate && [self.delegate respondsToSelector:@selector(mapManager:routePlanning:)])
        {
            [self.delegate mapManager:self routePlanning:TRUE];
        }
        
    }
    /* search failed */
    else if(YES == routeDownloadRequest.done)
    {
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
    marker.userData = p;
    
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
}


-(void) addCurrentPlaceToMarkers
{

    mlogAssertNotNil(self.currentPlace);
    if ( FALSE == [User placeCloseToUserPlace:self.currentPlace ])
    {
        [self addPlaceToMarker:self.currentPlace];
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
        p.placeType = kPlaceType_SearchedPlace;
        /* add the first search result no matter what */
        if (false == [self isPlaceInSearchedPlaces:p])
        {
            [_searchedPlaces addObject:p];
        }
    }
    

    [self addSearchedPlacesToMarkers];
}

-(void) addUserTappedPlace:(Place*) place
{
    place.placeType = kPlaceType_SearchedPlace;
    /* add the first search result no matter what */
    if (false == [self isPlaceInSearchedPlaces:place])
    {
        [_searchedPlaces addObject:place];
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

-(BOOL) isPlaceCloseToUserPlaces:(Place*) p
{
//    Place* tmpPlace;
    for(Place* tmpPlace in User.homePlaces)
    {
        if ([p isCloseTo:tmpPlace]) return TRUE;
    }

    for(Place* tmpPlace in User.officePlaces)
    {
        if ([p isCloseTo:tmpPlace]) return TRUE;
    }

    for(Place* tmpPlace in User.favorPlaces)
    {
        if ([p isCloseTo:tmpPlace]) return TRUE;
    }
    
    return FALSE;
}


-(void) removeCurrentPlaceFromMarkers
{
    int i;
    GMSMarker *marker;
    Place *place;

    for (i=0; i<markers.count; i++)
    {
        marker = [markers objectAtIndex:i];
        place = marker.userData;
        if (place.placeType == kPlaceType_CurrentPlace)
        {
            [markers removeObjectAtIndex:i];
            marker.map = nil;
            i--;
        }
    }

}

#if 0
-(void) removeUserPlacesFromMarkers
{

    int i=0;
    GMSMarker* marker;
    Place* p;
    NSMutableArray* markersToRemove;
    
    markersToRemove = [[NSMutableArray alloc] initWithCapacity:10];
    
    
    /* get these markers to be removed */
    for (i=0; i<markers.count; i++)
    {
        marker = [markers objectAtIndex:i];
        p = (Place*) marker.
        if (marker.icon == homeMarkerImage || marker.icon == officeMarkerImage || marker.icon == favorMarkerImage)
        {
            [markers removeObjectAtIndex:i];
//            [placesInMarkers removeObjectAtIndex:i];
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
#endif

#pragma mark -- Place
#if 0
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
#endif

-(void) searchPlace:(NSString *)locationName
{
    logO(locationName);
    if (nil != locationName && locationName.length > 0)
    {
        [self searchPlaceByRadarSearch:locationName];
    }
}

-(NSMutableArray*) searchPlaceInCache:(NSString*) locationName
{
 
    NSMutableArray* places;
    mlogDebug(@"%@: search in cache\n", locationName);
    places = [cachedSearch objectForKey:locationName];
    
    return places;
}



-(void) searchPlaceByTextSearch:(NSString*) locationName
{
    if (nil != locationName && locationName.length > 0)
    {
        searchPlaceTextSearchDownloadRequest          = [NaviQueryManager getPlaceTextSearchDownloadRequest:locationName];
        searchPlaceTextSearchDownloadRequest.delegate = self;

        [NaviQueryManager download:searchPlaceTextSearchDownloadRequest];
    }
}


-(void) searchPlaceByRadarSearch:(NSString*) locationName
{
    if (nil != locationName && locationName.length > 0)
    {
        logfn();
        searchPlaceRadarSearchDownloadRequest          = [NaviQueryManager getPlaceNearBySearchDownloadRequest:locationName
                                                                                  locaiton:self.currentPlace.coordinate
                                                                                    radius:NEAR_PLACE_SEARCH_RADIUS];
        searchPlaceRadarSearchDownloadRequest.delegate = self;
        [NaviQueryManager download:searchPlaceRadarSearchDownloadRequest];
    }
}

-(void) addSearchedPlacesToCache:(NSString*) locationName places:(NSArray*) places
{
    if (nil != locationName && locationName.length > 0 && nil != places && places.count > 0)
    {
        [cachedSearch setObject:places forKey:locationName];
    }
}

-(void) removeSearchedPlaces
{
//    [self removeSearchedPlacesFromMarkers];
    [_searchedPlaces removeAllObjects];
    [User removeAllSearchedPlaces];
    newLocationCount = 1;
}

-(void) processSearchPlaceDownloadRequestStatusChange:(DownloadRequest*) downloadRequest
{
    
    BOOL hasPlace = FALSE;
    NSArray* places;
    
    
    /* search place finished */
    if(downloadRequest.status == kDownloadStatus_Finished)
    {
        
        GoogleJsonStatus status = [GoogleJson getStatus:downloadRequest.filePath];
        
        /* parse ok */
        if ( kGoogleJsonStatus_Ok == status)
        {
            places = [Place parseJson:downloadRequest.filePath];
            hasPlace = places != nil && places.count > 0;
            
        }
    }
    
    if (TRUE == downloadRequest.done)
    {
        if (downloadRequest == searchPlaceRadarSearchDownloadRequest)
        {
            if (TRUE == hasPlace)
            {
                mlogDebug(@"%@: radar search success", downloadRequest.name);
                [self removeSearchedPlaces];
                [self addSearchedPlaces:places];
            }
            else
            {
                mlogDebug(@"%@: radar search failed, search in cache instead",  downloadRequest.name);
                
                places = [self searchPlaceInCache:downloadRequest.name];
                if (nil != places && places.count > 0)
                {
                    mlogDebug(@"%@: search in cache success", downloadRequest.name);
                    [self removeSearchedPlaces];
                    [self addSearchedPlaces:places];
                    hasPlace = TRUE;
                }
                else
                {
                    mlogDebug(@"%@: search in cache failed, use text search\n", downloadRequest.name);
                    [self searchPlaceByTextSearch:searchPlaceRadarSearchDownloadRequest.name];
                }
            }
        }
        else if(downloadRequest == searchPlaceTextSearchDownloadRequest)
        {
            if (TRUE == hasPlace)
            {
                mlogDebug(@"%@: text search success",  downloadRequest.name);
                [self removeSearchedPlaces];
                [self addSearchedPlaces:places];
                [self addSearchedPlacesToCache:downloadRequest.name places:places];
            }
            else
            {
                mlogDebug(@"%@: text search failed, notify delegate", downloadRequest.name);
                /* search failed, notify the delegate */
                if (nil != self.delegate && [self.delegate respondsToSelector:@selector(mapManager:searchPlaces:)])
                {
                    [self.delegate mapManager:self searchPlaces:FALSE];
                }
            }
        }

        /* has places, notify the delegate */
        if (TRUE == hasPlace)
        {
            if (nil != self.delegate && [self.delegate respondsToSelector:@selector(mapManager:placeSearchResult:)])
            {
                mlogDebug(@"notify the delegate with research placed\n");
                [self.delegate mapManager:self placeSearchResult:places];
            }
        }
    }
    
}


#pragma  mark -- Delegate

-(void) downloadRequest:(DownloadRequest*) downloadRequest status:(DownloadStatus) status;
{
    if (nil == downloadRequest)
        return;
    
    if (searchPlaceRadarSearchDownloadRequest == downloadRequest || searchPlaceTextSearchDownloadRequest == downloadRequest)
    {
        [self processSearchPlaceDownloadRequestStatusChange:downloadRequest];
    }
    else if (routeDownloadRequest == downloadRequest)
    {
        [self processRouteDownloadRequestStatusChange];
    }

}

- (BOOL) mapView:(GMSMapView *)mapView didTapMarker:(GMSMarker *)marker
{
    /* notify the delegate */
    if (nil != self.delegate && [self.delegate respondsToSelector:@selector(mapManager:didTapMarker:)])
    {
        return [self.delegate mapManager:self didTapMarker:marker];
    }
    
    return NO;
}


- (void)mapView:(GMSMapView *)mapView didTapAtCoordinate:(CLLocationCoordinate2D)coordinate
{
    /* notify the delegate */
    if (nil != self.delegate && [self.delegate respondsToSelector:@selector(mapManager:didTapAtCoordinate:)])
    {
        [self.delegate mapManager:self didTapAtCoordinate:coordinate];
    }
    
}

- (void)mapView:(GMSMapView *)mapView didChangeCameraPosition:(GMSCameraPosition *)position
{
    /* notify the delegate */
    if (nil != self.delegate && [self.delegate respondsToSelector:@selector(mapManager:didChangeCameraPosition:)])
    {
        [self.delegate mapManager:self didChangeCameraPosition:position];
    }
}

- (void)mapView:(GMSMapView *)mapView willMove:(BOOL)gesture;
{
    /* notify the delegate */
    if (nil != self.delegate && [self.delegate respondsToSelector:@selector(mapManager:willMove:)])
    {
        [self.delegate mapManager:self willMove:gesture];
    }
}

-(void)mapView:(GMSMapView *)mapView didLongPressAtCoordinate:(CLLocationCoordinate2D)coordinate
{
    Place *newPlace = [[Place alloc] initWithName:
                        [NSString stringWithFormat:@"%@%d", [SystemManager getLanguageString:@"New Place"], newLocationCount++]
                        address:@""
                     coordinate:CLLocationCoordinate2DMake(coordinate.latitude, coordinate.longitude)];

    [self addUserTappedPlace:newPlace];
}

@end

