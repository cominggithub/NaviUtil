//
//  RouteTrack.m
//  NaviUtil
//
//  Created by Coming on 5/10/14.
//  Copyright (c) 2014 Coming. All rights reserved.
//

#import "RouteTrack.h"

#include "Log.h"

@implementation RouteTrack
{
    NSMutableArray *routes;
    NSMutableArray *locations;
    NSMutableArray *events;
    NSString* _kmlFileName;
    NSFileHandle *_fileHandle;
}

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
    routes      = [[NSMutableArray alloc] init];
    locations   = [[NSMutableArray alloc] init];
    events      = [[NSMutableArray alloc] init];
    
}

-(void) addRoute:(Route*) route
{
    [routes addObject:route];
}

-(void) addLocation:(CLLocation*) location event:(GR_EVENT) event
{
    [locations addObject:location];
    [events addObject:[NSNumber numberWithInt:event]];
}

-(void) save
{
    NSMutableString *content = [[NSMutableString alloc] init];

    NSError *err;
    
    
    
    [content appendString:@"<?xml version=\"1.0\" standalone=\"yes\"?>\n"];
    [content appendString:@"<kml xmlns=\"http://earth.google.com/kml/2.2\">\n"];
    [content appendString:@"<Document>\n"];
    [content appendFormat:@"<name>KK</name>\n"];

    [content appendString:@"<Style id=\"red_marker\">"];
    [content appendString:@"<IconStyle>"];
    [content appendString:@"<color>ff172cff</color>"];
    [content appendString:@"<scale>1.1</scale>"];
    [content appendString:@"<Icon>"];
    [content appendString:@"<href>http://maps.google.com/mapfiles/kml/pushpin/ylw-pushpin.png</href>"];
    [content appendString:@"</Icon>"];
    [content appendString:@"<hotSpot x=\"20\" y=\"2\" xunits=\"pixels\" yunits=\"pixels\"/>"];
    [content appendString:@"</IconStyle>"];
    [content appendString:@"</Style>"];

    [content appendString:@"<Style id=\"green_marker\">"];
    [content appendString:@"<IconStyle>"];
    [content appendString:@"<color>FF00FF00</color>"];
    [content appendString:@"<scale>1.1</scale>"];
    [content appendString:@"<Icon>"];
    [content appendString:@"<href>http://maps.google.com/mapfiles/kml/pushpin/ylw-pushpin.png</href>"];
    [content appendString:@"</Icon>"];
    [content appendString:@"<hotSpot x=\"20\" y=\"2\" xunits=\"pixels\" yunits=\"pixels\"/>"];
    [content appendString:@"</IconStyle>"];
    [content appendString:@"</Style>"];

    
    for (int i=0; i<routes.count; i++)
    {
        [content appendString:[self getPlaceMarkerForRoute:[routes objectAtIndex:i] index:i]];
    }

    for (int i=0; i<locations.count; i++)
    {
        [content appendString:[self getPlaceMarkerForLocation:[locations objectAtIndex:i]
                                                        event:[events objectAtIndex:i]
                                                        index:i]];
    }
    
    [content appendString:@"</Document>\n"];
    [content appendString:@"</kml>"];
    _kmlFileName = [NSString stringWithFormat:@"%@/RT_%@.kml", [SystemManager getPath:kSystemManager_Path_Track], self.name];
    [content writeToFile:_kmlFileName atomically:YES encoding:NSUnicodeStringEncoding error:&err];
    
}

-(NSString*) getPlaceMarkerForRoute:(Route*)route index:(int) index
{
    NSMutableString *content = [[NSMutableString alloc] init];
    NSMutableString *coordinates = [[NSMutableString alloc] init];
    NSArray* routePolyLine = route.getRoutePolyLineCLLocation;
    
    for(CLLocation* cl in routePolyLine)
    {
        [coordinates appendFormat:@"%f,%f,0 \n", cl.coordinate.longitude, cl.coordinate.latitude];
    }
    
    [content appendString:@"<Placemark>\n"];
    [content appendString:[NSString stringWithFormat:@"<name>route %d</name>", index]];
    [content appendString:@"<Style>\n"];
    [content appendString:@"<LineStyle>\n"];

    
    [content appendString:@"<color>"];
    [content appendString:[self getRouteColorByIndex:index]];
    [content appendString:@"</color>"];
    [content appendString:[NSString stringWithFormat:@"<width>%d</width>\n", (index+1)*2]];
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

    return content;
}

-(NSString*) getPlaceMarkerForLocation:(CLLocation*) clLocation event:(NSNumber*) event index:(int) index
{
    NSMutableString *content = [[NSMutableString alloc] init];

    CLLocationCoordinate2D location = clLocation.coordinate;
    [content appendString:@"<Placemark>\n"];
    

    if (event.intValue == GR_EVENT_LOCATION_LOST)
    {
        [content appendString:@"<styleUrl>#red_marker</styleUrl>"];
        [content appendString:[NSString stringWithFormat:@"<name>%d_L</name>", index]];
    }
    else if (event.intValue == GR_EVENT_GPS_READY)
    {
        [content appendString:@"<styleUrl>#green_marker</styleUrl>"];
        [content appendString:[NSString stringWithFormat:@"<name>%d_R</name>", index]];
    }
    else
    {
        [content appendString:[NSString stringWithFormat:@"<name>%d</name>", index]];
    }

    [content appendString:@"<Point>\n"];
    [content appendString:[NSString stringWithFormat:@"<coordinates>%.8f,%.8f</coordinates>", location.longitude, location.latitude]];
    [content appendString:@"</Point>\n"];
    [content appendString:@"</Placemark>\n"];
    
    return content;
}

-(NSString*) getRouteColorByIndex:(int) index
{
    int tmpIndex = 0;
    
    tmpIndex = index%10;
    
    switch(tmpIndex)
    {
        case 0:
            return @"FFFF0000";
        case 1:
            return @"FF00FF00";
        case 2:
            return @"FF0000FF";
        case 3:
            return @"FF00FFFF";
        case 4:
            return @"FF8600FF";
        case 5:
            return @"FFFF44FF";
        case 6:
            return @"FFA23400";
        case 7:
            return @"FF8F4586";
        case 8:
            return @"FF467500";
        case 9:
            return @"FF984B4B";
    }
    
    return @"FF000000";
}

@end
