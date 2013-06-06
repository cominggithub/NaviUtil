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
@synthesize routeLines=_routeLines;
-(id) init
{
    self = [super init];
    if(self)
    {
        routeLineCount = -1;
    }
    
    _status = kRouteStatusCodeFail;
    return self;
}

-(id) initWithJsonRouteFile: (NSString*) fileName
{

    return self;
}

-(bool) parseJson:(NSString*) fileName
{

    int i = 0;
    NSArray *array;
    NSDictionary *location;
    NSDictionary *dic;
    NSError* error;
    NSData *data;
    NSDictionary* root;
    
    if ( [GoogleJson getStatus:fileName] != kGoogleJsonStatus_Ok )
    {
        return nil;
    }
    
    @try
    {
        
        data  = [[NSFileManager defaultManager] contentsAtPath:fileName];
        root  = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
        array = [root objectForKey:@"results"];
        dic = [array objectAtIndex:0];
    
        legs    = [[[root objectForKey:@"routes"] objectAtIndex:0] objectForKey:@"legs"];
        steps   = [[[[[root objectForKey:@"routes"] objectAtIndex:0] objectForKey:@"legs"] objectAtIndex:0] objectForKey:@"steps"];
        speech = [[NSMutableArray alloc] initWithCapacity:steps.count];
        [self initRouteLines];

        dic = [[[[root objectForKey:@"routes"] objectAtIndex:0] objectForKey:@"legs"] objectAtIndex:0];
 
        /* add Start Location */
        [self addLocationToRouteLinesWithStepNo:i Location:[self getStartLocation]];
    
        for(i=0; i<steps.count; i++)
        {
            Speech* s = [[Speech alloc] init];
            dic = [steps objectAtIndex:i];
            s.text = [[NSString stringWithString:[dic objectForKey:@"html_instructions"]] stripHTML];
            s.coordinate  = CLLocationCoordinate2DMake([[location objectForKey:@"lat"] doubleValue],
                                                   [[location objectForKey:@"lng"] doubleValue]);
            [speech addObject:s];
            NSArray *stepPolyLine = [self getStepPolyLine:i];
            /* add points in PolyLie */
            for(CLLocation *location in stepPolyLine)
            {
                [self addLocationToRouteLinesWithStepNo:i Location:location.coordinate];
            }

        }
    
        self.status = kRouteStatusCodeOk;
        [self addLocationToRouteLinesWithStepNo:i Location:[self getEndLocation]];

        [self saveRouteLines];
        [self saveToKMLFileName:[self getName] filePath:[NSString stringWithFormat:@"%@/%@.kml", [SystemManager routeFilePath], [self getName]]];
//        [self dumpRouteLines];
    
//        [self dumpRouteLineAndPolyLine];
        mlogDebug(ROUTE, @"parse json file done: %@", fileName);
        return true;
        
    }
    @catch (NSException *exception)
    {
        mlogWarning(ROUTE, @"parse json file fail: %@, reason: %@\n%@", fileName, [exception reason], exception );
    }
    @finally
    {
//        mlogWarning(ROUTE, @"parse json file fail: %@", fileName);
    }
    
    return false;
}

+(Route*) parseJson:(NSString*) fileName
{
    Route* r = [[Route alloc] init];
    if(![r parseJson:fileName])
        return nil;
    return r;
    
}
-(void) initRouteLines
{
    tmpRouteLines   = [[NSMutableArray alloc] initWithCapacity:0];
    routeLineCount  = -1;
}

-(void) addLocationToRouteLinesWithStepNo:(int) stepNo Location:(CLLocationCoordinate2D) location
{
    mlogDebug(ROUTE, @"AddLocationToRouteLinesWithStepNo: %3d, Line: %3d, (%12.7f, %12.7f)", stepNo, routeLineCount, location.latitude, location.longitude);
    
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
    else
    {
        mlogDebug(ROUTE, @"    Skip");
    }

    routeLineStartLocation = routeLineEndLocation;
}

