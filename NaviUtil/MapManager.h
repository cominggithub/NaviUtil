//
//  MapPlaceManager.h
//  NaviUtil
//
//  Created by Coming on 11/18/13.
//  Copyright (c) 2013 Coming. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GoogleMaps/GoogleMaps.h>
#import "Place.h"
#import "DownloadManager.h"


@class MapManager;

@protocol MapManagerDelegate <NSObject>
-(void) mapManager: (MapManager*) mapManager placeSearchResult:(NSArray*) places;
-(void) mapManager: (MapManager*) mapManager updateCurrentPlace:(Place*) place;
-(void) mapManager: (MapManager*) mapManager routeChangedFrom:(Place*) fromPlace to:(Place*) toPlace;
@end

@interface MapManager : NSObject <GMSMapViewDelegate, DownloadRequestDelegate>
{
    
 
}

@property GMSPolyline* routePolyline;
//@property GMSMapView* mapView;
@property NSArray* searchedPlaces;
@property BOOL hasRoute;
@property BOOL updateToCurrentPlace;
@property BOOL useCurrentPlaceAsRouteStart;
@property Place* routeStartPlace;
@property Place* routeEndPlace;
@property CGRect frame;
@property id<MapManagerDelegate> delegate;

-(void) searchPlace:(NSString*) placeText;
-(void) moveToSearchedPlaceByIndex:(int) index;
-(GMSMapView*) mapView;

-(Place*) placeByMarker:(GMSMarker*) marker;
-(void) moveToPlace:(Place*) place;
-(void) refreshMap;
-(void) moveToMyLocation;

-(void) zoomIn;
-(void) zoomOut;
@end
