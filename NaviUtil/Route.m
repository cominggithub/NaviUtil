//
//  Route.m
//  GoogleDirection
//
//  Created by Coming on 13/1/8.
//  Copyright (c) 2013年 Coming. All rights reserved.
//

#import "Route.h"

@implementation Route

@synthesize status=_status;
-(id) init
{
    self = [super init];
    if(self)
    {
        routeLineCount = -1;
    }
    
    _status = RouteStatusCodeOK;
    return self;
}

-(id) initWithJsonRouteFile: (NSString*) fileName
{

    return self;
}

-(void) parseJson:(NSString*) fileName
{

    int i;
    NSArray *array;

    NSDictionary *dic;
    NSError* error;
    NSData *data = [[NSFileManager defaultManager] contentsAtPath:fileName];
    
    NSDictionary* root = [NSJSONSerialization
                          JSONObjectWithData:data //1
                          options:kNilOptions
                          error:&error];
    
    array = [root objectForKey:@"results"];
    dic = [array objectAtIndex:0];
    
    legs    = [[[root objectForKey:@"routes"] objectAtIndex:0] objectForKey:@"legs"];
    steps   = [[[[[root objectForKey:@"routes"] objectAtIndex:0] objectForKey:@"legs"] objectAtIndex:0] objectForKey:@"steps"];

    speech = [[NSMutableArray alloc] initWithCapacity:steps.count];

    [self initRouteLines];
    for(i=0; i<steps.count; i++)
    {
        Speech* s = [[Speech alloc] init];
        CLLocationCoordinate2D startLocation;
        CLLocationCoordinate2D endLocation;

        dic = [steps objectAtIndex:i];
        NSDictionary *location = [dic objectForKey:@"start_location"];
        
        s.text = [[NSString stringWithString:[dic objectForKey:@"html_instructions"]] stripHTML];
        s.coordinate  = CLLocationCoordinate2DMake([[location objectForKey:@"lat"] doubleValue],
                                                   [[location objectForKey:@"lng"] doubleValue]);

        startLocation  = CLLocationCoordinate2DMake([[location objectForKey:@"lat"] doubleValue],
                                                   [[location objectForKey:@"lng"] doubleValue]);

        location = [dic objectForKey:@"end_location"];
        
        endLocation  = CLLocationCoordinate2DMake([[location objectForKey:@"lat"] doubleValue],
                                                    [[location objectForKey:@"lng"] doubleValue]);
        
        [speech addObject:s];
        
        
        NSArray *stepPolyLine = [self getStepPolyLine:i];

        [self addLocationToRouteLinesWithStepNo:i Location:startLocation];
        
        for(CLLocation *location in stepPolyLine)
        {
            [self addLocationToRouteLinesWithStepNo:i Location:location.coordinate];
        }
        
        [self addLocationToRouteLinesWithStepNo:i Location:endLocation];
        
    }
    
    [self saveRouteLines];
    
    
    [self saveToKMLFileName:[self getName] filePath:[NSString stringWithFormat:@"%@/%@.kml", [SystemManager routeFilePath], [self getName]]];
    
//    [self dumpRouteLines];
}

-(void) initRouteLines
{
    tmpRouteLines   = [[NSMutableArray alloc] initWithCapacity:0];
    routeLineCount  = -1;
}

-(void) addLocationToRouteLinesWithStepNo:(int) stepNo Location:(CLLocationCoordinate2D) location
{
    
    routeLineEndLocation = location;
    
    if(routeLineCount == -1)
    {
        routeLineStartLocation = routeLineEndLocation;
        routeLineCount++;
    }
    
    if( !(routeLineStartLocation.longitude == routeLineEndLocation.longitude &&
          routeLineStartLocation.latitude == routeLineEndLocation.latitude))
    {
        RouteLine *routeLine = [RouteLine getRouteLineWithStartLocation: routeLineStartLocation
                                                            EndLocation: routeLineEndLocation
                                                                 stepNo: stepNo
                                                            routeLineNo:routeLineCount];
        [tmpRouteLines addObject:routeLine];
        routeLineCount++;
    }

    routeLineStartLocation = routeLineEndLocation;
}

-(void) saveRouteLines
{
    routeLines = [NSArray arrayWithArray:tmpRouteLines];
}

-(int) getStepCount
{
    return [steps count];
}