-(void) saveRouteLines
{
    self.routeLines = [NSArray arrayWithArray:tmpRouteLines];
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
    int max = 100000;
    int cnt = 0;
    PointD p;
    PointD prev;
    p.x = -1;
    prev.x = -2;
    NSMutableArray *routePolyLine = [[NSMutableArray alloc] initWithObjects:nil];
    
    /* add start location */
    p = [GeoUtil makePointDFromCLLocationCoordinate2D:[self getStartLocation]];
    prev.x  = p.x;
    prev.y  = p.y;
    [routePolyLine addObject:[NSValue valueWithPointD:p]];
    
    for(i=0; i<[steps count] && cnt < max ; i++)
    {
        NSArray *stepPolyLine = [self getStepPolyLine:i];
        
        /* add points in poly line */
        for(CLLocation *location in stepPolyLine)
        {
            p.x = location.coordinate.longitude;
            p.y = location.coordinate.latitude;
            
            if(!(prev.x == p.x && prev.y == p.y))
                [routePolyLine addObject:[NSValue valueWithPointD:p]];
            
            cnt++;
            prev.x = p.x;
            prev.y = p.y;
            
            if(cnt > max)
                break;
        }


    }
    
    /* add end location */
    p = [GeoUtil makePointDFromCLLocationCoordinate2D:[self getEndLocation]];
    
    [routePolyLine addObject:[NSValue valueWithPointD:p]];
    
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
    return [NSString stringWithFormat:@"%@ to %@ (%.7f,%.7f) -> (%.7f,%.7f), Step:%d, RouteLines:%d",
            [self getStartAddress],
            [self getEndAddress],
            [self getStartLocation].latitude,
            [self getStartLocation].longitude,
            [self getEndLocation].latitude,
            [self getEndLocation].longitude,
            steps.count,
            self.routeLines.count
            ];
}


