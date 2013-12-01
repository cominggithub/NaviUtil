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

@interface MapManager : NSObject <GMSMapViewDelegate>
{
    
 
}

@property GMSPolyline* routePolyline;
//@property GMSMapView* mapView;
@property NSArray* searchedPlaces;
@property BOOL hasRoute;
@property Place* routeStartPlace;
@property Place* routeEndPlace;
@property CGRect frame;

-(void) addSearchedPlaces:(NSArray*) places;
-(void) addPlace:(Place*) p;
-(void) removePlace:(Place*) p;
-(void) setRouteStart:(Place*) marker;
-(void) setRouteEnd:(Place*) marker;
-(void) planRoute;
-(void) clearRoute;
-(GMSMapView*) mapView;

-(Place*) placeByGMSMarker:(GMSMarker*) marker;
-(NSArray*) placeMarkers;
-(void) moveToPlace:(Place*) place;

-(void) zoomIn;
-(void) zoomOut;
@end