-(NSArray*) getSubRouteStartPoints
{
    int i = 0;
    int max = 100;
    int cnt = 0;
    PointD p;
    PointD prev;
    p.x = -1;
    prev.x = -2;
    NSMutableArray *routePolyLine = [[NSMutableArray alloc] initWithObjects:nil];
    for(i=0; i<[steps count] && cnt < max ; i++)
    {
        NSArray *stepPolyLine = [self getStepPolyLine:i];

        for(CLLocation *location in stepPolyLine)
        {
            p.x = location.coordinate.longitude;
            p.y = location.coordinate.latitude;
            
            if(!(prev.x == p.x && prev.y == prev.y))
                [routePolyLine addObject:[NSValue valueWithPointD:p]];
            
            cnt++;
            prev.x = p.x;
            prev.y = p.y;
            
            if(cnt > max)
                break;
        }
    }
    
    return routePolyLine;

}

-(NSArray*) getRoutePolyLineCLLocationCoordinate2D
{

    int i = 0;
    CLLocationCoordinate2D p;
    CLLocationCoordinate2D prev;
    prev = CLLocationCoordinate2DMake(0, 0);
    NSMutableArray *routePolyLine = [[NSMutableArray alloc] initWithObjects:nil];
    for(i=0; i<[steps count]; i++)
    {
        NSArray *stepPolyLine = [self getStepPolyLine:i];
        for(CLLocation *location in stepPolyLine)
        {
            p = location.coordinate;
            if(!(prev.latitude == p.latitude && prev.longitude == prev.longitude))
                [routePolyLine addObject:[NSValue valueWithCLLocationCoordinate2D:p]];
            prev = p;
        }
    }
    
    return routePolyLine;
}

-(NSArray*) getRoutePolyLinePointD
{
    int i = 0;
    int max = 1000000;
    int cnt = 0;
    PointD p;
    PointD prev;
    p.x = -1;
    prev.x = -2;
    NSMutableArray *routePolyLine = [[NSMutableArray alloc] initWithObjects:nil];
    for(i=0; i<[steps count] && cnt < max ; i++)
    {
        NSArray *stepPolyLine = [self getStepPolyLine:i];

        NSDictionary *dic = [steps objectAtIndex:i];
        NSDictionary *location = [dic objectForKey:@"start_location"];
        CLLocationCoordinate2D startLocation;
        CLLocationCoordinate2D endLocation;
        
        startLocation  = CLLocationCoordinate2DMake([[location objectForKey:@"lat"] doubleValue],
                                                    [[location objectForKey:@"lng"] doubleValue]);
        
        location = [dic objectForKey:@"end_location"];
        
        endLocation  = CLLocationCoordinate2DMake([[location objectForKey:@"lat"] doubleValue],
                                                  [[location objectForKey:@"lng"] doubleValue]);
        
        /* add start location */

        p.x = startLocation.longitude;
        p.y = startLocation.latitude;
        
        if(!(prev.x == p.x && prev.y == prev.y))
            [routePolyLine addObject:[NSValue valueWithPointD:p]];
        
        cnt++;
        prev.x = p.x;
        prev.y = p.y;
        
        /* add poly line */
        for(CLLocation *location in stepPolyLine)
        {
            p.x = location.coordinate.longitude;
            p.y = location.coordinate.latitude;
            
            if(!(prev.x == p.x && prev.y == prev.y))
                [routePolyLine addObject:[NSValue valueWithPointD:p]];
            
            cnt++;
            prev.x = p.x;
            prev.y = p.y;
            
            if(cnt > max)
                break;
        }

        /* add end location */
        p.x = endLocation.longitude;
        p.y = endLocation.latitude;
        
        if(!(prev.x == p.x && prev.y == prev.y))
            [routePolyLine addObject:[NSValue valueWithPointD:p]];
        
        cnt++;
        prev.x = p.x;
        prev.y = p.y;
        
    }
    
    return routePolyLine;
}

-(NSArray*) getRoutePolyLineCLLocation
{
    int i = 0;
    NSMutableArray *routePolyLine = [[NSMutableArray alloc] initWithObjects:nil];
    for(i=0; i<[steps count]; i++)
    {
        NSArray *stepPolyLine = [self getStepPolyLine:i];
        
        for(CLLocation *location in stepPolyLine)
        {
            [routePolyLine addObject:location];
        }
    }
    
    return routePolyLine;
}

-(NSArray*) getStepPolyLine:(int) index
{
    NSArray *polyLine = [[[(NSDictionary*)[steps objectAtIndex:index] objectForKey:@"polyline"] objectForKey:@"points"] decodePolyLine];
    return polyLine;

}