-(RouteLine*) findClosestRouteLineByLocation:(CLLocationCoordinate2D) location LastRouteLine:(RouteLine*)lastRouteLine
{
    int i=0;
    int radius = 5;
    int searchCount = 0;
    NSDate* startTime;
    NSDate* endTime;
    NSTimeInterval duration;
    
    
    
    RouteLine* matchedRouteLine = nil;
    RouteLine* matchedRouteLineWithEndPoint = nil;
    double distance = 99999;
    double distanceFromEndPoint = 99999;
    double tmpDistance = 0.0;
    double tmpStartDistance = 0.0;
    double angleStart = 0.0;
    double angleEnd = 0.0;
    double minDistanceRequired = 20; // 10m

    startTime = [NSDate date];
    NSString *matchFlag;

    if(lastRouteLine == nil)
        i = 0;
    else
        i = lastRouteLine.routeLineNo;
    
        /* look forward */
        for(; i<lastRouteLine.routeLineNo+radius && i<routeLineCount; i++)
        {

            RouteLine *rl = [self.routeLines objectAtIndex:i];
            [self calculateDistanceFromLocation:location
                                  fromRouteLine:rl
                                     angleStart:&angleStart
                                       angleEnd:&angleEnd
                                       distance:&tmpDistance
                              distanceFromStart:&tmpStartDistance];
            matchFlag = @"";
            if(angleStart <= 90 && angleEnd <= 90)
            {
                matchFlag = @"A";
            }
            if((tmpDistance <= distance &&  ((angleStart <= 90) && angleEnd <= 90)))
            {
                
                matchedRouteLine = rl;
                distance = tmpDistance;
                matchFlag = [NSString stringWithFormat:@"%@%@", matchFlag, @"*"];
            }
            if(tmpStartDistance < distanceFromEndPoint)
            {
                matchedRouteLineWithEndPoint = rl;
                distanceFromEndPoint = tmpStartDistance;
                matchFlag = [NSString stringWithFormat:@"%@%@", matchFlag, @"E"];
            }
            
            mlogDebug(ROUTE, @"RouteLineNo:%3d, angle: %8.4f, angleS: %8.4f, angleE: %8.4f, distance: %11.7f Ed: %11.7f %@",
                      rl.routeLineNo,
                      angleStart + angleEnd,
                      angleStart,
                      angleEnd,
                      tmpDistance,
                      tmpStartDistance,
                      matchFlag
                      );
            
            searchCount++;
        }
        
        /* look backward */
        if(lastRouteLine == nil)
            i = -1;
        for(i=lastRouteLine.routeLineNo-1; i>=0 && i>=lastRouteLine.routeLineNo-radius && i<routeLineCount; i--)
        {
            RouteLine *rl = [self.routeLines objectAtIndex:i];
            [self calculateDistanceFromLocation:location
                                  fromRouteLine:rl
                                     angleStart:&angleStart
                                       angleEnd:&angleEnd
                                       distance:&tmpDistance
                              distanceFromStart:&tmpStartDistance];
            matchFlag = @"";   
            if(angleStart <= 90 && angleEnd <= 90)
            {
                matchFlag = @"A";
            }
            if((tmpDistance <= distance &&  ((angleStart <= 90) && angleEnd <= 90)))
            {
                
                matchedRouteLine = rl;
                distance = tmpDistance;
                matchFlag = [NSString stringWithFormat:@"%@%@", matchFlag, @"*"];
            }
            if(tmpStartDistance < distanceFromEndPoint)
            {
                matchedRouteLineWithEndPoint = rl;
                distanceFromEndPoint = tmpStartDistance;
                matchFlag = [NSString stringWithFormat:@"%@%@", matchFlag, @"E"];
            }
            
            mlogDebug(ROUTE, @"RouteLineNo:%3d, angle: %8.4f, angleS: %8.4f, angleE: %8.4f, distance: %11.7f Ed: %11.7f %@",
                      rl.routeLineNo,
                      angleStart + angleEnd,
                      angleStart,
                      angleEnd,
                      tmpDistance,
                      tmpStartDistance,
                      matchFlag
                      );
            
            searchCount++;
        }
#if 0
    /* worest case */
    /* if not found, look up all route lines */
    
//    if(matchedRouteLine == nil || distance >= minDistanceRequired)
    {
        for (RouteLine* rl in self.routeLines)
        {
            tmpDistance = [rl getGeoDistanceToLocation:location];
            angleStart = TO_ANGLE([rl getAngleToStartLocation:location]);
            angleEnd = TO_ANGLE([rl getAngleToEndLocation:location]);
            matchFlag = @"";
            if(angleStart <= 90 && angleEnd <= 90)
            {
                matchFlag = @"A";
            }
            if((tmpDistance <= distance &&  ((angleStart <= 90) && angleEnd <= 90)))
            {

                matchedRouteLine = rl;
                distance = tmpDistance;
                matchFlag = [NSString stringWithFormat:@"%@%@", matchFlag, @"*"];
            }
            tmpStartDistance = [GeoUtil getGeoDistanceFromLocation:rl.startLocation ToLocation:location];

            if(tmpStartDistance < distanceFromEndPoint)
            {
                matchedRouteLineWithEndPoint = rl;
                distanceFromEndPoint = tmpStartDistance;
                matchFlag = [NSString stringWithFormat:@"%@%@", matchFlag, @"E"];
            }
            
            mlogDebug(ROUTE, @"RouteLineNo:%3d, angle: %8.4f, angleS: %8.4f, angleE: %8.4f, distance: %11.7f Ed: %11.7f %@",
                      rl.routeLineNo,
                      angleStart + angleEnd,
                      angleStart,
                      angleEnd,
                      tmpDistance,
                      tmpStartDistance,
                      matchFlag
                      );
            
            searchCount++;
            
            if(searchCount > 20)
                break;

        }
    }
#endif    
    


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

-(void) calculateDistanceFromLocation:(CLLocationCoordinate2D) location fromRouteLine:(RouteLine*) rl
               angleStart:(double*) angleStart angleEnd:(double*) angleEnd distance:(double*) distance distanceFromStart:(double*) distanceFromStart
{
    *distance           = [rl getGeoDistanceToLocation:location];
    *angleStart         = TO_ANGLE([rl getAngleToStartLocation:location]);
    *angleEnd           = TO_ANGLE([rl getAngleToEndLocation:location]);
    *distance           = [rl getGeoDistanceToLocation:location];
    *distanceFromStart  = [GeoUtil getGeoDistanceFromLocation:rl.startLocation ToLocation:location];
}

-(RouteLine*) getNextStepFirstRouteLineByStepNo:(int)stepNo CarLocation:(CLLocationCoordinate2D) carLocation
{
    for(RouteLine* rl in self.routeLines)
    {
        if(rl.stepNo == stepNo+1)
        {
            double distance = [GeoUtil getGeoDistanceFromLocation:rl.startLocation ToLocation:carLocation];
            if(distance < 100)
                return rl;
        }
    }
    
    return nil;
}

-(void) dumpRouteLines
{
    logfn();
    logi(self.routeLines.count);
    for(RouteLine *rl in self.routeLines)
    {
        logObjNoName(rl);
    }
}

-(void) dumpRouteLineAndPolyLine
{
    int i=0;
    NSArray* polyLine = [self getRoutePolyLinePointD];
    for(i=0; i<polyLine.count && i<self.routeLines.count;i++)
    {
        NSValue *v = [polyLine objectAtIndex:i];
        RouteLine *rl = [self.routeLines objectAtIndex:i];
        PointD p = [v PointDValue];
        if(p.y == rl.startLocation.latitude && p.x == rl.startLocation.longitude)
        {
            printf(" ");
        }
        else
        {
            printf("!");
        }
        printf("step:%4d, line: %4d, (%12.7f, %12.7f), (%12.7f, %12.7f)\n", rl.stepNo, rl.routeLineNo, p.y, rl.startLocation.latitude, p.x, rl.startLocation.longitude);
    }
    
}

@end
