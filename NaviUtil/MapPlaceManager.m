//
//  MapPlaceManager.m
//  NaviUtil
//
//  Created by Coming on 11/18/13.
//  Copyright (c) 2013 Coming. All rights reserved.
//

#import "MapPlaceManager.h"

@implementation MapPlaceManager
{
    
    NSMutableArray *_searchedPlaces;
    Place *_selectedPlace;
    Place *_currentPlace;
    Place *_routeStartPlace;
    Place *_routeEndPlace;
}

-(void) addPlace:(Place *)p
{
    
    
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


-(Place*) getPlaceByGMSMarker:(GMSMarker*) marker
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



-(void) updateSearchedPlace:(NSArray*) places
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


@end