-(NSString* ) getStepInstruction: (int) index
{
    return [[(NSDictionary*)[steps objectAtIndex:index] objectForKey:@"html_instructions"] stripHTML];
}

-(NSString* ) getStepDurationString: (int) index
{
    return [[(NSDictionary*)[steps objectAtIndex:index] objectForKey:@"duration"] objectForKey:@"text"];
}

-(NSString* ) getStepDistanceString: (int) index
{
    return [[(NSDictionary*)[steps objectAtIndex:index] objectForKey:@"distance"] objectForKey:@"text"];
}

-(void) saveToKMLFileName:(NSString*)name filePath: (NSString*)filePath
{
    
    NSMutableString *content = [[NSMutableString alloc] init];
    NSMutableString *coordinates = [[NSMutableString alloc] init];
    NSArray* routePolyLine = self.getRoutePolyLineCLLocation;

    for(CLLocation* cl in routePolyLine)
    {
        [coordinates appendFormat:@"%f,%f,0 \n", cl.coordinate.longitude, cl.coordinate.latitude];
    }
    
    [content appendString:@"<?xml version=\"1.0\" standalone=\"yes\"?>\n"];
    [content appendString:@"<kml xmlns=\"http://earth.google.com/kml/2.2\">\n"];
    [content appendString:@"<Document>\n"];
    [content appendFormat:@"<name>%@</name>\n", name];
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
    [content appendString:@"</Document>\n"];
    [content appendString:@"</kml>"];
    
    NSError *err;
    mlogInfo(ROUTE, @"kml path:%@\n", filePath);
    
    BOOL ok = [content writeToFile:filePath atomically:YES encoding:NSUnicodeStringEncoding error:&err];
    
    if (!ok)
    {
        mlogWarning(ROUTE, @"cannot write: %@\n", filePath);
    }
    
}



-(NSString*) getDocumentDirectory
{
    NSFileManager *filemanager;
    NSString *currentPath;
    
    filemanager =[NSFileManager defaultManager];
    currentPath = [filemanager currentDirectoryPath];
    
    NSArray *dirPaths;
    NSString *docsDir;
    
    dirPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                   NSUserDomainMask, YES);
    docsDir = [dirPaths objectAtIndex:0];
    return docsDir;
}

-(NSArray*) getSpeech
{
    return speech;
}

-(NSString*) getStartAddress
{
    return [[legs objectAtIndex:0] objectForKey:@"start_address"];
}

-(NSString*) getEndAddress
{
    return [[legs objectAtIndex:0] objectForKey:@"end_address"];
}

-(NSString*) getDurationString
{
    return [[[legs objectAtIndex:0] objectForKey:@"duration"] objectForKey:@"text"];
}

-(NSString*) getDistanceString
{
    return [[[legs objectAtIndex:0] objectForKey:@"distance"] objectForKey:@"text"];
}

-(CLLocationCoordinate2D) getStartLocation
{
    NSDictionary *location = [[legs objectAtIndex:0] objectForKey:@"start_location"];
    CLLocationCoordinate2D result = CLLocationCoordinate2DMake(
                                        [[location objectForKey:@"lat"] doubleValue],
                                        [[location objectForKey:@"lng"] doubleValue]);
    
    return result;
}

-(CLLocationCoordinate2D) getEndLocation
{
    NSDictionary *location = [[legs objectAtIndex:0] objectForKey:@"end_location"];
    CLLocationCoordinate2D result = CLLocationCoordinate2DMake(
                                                               [[location objectForKey:@"lat"] doubleValue],
                                                               [[location objectForKey:@"lng"] doubleValue]);
    
    return result;
}

-(NSString *) getName
{
    return [NSString stringWithFormat:@"%@_to_%@",
            [self getStartAddress],
            [self getEndAddress]
            ];
    
}

-(NSString *) getNameWithCoordinate
{
    CLLocationCoordinate2D startLocation = [self getStartLocation];
    CLLocationCoordinate2D endLocation = [self getStartLocation];
    
    return [NSString stringWithFormat:@"%@_to_%@((%.7f,%.7f)_To_(%.7f,%.7f))",
            [self getStartAddress],
            [self getEndAddress],
            startLocation.latitude,
            startLocation.longitude,
            endLocation.latitude,
            endLocation.longitude
            ];
}

