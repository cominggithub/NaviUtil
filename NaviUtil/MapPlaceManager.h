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

@interface MapPlaceManager : NSObject
{
    

}

-(void) addPlace:(Place*) p;
-(void) removePlace:(Place*) p;
-(Place*) getPlaceByGMSMarker:(GMSMarker*) marker;
@end