-(NSString *) description
{
    CLLocationCoordinate2D startLocation = [self getStartLocation];
    CLLocationCoordinate2D endLocation = [self getStartLocation];
    
    return [NSString stringWithFormat:@"%@ To %@ (%.7f,%.7f) -> (%.7f,%.7f)",
            [self getStartAddress],
            [self getEndAddress],
            startLocation.latitude,
            startLocation.longitude,
            endLocation.latitude,
            endLocation.longitude
            ];
}


-(RouteLine*) findClosestRouteLineByLocation:(CLLocationCoordinate2D) location LastRouteLine:(RouteLine*)lastRouteLine
{
    int i=0;
    int radius = 10;
    int searchCount = 0;
    NSDate* startTime;
    NSDate* endTime;
    NSTimeInterval duration;
    
    
    
    RouteLine* matchedRouteLine = nil;
    RouteLine* matchedRouteLineWithEndPoint = nil;
    double distance = 0;
    double distanceFromEndPoint = 0.00008;
    double tmpDistance = 0.0;
    double angleStart = 0.0;
    double angleEnd = 0.0;
    double minDistanceRequired = 0.00008; // almost 10m

    startTime = [NSDate date];

#if 0
    if(lastRouteLine != nil)
    {
        /* look forward */
        for(i=lastRouteLine.routeLineNo; i<lastRouteLine.routeLineNo+radius && i<routeLineCount; i++)
        {
            logi(i);
            RouteLine *rl = [routeLines objectAtIndex:i];
            tmpDistance = [rl getDistanceWithLocation:location];
            if(matchedRouteLine == nil || tmpDistance < distance)
            {
                matchedRouteLine = rl;
                distance = tmpDistance;
                searchCount++;
            }
        }
        
        /* look backward */
        for(i=lastRouteLine.routeLineNo; i>=0 && i<routeLineCount; i--)
        {
            logi(i);
            RouteLine *rl = [routeLines objectAtIndex:i];
            tmpDistance = [rl getDistanceWithLocation:location];
            logf(tmpDistance);
            if(matchedRouteLine == nil || tmpDistance < distance)
            {
                matchedRouteLine = rl;
                distance = tmpDistance;
                searchCount++;
            }
        }
        
    }
#endif
    /* worest case */
    /* if not found, look up all route lines */
    
//    if(matchedRouteLine == nil || distance >= minDistanceRequired)
    {
        for (RouteLine* rl in routeLines)
        {
            tmpDistance = [rl getDistanceWithLocation:location];
            angleStart = TO_ANGLE([rl getAngleToStartLocation:location]);
            angleEnd = TO_ANGLE([rl getAngleToEndLocation:location]);
            
            if(matchedRouteLine == nil || (tmpDistance <= distance &&  ((angleStart <= 90) && angleEnd <= 90)))
            {
                matchedRouteLine = rl;
                distance = tmpDistance;
            }
            
            tmpDistance = [GeoUtil getGeoDistanceFromLocation:rl.startLocation ToLocation:location];
            
            if(tmpDistance < distanceFromEndPoint)
            {
                matchedRouteLineWithEndPoint = rl;
                distanceFromEndPoint = tmpDistance;
                mlogDebug(ROUTE, @"RouteLineNo:%3d, distance: %11.7f", rl.routeLineNo, distanceFromEndPoint);
            }
            
            mlogDebug(ROUTE, @"RouteLineNo:%3d, angle: %8.4f, angleS: %8.4f, angleE: %8.4f, distance: %11.7f",
                     rl.routeLineNo,
                     angleStart + angleEnd,
                     angleStart,
                     angleEnd,
                     tmpDistance
                     );
            
            searchCount++;

        }
    }
    
    


    if(distance >= minDistanceRequired)
    {
        matchedRouteLine = matchedRouteLineWithEndPoint;
    }
    
    
    endTime = [NSDate date];
    
    duration = [endTime timeIntervalSinceDate:startTime];


    mlogInfo(ROUTE, @"Matched: %d(%.7f), RouteLine %d searched, in %f seconds",
             matchedRouteLine != nil ? matchedRouteLine.routeLineNo : -1,
             distance,
             searchCount,
             duration
             );

    return matchedRouteLine;
}

-(void) dumpRouteLines
{
    logfn();
    logi(routeLines.count);
    for(RouteLine *rl in routeLines)
    {
        logObjNoName(rl);
    }
}
-(void) dump
{
    
}

@end
